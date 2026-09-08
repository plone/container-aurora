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
AURORA_VERSION=$$(cat ../version.txt)
IMAGE_TAG=${AURORA_VERSION}
IMAGE_SUFFIX=

# Full base-image references handed to Dockerfile.dev and Dockerfile. CI
# overrides these with `<image>@sha256:<manifest digest>` so a derived image is
# always built on the base produced in the same run; locally they resolve to the
# tags `make image-builder` / `make image-prod-config` just wrote.
BUILDER_REF=$(BASE_IMAGE_NAME)-builder:$(IMAGE_TAG)$(IMAGE_SUFFIX)
PROD_CONFIG_REF=$(BASE_IMAGE_NAME)-prod-config:$(IMAGE_TAG)$(IMAGE_SUFFIX)

.PHONY: all
all: help

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: # This help message
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Build image
.PHONY: show-image
show-image: ## Print Version
	@echo "$(MAIN_IMAGE_NAME):$(IMAGE_TAG)$(IMAGE_SUFFIX)"
	@echo "$(BASE_IMAGE_NAME)-(builder|dev|prod-config):$(IMAGE_TAG)$(IMAGE_SUFFIX)"

.PHONY: image-builder
image-builder:  ## Build Base Image
	@echo "Building $(BASE_IMAGE_NAME)-builder:$(IMAGE_TAG)$(IMAGE_SUFFIX)"
	@docker buildx build . --build-arg AURORA_VERSION=${AURORA_VERSION} -t $(BASE_IMAGE_NAME)-builder:$(IMAGE_TAG)$(IMAGE_SUFFIX) -f Dockerfile.builder --load

.PHONY: image-dev
image-dev:  ## Build Dev Image
	@echo "Building $(BASE_IMAGE_NAME)-dev:$(IMAGE_TAG)$(IMAGE_SUFFIX)"
	@docker buildx build . --build-arg BUILDER_REF=$(BUILDER_REF) -t $(BASE_IMAGE_NAME)-dev:$(IMAGE_TAG)$(IMAGE_SUFFIX) -f Dockerfile.dev --load

.PHONY: image-prod-config
image-prod-config:  ## Build Prod Image
	@echo "Building $(BASE_IMAGE_NAME)-prod-config:$(IMAGE_TAG)$(IMAGE_SUFFIX)"
	@docker buildx build . -t $(BASE_IMAGE_NAME)-prod-config:$(IMAGE_TAG)$(IMAGE_SUFFIX) -f Dockerfile.prod --load

.PHONY: image-main
image-main:  ## Build main image
	@echo "Building $(MAIN_IMAGE_NAME):$(IMAGE_TAG)$(IMAGE_SUFFIX)"
	@docker buildx build . --build-arg BUILDER_REF=$(BUILDER_REF) --build-arg PROD_CONFIG_REF=$(PROD_CONFIG_REF) -t $(MAIN_IMAGE_NAME):$(IMAGE_TAG)$(IMAGE_SUFFIX) -f Dockerfile --load
