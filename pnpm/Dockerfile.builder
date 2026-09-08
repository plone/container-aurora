# syntax=docker/dockerfile:1
FROM node:24-bookworm-slim

ARG AURORA_VERSION
# The aurora_addon template lives only on cookieplone-templates' `next` branch:
# it was added by #450, which merged into `next` (not `main`) on 2026-09-05, and
# main...next is heavily diverged. Pinned to a commit rather than to `next` so a
# given commit here always scaffolds the same project -- bump it deliberately.
ARG COOKIEPLONE_REPOSITORY_TAG=662183adfd8f2271ed2c6c65419171737723430a
ARG COOKIEPLONE_VERSION=2.0.0b3

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
    pipx run --no-cache --spec cookieplone==$COOKIEPLONE_VERSION cookieplone aurora_addon --no-input \
      title="Plone Aurora" \
      frontend_addon_name=plone-aurora \
      project_slug=plone-aurora \
      description="Plone Aurora frontend" \
      author="Plone Community" \
      email=dev@plone.org \
      github_organization=plone \
      npm_package_name=plone-aurora \
      aurora_version=$AURORA_VERSION
    mv /plone-aurora /app
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
