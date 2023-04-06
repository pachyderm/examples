from golang:1.20.2-alpine3.17


WORKDIR /app
COPY splitcombine.go /app

RUN go build -o splitcombine splitcombine.go

from scratch

COPY --from=0 /app/splitcombine /splitcombine
WORKDIR /

