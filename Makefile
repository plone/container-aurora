## Defensive settings for make:
#     https://tech.davis-hansson.com/p/make/
SHELL:=bash
.ONESHELL:
.SHELLFLAGS:=-xeu -o pipefail -O inherit_errexit -c
.SILENT:
.DELETE_ON_ERROR:
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules

# We like colors
# From: https://coderwall.com/p/izxssa/colored-makefile-for-golang-projects
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
YELLOW=`tput setaf 3`

# Current version
MAIN_IMAGE_NAME=plone/aurora
BASE_IMAGE_NAME=plone/aurora
AURORA_VERSION=$$(cat version.txt)
IMAGE_TAG=${AURORA_VERSION}

# Code Quality
# All tooling runs via docker: no local installs required. This repository
# carries no Python, so what there is to lint is Dockerfiles and workflow YAML,
# following plone.docker's legacy/Makefile.
DOCKER ?= docker
CURRENT_FOLDER=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DOCKERFILES=pnpm/Dockerfile pnpm/Dockerfile.builder pnpm/Dockerfile.dev pnpm/Dockerfile.prod
YAML_FILES=.github/workflows/*.yml .github/dependabot.yml



.PHONY: all
all: help

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: # This help message
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: lint
lint: ## Lint Dockerfiles (hadolint) and workflows (yaml well-formedness)
	@echo "$(GREEN)==> hadolint$(RESET)"
	set -e; for f in $(DOCKERFILES); do \
		echo "hadolint $$f"; \
		$(DOCKER) run --rm -v "$(CURRENT_FOLDER):/mnt:ro" -w /mnt \
			hadolint/hadolint hadolint "$$f"; \
	done
	@echo "$(GREEN)==> yaml$(RESET)"
	set -e; for f in $(YAML_FILES); do \
		echo "yaml check $$f"; \
		$(DOCKER) run --rm -v "$(CURRENT_FOLDER):/data:ro" \
			mikefarah/yq:4 -e 'true' "/data/$$f" >/dev/null; \
	done
	@echo "$(GREEN)==> lint OK$(RESET)"

# Build image
.PHONY: show-image
show-image: ## Print Version
	@echo "$(MAIN_IMAGE_NAME):$(IMAGE_TAG)"
	@echo "$(BASE_IMAGE_NAME)-(builder|dev|prod-config):$(IMAGE_TAG)"

.PHONY: image-builder
image-builder:  ## Build Base Image
	$(MAKE) -C "./pnpm/" image-builder

.PHONY: image-dev
image-dev:  ## Build Dev Image
	$(MAKE) -C "./pnpm/" image-dev

.PHONY: image-prod-config
image-prod-config:  ## Build Prod Image
	$(MAKE) -C "./pnpm/" image-prod-config

.PHONY: image-main
image-main:  ## Build main image
	$(MAKE) -C "./pnpm/" image-main

.PHONY: build-images
build-images:  ## Build Images
	@echo "Building $(BASE_IMAGE_NAME)-(builder|dev|prod-config):$(IMAGE_TAG) images"
	$(MAKE) image-builder
	$(MAKE) image-dev
	$(MAKE) image-prod-config
	@echo "Building $(MAIN_IMAGE_NAME):$(IMAGE_TAG)"
	$(MAKE) image-main

.PHONY: create-tag
create-tag: # Create a new tag using git
	@echo "Creating new tag $(AURORA_VERSION)"
	if git show-ref --tags v$(AURORA_VERSION) --quiet; then echo "$(AURORA_VERSION) already exists";else git tag -a v$(AURORA_VERSION) -m "Release $(AURORA_VERSION)" && git push && git push --tags;fi

.PHONY: remove-tag
remove-tag: # Remove an existing tag locally and remote
	@echo "Removing tag v$(TAG)"
	if git show-ref --tags v$(TAG) --quiet; then git tag -d v$(TAG) && git push origin :v$(TAG) && echo "$(TAG) removed";else echo "$(TAG) does not exist";fi

.PHONY: commit-and-release
commit-and-release: # Commit new version change and create tag
	@echo "Commiting changes"
	@git commit -am "Use Aurora $(AURORA_VERSION)"
	make create-tag
