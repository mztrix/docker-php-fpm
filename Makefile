# Makefile — mztrix/php-fpm
# Usage:
#   make publish                 # build & push amd64+arm64
#   make publish VERSION=1.2.3   # force the version
#   make test                    # local build (load) for your machine
#   make inspect                 # view pushed manifests
#   make clean-builder           # remove the builder

IMAGE        ?= mztrix/php-fpm

VERSION      ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo latest)
BUILDER      ?= mztrix-multiarch
REGISTRY     ?= docker.io

PLATFORMS := linux/amd64,linux/arm64

STAGE_TARGET ?= base

GIT_REV      := $(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)
SRC_EPOCH    := $(shell git log -1 --format=%ct 2>/dev/null || date +%s)
BUILD_DATE   := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
SOURCE_URL   := $(shell git config --get remote.origin.url 2>/dev/null || echo unknown)

OCI_LABELS = \
  org.opencontainers.image.title=$(IMAGE) \
  org.opencontainers.image.version=$(VERSION) \
  org.opencontainers.image.revision=$(GIT_REV) \
  org.opencontainers.image.created=$(BUILD_DATE) \
  org.opencontainers.image.source=$(SOURCE_URL)

LABEL_FLAGS := $(foreach label,$(OCI_LABELS),--label $(label))

.DEFAULT_GOAL := help

.PHONY: help login setup-builder test publish inspect clean-builder

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  login            Login to Docker registry ($(REGISTRY))"
	@echo "  setup-builder    Create/activate the builder '$(BUILDER)'"
	@echo "  test             Local build (LOAD) for the machine architecture"
	@echo "  publish          Buildx multi-arch & push: $(IMAGE):$(VERSION) + latest"
	@echo "  inspect          Display the pushed multi-arch manifest"
	@echo "  clean-builder    Remove the builder"
	@echo
	@echo "Useful variables:"
	@echo "  VERSION=x.y.z (default from git tag or 'main')"
	@echo "  STAGE_TARGET=base|debug|... (default: base)"

login:
	@docker login $(REGISTRY)

setup-builder:
	@docker buildx inspect $(BUILDER) >/dev/null 2>&1 || docker buildx create --name $(BUILDER) --use
	@docker buildx use $(BUILDER)
	@docker buildx inspect --bootstrap

test: setup-builder
	@echo ">> Test build local ($(IMAGE):$(VERSION)) [stage=$(STAGE_TARGET)]"
	DOCKER_BUILDKIT=1 docker buildx build \
		--no-cache \
		--target $(STAGE_TARGET) \
		--platform $(PLATFORMS) \
		--provenance=true \
		--sbom=true \
		--build-arg SOURCE_DATE_EPOCH=$(SRC_EPOCH) \
		$(LABEL_FLAGS) \
		--cache-to   type=inline,mode=max \
		--tag $(IMAGE):$(VERSION) \
		--load \
		.

publish: login setup-builder
	@echo ">> Build & push $(IMAGE):$(VERSION) [$(PLATFORMS)] stage=$(STAGE_TARGET)"
	DOCKER_BUILDKIT=1 docker buildx build \
		--no-cache \
		--target $(STAGE_TARGET) \
		--platform $(PLATFORMS) \
		--provenance=true \
		--sbom=true \
		--build-arg SOURCE_DATE_EPOCH=$(SRC_EPOCH) \
		$(LABEL_FLAGS) \
		--cache-to   type=inline,mode=max \
		--tag $(IMAGE):$(VERSION) \
		--push \
		.

inspect:
	@echo ">> Inspecting manifest for $(IMAGE):$(VERSION)"
	@docker buildx imagetools inspect $(IMAGE):$(VERSION)

clean-builder:
	@echo ">> Removing builder '$(BUILDER)' (if exists)"
	@docker buildx rm $(BUILDER) 2>/dev/null || true