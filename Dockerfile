FROM node:12-alpine AS ui
WORKDIR /ui
COPY package.json package-lock.json /ui/
RUN npm install
COPY ui .
RUN npm run build

FROM golang:1.13 AS build
WORKDIR /wg
RUN go get github.com/go-bindata/go-bindata/... &&\
    go get github.com/elazarl/go-bindata-assetfs/...
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
COPY --from=ui /ui/public ui/public
RUN go-bindata-assetfs -prefix ui/public ui/public &&\
    go install .

FROM gcr.io/distroless/base
COPY --from=build /go/bin/wireguard-ui /
ENTRYPOINT [ "/wireguard-ui" ]
