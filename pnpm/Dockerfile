# syntax=docker/dockerfile:1
# Both bases are passed in as complete references rather than assembled from a
# version tag, so CI can pin them to the manifest digests built in the same run.
# The defaults keep a bare `docker build` working.
# Both refs are declared HERE, before the first FROM: only ARGs in this global
# scope are usable by FROM instructions. Declaring PROD_CONFIG_REF next to the
# stage that uses it would put it in the `builder` stage's scope, and the second
# FROM would fail with "base name should not be blank".
ARG BUILDER_REF=plone/aurora-builder:latest
ARG PROD_CONFIG_REF=plone/aurora-prod-config:latest
FROM ${BUILDER_REF} AS builder

RUN --mount=type=cache,id=pnpm,target=/app/.pnpm-store,uid=1000 <<EOT
    set -e
    pnpm build
    rm -rf node_modules
    pnpm install --prod
EOT

FROM ${PROD_CONFIG_REF} AS base

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="plone-aurora" \
      org.label-schema.description="Plone Aurora frontend image" \
      org.label-schema.vendor="Plone Foundation"

COPY --from=builder /app/ /app/

# Install the pnpm version declared by the Cookieplone-generated package.json.
RUN corepack install
