<p align="center">
  <img alt="Plone Logo" width="200" src="https://raw.githubusercontent.com/plone/plone-frontend/15.x/docs/logo.png">
</p>

<h1 align="center">plone/aurora</h1>

<div align="center">

[![Docker Image Version](https://img.shields.io/docker/v/plone/aurora?sort=semver)](https://hub.docker.com/r/plone/aurora)
[![Docker Image Size](https://img.shields.io/docker/image-size/plone/aurora?sort=semver)](https://hub.docker.com/r/plone/aurora)
[![GitHub stars](https://img.shields.io/github/stars/plone/container-aurora?style=flat-square)](https://github.com/plone/plone-aurora)
[![License](https://img.shields.io/github/license/plone/container-aurora)](./LICENSE.txt)

</div>

Official container images for the [Plone Aurora](https://github.com/plone/aurora) frontend.
This repository contains only the image build and release machinery; Aurora development
happens in `plone/aurora`.

The builder creates a clean frontend project with Cookieplone's `aurora_addon` template,
pins its Aurora checkout to the version in [`version.txt`](./version.txt), installs the
workspace, and builds the production application. Version pinning depends on
[cookieplone-templates#450](https://github.com/plone/cookieplone-templates/pull/450).
Until that PR merges, `Dockerfile.builder` defaults
`COOKIEPLONE_REPOSITORY_TAG` to `auroraversion`; change it to `next` after merge.

## Images

For Aurora `1.0.0-alpha.7`, the release workflow publishes:

- `plone/aurora:1.0.0-alpha.7` — production application
- `plone/aurora-builder:1.0.0-alpha.7` — generated project and build dependencies
- `plone/aurora-dev:1.0.0-alpha.7` — development entrypoint
- `plone/aurora-prod-config:1.0.0-alpha.7` — production runtime base

The workflow also creates compatible major, minor, and `latest` tags.

## Usage

Run Aurora against a Plone site at `http://localhost:8080/Plone`:

```shell
docker run --rm -p 3000:3000 \
  -e PLONE_API_PATH=http://host.docker.internal:8080/Plone \
  plone/aurora:latest
```

Build all images locally:

```shell
make build-images
```

Use `make help` for the individual builder, development, runtime, and main-image targets.

## Contributing

- [Issue tracker](https://github.com/plone/plone-aurora/issues)
- [Source code](https://github.com/plone/plone-aurora)

Do not commit directly to release branches. Open a pull request and have another
maintainer merge it.

## License

This project is licensed under GPLv2.
