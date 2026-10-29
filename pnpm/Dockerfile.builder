# syntax=docker/dockerfile:1
FROM node:26-bookworm-slim

ARG AURORA_VERSION
# Pinned to a cookieplone-templates commit rather than to `main` so a given
# commit here always scaffolds the same project -- bump it deliberately.
# It must include the `sub/aurora_project` template (plone/cookieplone-templates#490);
# Node.js 26 needs plone/cookieplone-templates#485, whose pre-prompt check
# otherwise rejects it, and pnpm 12 comes from plone/cookieplone-templates#495.
# Switch back to a release tag once one includes all three.
ARG COOKIEPLONE_REPOSITORY_TAG=b12538cd442a86d1869caf641aea4c36f6902481
# 2.0.2 handles template names with `/` (plone/cookieplone#216); 2.0.0 exits
# with an error after generating `sub/aurora_project`.
ARG COOKIEPLONE_VERSION=2.0.2

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV COOKIEPLONE_REPOSITORY_TAG=${COOKIEPLONE_REPOSITORY_TAG}

LABEL maintainer="Plone Community <dev@plone.org>" \
      org.label-schema.name="aurora-builder" \
      org.label-schema.description="Plone Aurora builder image" \
      org.label-schema.vendor="Plone Foundation"

RUN <<EOT
    set -e
    apt-get update
    apt-get install -y --no-install-recommends python3 python3-pip build-essential git ca-certificates pipx
    rm -rf /var/lib/apt/lists/*
EOT

RUN <<EOT
    set -e
    cd /
    # A workspace with no add-on: projects built on this image copy in their own.
    pipx run --no-cache --spec cookieplone==$COOKIEPLONE_VERSION cookieplone sub/aurora_project --no-input \
      title="Plone Aurora" \
      author="Plone Community" \
      aurora_version=$AURORA_VERSION
    chown -R node:node /app
EOT

RUN npm i -g corepack@latest && corepack enable
USER node

WORKDIR /app

RUN --mount=type=cache,id=pnpm,target=/app/.pnpm-store,uid=1000 <<EOT
    set -e
    pnpm dlx mrs-developer missdev --no-config --fetch-https
    pnpm install
    make build-deps
EOT
