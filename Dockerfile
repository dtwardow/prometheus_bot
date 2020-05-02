FROM golang:1.14-alpine3.11 as builder
RUN \
    cd / && \
    apk update && \
    apk add --no-cache git ca-certificates make tzdata && \
    git clone https://github.com/inCaller/prometheus_bot
ADD main.go /prometheus_bot/main.go
RUN cd /prometheus_bot && \
    go get -d -v && \
    CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o prometheus_bot 

FROM alpine:3.11
COPY --from=builder /prometheus_bot/prometheus_bot /
RUN apk add --no-cache ca-certificates tzdata tini
USER nobody
EXPOSE 9087
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/prometheus_bot"]
