FROM golang:1.22-alpine AS builder

# Instalar certificados SSL y git
RUN apk add --no-cache ca-certificates git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main ./cmd/api/main.go

FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /app

RUN mkdir -p /app/uploads

COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
