# syntax=docker/dockerfile:1
ARG AURORA_VERSION=latest
ARG SUFFIX
FROM plone/aurora-builder:${AURORA_VERSION}${SUFFIX} AS builder

RUN --mount=type=cache,id=pnpm,target=/app/.pnpm-store,uid=1000 <<EOT
    set -e
    pnpm build
    rm -rf node_modules
    pnpm install --prod
EOT

ARG AURORA_VERSION=latest
ARG SUFFIX
FROM plone/aurora-prod-config:${AURORA_VERSION}${SUFFIX} AS base

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="plone-aurora" \
      org.label-schema.description="Plone Aurora frontend image" \
      org.label-schema.vendor="Plone Foundation"

COPY --from=builder /app/ /app/

# Install the pnpm version declared by the Cookieplone-generated package.json.
RUN corepack install
