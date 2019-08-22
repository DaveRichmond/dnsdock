ARG GOLANG_VERSION="1.9"
ARG ALPINE_VERSION="3"

FROM golang:${GOLANG_VERSION}-alpine AS build

RUN apk update
RUN apk add git musl-dev gcc

RUN go get -v github.com/tools/godep
RUN go get -u github.com/golang/lint/golint
RUN go get github.com/ahmetb/govvv

ARG BUILD_DIR=github.com/aacebedo/dnsdock
WORKDIR /go/src/${BUILD_DIR}
COPY . .
RUN godep restore

WORKDIR /go/src/${BUILD_DIR}/src
RUN govvv build -o /go/bin/dnsdock
RUN golint -set_exit_status
RUN go vet
RUN go test ./...

FROM alpine:${ALPINE_VERSION}
COPY --from=build /go/bin/dnsdock /bin/dnsdock
CMD ["/bin/dnsdock"]
