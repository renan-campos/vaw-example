# Build the manager binary
FROM golang:1.13 as builder

WORKDIR /workspace

# Copy the go source
COPY server.go server.go

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o server server.go

# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
USER nonroot:nonroot
WORKDIR /
COPY --from=builder /workspace/server .
COPY --chown=nonroot:nonroot tls/server.crt tls/server.crt
COPY --chown=nonroot:nonroot tls/server.key tls/server.key

ENTRYPOINT ["/server"]
