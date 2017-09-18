VERSION ?= latest

.PHONY: images
images:
	@./src/build-services.sh $(VERSION)

.PHONY: up
up:
	@docker-compose up
