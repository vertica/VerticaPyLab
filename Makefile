# Makefile for vertica-demo

QUERY?=select version();
SHELL:=/bin/bash

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' "$(firstword $(MAKEFILE_LIST))"

# Keep a copy of the default conf
.PHONY: config
config: etc/vertica-demo.conf ## Edit the configuration file
	@echo "Editing configuration settings in $$PWD/etc/vertica-demo.conf"
	@if [[ -x $$VISUAL ]] ; then \
	  "$$VISUAL" "$$PWD/etc/vertica-demo.conf"; \
	elif [[ -x $$EDITOR ]] ; then \
	  "$$EDITOR" "$$PWD/etc/vertica-demo.conf"; \
	else \
	  echo "Could not find editor $$VISUAL"; \
	fi

.PHONY: env
env: ## set up an environment by running "eval $(make env)"
	@echo 'PATH="'$$PWD'/bin:$$PATH"'

all: ## quickstart: install and run all containers
	$(MAKE) vertica-start
	$(MAKE) verticalab-start

# create new conf file or update timestamp if exists
etc/vertica-demo.conf: etc/vertica-demo.conf.default
	@cp -n etc/vertica-demo.conf.default etc/vertica-demo.conf || touch etc/vertica-demo.conf

.PHONY: vertica-install
vertica-install: etc/vertica-demo.conf ## Create a vertica container and start the database.
	@bin/vertica-install

.PHONY: vertica-stop
vertica-stop: ## Stop the vertica container.
	@bin/vertica-stop

.PHONY: vertica-start
vertica-start: etc/vertica-demo.conf ## start/restart the vertica container.
	@source etc/vertica-demo.conf; \
	if (($$(docker ps -a --no-trunc -q -f NAME="$${VERTICA_CONTAINER_NAME:-vertica-demo}" | wc -l)==0)); then \
	    $(MAKE) vertica-install; \
	else \
	    bin/vertica-start; \
	fi

.PHONY: vertica-uninstall
vertica-uninstall: ## Remove the vertica container and associated images.
	@bin/vertica-uninstall; \
	source etc/vertica-demo.conf; \
	docker image rm "$${VERTICA_DOCKER_IMAGE:=vertica/vertica-k8s}"

.PHONY: vsql
vsql: ## Run a basic sanity test (optional -DQUERY="select 'whatever')
	@bin/vsql -c "$(QUERY)"

.PHONY: verticalab-start
verticalab-start: etc/vertica-demo.conf ## Start a jupyterlab
	@if (($$(docker ps -a --no-trunc -q -f NAME="$${VERTICALAB_CONTAINER_NAME:-verticalab}" | wc -l)==0)); then \
	    $(MAKE) verticalab-install; \
	fi
	@bin/verticalab;

.PHONY: verticalab-install
verticalab-install: etc/vertica-demo.conf ## Build the image to use for the demo
	@bin/verticalab-install

.PHONY: verticalab-stop
verticalab-stop: ## Shut down the jupyterlab server and remove the container
	@source etc/vertica-demo.conf; \
	docker stop "$${VERTICALAB_CONTAINER_NAME:-verticalab}"

.PHONY: verticalab-uninstall
verticalab-uninstall: ## Remove the verticalab container and associated images.
	@source etc/vertica-demo.conf; \
	docker stop "$${VERTICALAB_CONTAINER_NAME:-verticalab}" >/dev/null 2>&1; \
	docker image rm "$${VERTICALAB_IMG:=verticapy-jupyterlab}"; \
	docker image rm "python:$${PYTHON_VERSION:-3.8-slim-buster}"

# aliases for convenience
start: all

stop: verticalab-stop vertica-stop

uninstall: verticalab-uninstall vertica-uninstall

.PHONY: reguster
register: etc/vertica-demo.conf ## Register vertica to increase data limit to 1TB
	@bin/vertica-register

.PHONY: get-ip
get-ip: etc/vertica-demo.conf ## Get the ip of the Vertica container
	@source etc/vertica-demo.conf; \
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$${VERTICA_CONTAINER_NAME:-vertica-demo}"

.PHONY: test
test: ## suite of tests to make sure everything is working
	@source etc/vertica-demo.conf; \
	docker exec -i "$${VERTICALAB_CONTAINER_NAME:-verticalab}" vsql -c "select version();"
