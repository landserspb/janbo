DOCKER_IMAGE=janbo-docker-image

.PHONY: help
help: ## - Show help message
	@printf "\033[32m\xE2\x9c\x93 usage: make [target]\n\n\033[0m"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: docker-pull
docker-pull:	## - docker pull latest images
	@printf "\033[32m\xE2\x9c\x93 docker pull latest images\n\033[0m"
	@docker pull golang:alpine

.PHONY: build
build:docker-pull	## - Build local docker image based on scratch
	@printf "\033[32m\xE2\x9c\x93 Build local docker image based on scratch\n\033[0m"
	$(eval BUILDER_IMAGE=$(shell docker inspect --format='{{index .RepoDigests 0}}' golang:alpine))
	@export DOCKER_CONTENT_TRUST=1
	@docker build --build-arg "BUILDER_IMAGE=$(BUILDER_IMAGE)" -t $(DOCKER_IMAGE) .

.PHONY: run
run:	## - Run local docker image based on scratch
	@printf "\033[32m\xE2\x9c\x93 Run docker image based on scratch\n\033[0m"
	@docker run -p 11130:11130 $(DOCKER_IMAGE):latest

.PHONY: deploy
deploy:	## - Deploy docker image from dockerhub to local minikube
	@printf "\033[32m\xE2\x9c\x93 Deploy docker image from dockerhub to local minikube\n\033[0m"
	@kubectl apply -f k8s/issuer.yml
	@kubectl wait --for=condition=Ready ClusterIssuer/letsencrypt
	@kubectl apply -f k8s/janbo-app.yml

.PHONY: delete
delete:	## - Delete app and minikube
	@printf "\033[32m\xE2\x9c\x93 Delete app and minikube\n\033[0m"
	@kubectl delete -f k8s/janbo-app.yml
	@kubectl delete -f k8s/issuer.yml
	@minikube stop
	@minikube delete

