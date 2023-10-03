FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES git build-base

# Set working directory for the build
WORKDIR /go/src/github.com/evmos/ethermint

# Install dependencies
RUN apk add --update $PACKAGES
RUN apk add linux-headers rust cargo

# Add source files
COPY . .

RUN go mod download

RUN cd $(go env GOPATH)/pkg/mod/github.com/dcspark/go-ethereum@v1.10.26-mina/ && make mina

# Make the binary
RUN make build

# Final image
FROM alpine:3.17.3

# Install ca-certificates
RUN apk add --update ca-certificates jq gcc
WORKDIR /

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/evmos/ethermint/build/ethermintd /usr/bin/ethermintd

# Run ethermintd by default
CMD ["ethermintd"]
