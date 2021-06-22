module Main where

import Prelude

import Control.Monad.Except (ExceptT(..))
import Control.Monad.Except.Trans (lift)
import Control.Monad.Indexed ((:>>=), (:*>))
import Control.Monad.Indexed (ibind, (:*>))
import Control.Monad.Indexed.Qualified as Ix
import Data.Argonaut (class EncodeJson, Json, decodeJson, jsonEmptyObject, stringify, (:=), (~>))
import Data.Either (Either(..), either)
import Data.HTTP.Method (Method(..))
import Data.Lazy (force)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Class (class MonadAff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Hyper.Conn (Conn)
import Hyper.Middleware (Middleware, lift')
import Hyper.Node.Server (HttpRequest, HttpResponse, NodeResponse, defaultOptionsWithLogging, runServer)
import Hyper.Request (class Request, getRequestData)
import Hyper.Response (class Response, class ResponseWritable, ResponseEnded, StatusLineOpen, closeHeaders, contentType, end, headers, respond, writeHeader, writeStatus)
import Hyper.Status (Status, status, statusBadRequest, statusMethodNotAllowed, statusNotAcceptable, statusNotFound, statusOK)
import Hyper.Trout.Router (RoutingError, router)
import Type.Proxy (Proxy(..))
import Type.Trout (type (:/), type (:<|>), type (:=), type (:>), Capture, Resource, Raw)
import Type.Trout.ContentType.JSON (JSON)
import Type.Trout.Method (Get)

foreign import _getUrl :: YoutubeId -> Format -> EffectFnAff Url

type YoutubeId = String

type Url = String
type Format = String

getUrl :: YoutubeId -> Format -> Aff Url
getUrl y f = fromEffectFnAff $ _getUrl y f

data Home = Home { url :: String }

instance encodeJsonHome :: EncodeJson Home where
  encodeJson (Home { url }) = "url" := url ~> jsonEmptyObject

type Site = "home" := "get" :/ Capture "youtubeid" YoutubeId :> Capture "format" Format :> Raw "GET"
       :<|> "preflight" := "get" :/ Capture "youtubeid" YoutubeId :> Capture "format" Format :> Raw "OPTIONS"

-- type Site = "home" := "get" :/ Capture "youtubeid" YoutubeId :> Capture "format" Format :> Resource (Get Home JSON)
--        :<|> "home2" := "get2" :/ Capture "youtubeid" YoutubeId :> Capture "format" Format :> Raw "GET"

-- home :: YoutubeId -> Format -> {"GET" :: ExceptT RoutingError Aff Home}
-- home ytid fmt = {"GET": _ } $ do
--   -- url <- lift $ getUrl ytid fmt
--   -- pure $ Home { url }

home :: YoutubeId -> Format -> Middleware Aff
      { request :: HttpRequest
      , response :: HttpResponse StatusLineOpen
      , components :: Record ()
      }
      { request :: HttpRequest
      , response :: HttpResponse ResponseEnded
      , components :: Record ()
      } Unit
home ytid fmt = Ix.do
  writeStatus statusOK
  writeHeader $ Tuple "Access-Control-Allow-Origin" "*"
  writeHeader $ Tuple "Access-Control-Allow-Methods" "OPTIONS, POST, GET"
  closeHeaders
  url <- lift' $ getUrl ytid fmt
  respond $ stringify $ "url" := url ~> jsonEmptyObject

preflight :: YoutubeId -> Format -> Middleware Aff
      { request :: HttpRequest
      , response :: HttpResponse StatusLineOpen
      , components :: Record ()
      }
      { request :: HttpRequest
      , response :: HttpResponse ResponseEnded
      , components :: Record ()
      } Unit
preflight ytid fmt = Ix.do
  writeStatus $ status 204 "Success No Content"
  closeHeaders
  end


site :: Proxy Site
site = Proxy

main :: Effect Unit
main = runServer defaultOptionsWithLogging {} siteRouter
  where
    siteRouter = router site { home, preflight } onRoutingError
    onRoutingError status msg = Ix.do
      writeStatus statusOK
      closeHeaders
      respond "ok. /get/${id}/${format}"