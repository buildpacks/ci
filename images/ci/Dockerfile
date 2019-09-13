FROM golang:1.13-alpine as golang

FROM concourse/docker-image-resource:1.3.1

# GOLANG
COPY --from=golang /usr/local/go /usr/local/go
ENV GOPATH="/go"
ENV GOROOT="/usr/local/go"
ENV PATH="${GOPATH}/bin:${GOROOT}/bin:${PATH}"
RUN mkdir -p ${GOPATH}

# BUILD DEPS
RUN apk add --no-cache build-base git