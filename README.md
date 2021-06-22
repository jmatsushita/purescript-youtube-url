# Work in Progress. Purescript Youtube URL

Small node.js endpoint to provide a video or audio streaming url for youtube ids and a specific format.

## Usage

```
% node index.js
Listening on http://0.0.0.0:3000
```

```
% curl http://0.0.0.0:3000/
ok. /get/${id}/${format}
```

Provide a youtube id and a format id.

`vendor` folder is included for Dockerfile with arm64 target.

## Warning Broken

Used `youtube-dl` npm module, which got deprecated in favor of `youtube-dl-exec` with a different API. Started to port, but not sure of the relevance at this point. PR welcome!