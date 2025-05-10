# Makefile for mztrix/php-fpm multi-arch build & push

# Override via environment:
IMAGE_NAME ?= mztrix/php-fpm
VERSION    ?= 1.0
PLATFORMS  ?= linux/amd64,linux/arm64,linux/arm/v7
BUILDER    ?= multiarch

.DEFAULT_GOAL := help

.PHONY: help login setup-builder publish clean-builder

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  login          Login to Docker Hub"
	@echo "  setup-builder  Create & use '$(BUILDER)' buildx builder"
	@echo "  publish        Build & push '$(IMAGE_NAME):$(VERSION)' + 'latest'"
	@echo "  clean-builder  Remove '$(BUILDER)' builder (if exists)"

login:
	docker login

setup-builder:
	docker buildx inspect $(BUILDER) >/dev/null 2>&1 || \
		docker buildx create --name $(BUILDER) --use
	@docker buildx inspect --bootstrap

publish: login setup-builder
	@echo "Building & pushing $(IMAGE_NAME):$(VERSION) + latest on $(PLATFORMS)"
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(IMAGE_NAME):$(VERSION) \
		--tag $(IMAGE_NAME):latest \
		--push \
		.

clean-builder:
	@echo "Removing buildx builder '$(BUILDER)' (if exists)"
	docker buildx rm $(BUILDER) || true