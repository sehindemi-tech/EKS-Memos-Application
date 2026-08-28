# syntax=docker/dockerfile:1

FROM node:24-alpine AS frontend

WORKDIR /web

RUN corepack enable && corepack prepare pnpm@11.0.1 --activate

COPY web/package.json web/pnpm-lock.yaml ./
COPY web/patches ./patches

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --no-frozen-lockfile

COPY web/ .

RUN pnpm release

FROM golang:1.27.0-alpine AS backend

RUN apk add --no-cache ca-certificates tzdata git && \
    adduser -u 10001 -D nonroot

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

WORKDIR /app

COPY go.mod go.sum ./

RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .

COPY --from=frontend /server/router/frontend/dist ./server/router/frontend/dist

ARG VERSION=dev COMMIT=unknown

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath \
    -ldflags="-s -w -X github.com/usememos/memos/internal/version.Version=${VERSION} -X github.com/usememos/memos/internal/version.Commit=${COMMIT} -extldflags '-static'" \
    -tags netgo,osusergo \
    -o memos ./cmd/memos

FROM scratch

COPY --from=backend /etc/passwd /etc/passwd
COPY --from=backend /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=backend /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=backend /app/memos /usr/local/bin/memos


USER nonroot

WORKDIR /var/opt/memos

ENV TZ="UTC" \
    MEMOS_PORT="5230"

EXPOSE 5230

ENTRYPOINT ["/usr/local/bin/memos"]