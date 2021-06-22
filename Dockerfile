#FROM mstephano/haskell-arm:jetson-debian10.3-haskell8.4.4

# FROM node:12

FROM ubuntu:18.04

RUN apt-get update && \
  apt-get install -y curl && \
  rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
# RUN apt-get update && apt-cache search ncurses
RUN apt-get update && apt-get install -y \
	nodejs \ 
	netbase \
	git \
#	libncurses5-dev \
#	llvm-6.0 \
#	gcc \
#	build-essential \
#	make \
#	libnuma-dev \
#	autoconf \
#	python3 \
#	libgmp-dev \
#	zlib1g \
#	zlib1g-dev \
     	&& rm -rf /var/lib/apt/lists/*

#RUN node --version
#RUN curl -sSL https://github.com/commercialhaskell/stack/releases/download/v2.1.1/stack-2.1.1-linux-aarch64.tar.gz --output stack-2.1.1-linux-aarch64.tar.gz
#RUN tar xvzf stack-2.1.1-linux-aarch64.tar.gz
#RUN cp stack-2.1.1-linux-aarch64/stack /usr/local/bin/
#RUN chmod +x /usr/local/bin/stack 
#RUN stack --version 

## Install purescript from source manually
#RUN stack update
#RUN stack unpack purescript
## RUN cd purescript-0.13.8
#RUN cd purescript-0.13.8 && stack install -v --flag purescript:RELEASE

# RUN git clone https://github.com/purescript/purescript.git
# RUN cd purescript
# RUN apt-get update && apt-get install -y && \
#  rm -rf /var/lib/apt/lists/* 
# RUN stack config set system-ghc --global true
# RUN stack setup -v


# Create app directory
WORKDIR /usr/src/app

COPY vendor/purs /usr/local/bin/purs
COPY vendor/spago /usr/local/bin/spago

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./


#RUN npm install -g purescript --unsafe-perm=true
RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

COPY *.dhall ./

RUN spago install

# Bundle app source
COPY . .

RUN spago build

EXPOSE 8080
CMD [ "node", "index.js" ]

