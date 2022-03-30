
DEMO_IMG?=verticapy-jupyterlab
DEMO_CONTAINER_NAME?=verticapy-demo
PORT=8889
QUERY?="select version();"
VERTICA_CONTAINER_NAME=vertica-demo
PYTHON_VERSION?=3.8-slim-buster
FROM_HOME?=false
export PYTHON_VERSION
export DEMO_IMG
export FROM_HOME

ifeq ($(RANDOM_PORT), true)
PORT=-P
endif

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(firstword $(MAKEFILE_LIST))

.PHONY: vertica-setup
vertica-setup: ## Create a vertica container and start the database.
	bin/vertica-setup

.PHONY: vertica-stop
vertica-stop: ## Stop the vertica container.
	bin/vertica-stop

.PHONY: vertica-restart
vertica-restart: ## Stop the vertica container.
	bin/vertica-restart

.PHONY: vsql
vsql:
	bin/vsql -c $(QUERY)

.PHONY: verticalab-start
verticalab-start: ## Start a jupyterlab
	bin/verticalab -c $(DEMO_CONTAINER_NAME) -i $(DEMO_IMG) -p $(PORT) 

.PHONY: verticalab-install
verticalab-install: ## Build the image to use for the demo
	scripts/docker-build.sh

.PHONY: verticalab-stop
verticalab-stop: ## Shut down the jupyterlab server and remove the container
	docker stop $(DEMO_CONTAINER_NAME)

.PHONY: get-ip
get-ip: ## Get the ip of the Vertica container
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(VERTICA_CONTAINER_NAME)
