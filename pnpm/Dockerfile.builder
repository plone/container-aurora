# syntax=docker/dockerfile:1
FROM node:24-bookworm-slim

ARG AURORA_VERSION
# Pinned to a cookieplone-templates commit rather than to `main` so a given
# commit here always scaffolds the same project -- bump it deliberately.
# Aurora 1.0.0-alpha.16 needs 48d2e63 (build @plone/icons and @plone/quanta in
# build-deps) and #475 (use @plone/icons for the SVG types), both newer than the
# 20260914.1 release; switch back to a release tag once one includes them.
ARG COOKIEPLONE_REPOSITORY_TAG=99c2201962371b182499a0d71f45ed878da0c33d
ARG COOKIEPLONE_VERSION=2.0.0

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

# Drop the scaffolded `plone-aurora` add-on: it only exists to bootstrap the
# workspace. Left in place, it stays a `packages/*` workspace project, and a
# project built on this image copies in its own add-on and `pnpm-lock.yaml`,
# which has no entry for it, so the frozen-lockfile install fails. Unregister it
# from the root `package.json` and `registry.config.ts`, then refresh the lockfile.
RUN --mount=type=cache,id=pnpm,target=/app/.pnpm-store,uid=1000 <<EOT
    set -e
    rm -rf packages/plone-aurora
    python3 -c "import json; data = json.load(open('package.json')); data['dependencies'].pop('plone-aurora'); json.dump(data, open('package.json', 'w'), indent=2)"
    printf "import { addons } from '@plone/aurora/registry.config';\n\nexport { addons };\n" > registry.config.ts
    pnpm install
EOT
