FROM --platform=$BUILDPLATFORM alpine as protoc
ARG BUILDPLATFORM=linux/amd64 TARGETOS=linux TARGETARCH=amd64

# download the protoc binary from github
# We unzip the file into /usr/local. Notice that we are extracting both the protoc
# binary (/bin/protoc) and the /include folder because the first one is the compiler that we are
# going to use and the second one is all the files needed to include Well-Known Types.
RUN export PROTOC_VERSION=26.1 \
    && export PROTOC_ARCH=$(uname -m | sed s/aarch64/aarch_64/) \
    && export PROTOC_OS=$(echo $TARGETOS | sed s/darwin/linux/) \
    && export PROTOC_ZIP=protoc-$PROTOC_VERSION-$PROTOC_OS-$PROTOC_ARCH.zip \
    && echo "downloading: " https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_ZIP \
    && wget https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_ZIP \
    && unzip -o $PROTOC_ZIP -d /usr/local bin/protoc 'include/*' \
    && rm -f $PROTOC_ZIP

FROM --platform=$BUILDPLATFORM golang:1.22-alpine as build
ARG BUILDPLATFORM=linux/amd64 TARGETOS=linux TARGETARCH=amd64

# copy the protoc binary and the protobuf includes
COPY --from=protoc /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=protoc /usr/local/include/google /usr/local/include/google

# download protoc plugins
RUN go env -w GOPROXY=https://goproxy.io,direct
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
RUN go install github.com/envoyproxy/protoc-gen-validate@latest

# copy proto files into /go/src/proto
WORKDIR /go/src/proto
COPY ./proto .

# generate code out of proto files
WORKDIR /go
ENV MODULE=zgrpc-go-professionals
RUN protoc --proto_path=src/proto \
           --go_out=src \
           --go_opt=module=$MODULE \
           --go-grpc_out=src \
           --go-grpc_opt=module=$MODULE \
           --validate_out="lang=go,module=$MODULE:src" \
           src/proto/todo/v2/*.proto

# copy code into /go/src/server
WORKDIR /go/src/server
COPY ./server .

# copy go.mod into go/src
WORKDIR /go/src
COPY go.mod .

# download dependencies and build
RUN go mod tidy
WORKDIR /go/src/server
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-s -w" -o /go/bin/server

FROM scratch

# copy certs into /certs
COPY ./certs/server_cert.pem ./certs/server_cert.pem
COPY ./certs/server_key.pem ./certs/server_key.pem

# copy the previously built binary into smaller image
COPY --from=build /go/bin/server /
EXPOSE 50051 5002
CMD ["/server", "0.0.0.0:50051", "0.0.0.0:50052"]