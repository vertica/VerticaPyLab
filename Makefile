
VERTICALAB_IMG?=verticapy-jupyterlab
VERTICALAB_CONTAINER_NAME?=verticalab
VERTICALAB_PORT=8889
QUERY?=select version();
VERTICA_CONTAINER_NAME=vertica-demo
PYTHON_VERSION?=3.8-slim-buster
FROM_HOME?=false
export PYTHON_VERSION
export VERTICALAB_IMG
export FROM_HOME

ifeq ($(RANDOM_PORT), true)
VERTICALAB_PORT=-P
endif

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' "$(firstword $(MAKEFILE_LIST))"

# Keep a copy of the default conf
etc/vertica-demo.conf: etc/vertica-demo.conf.default
	cp etc/vertica-demo.conf.default etc/vertica-demo.conf

.PHONY: vertica-install
vertica-install: etc/vertica-demo.conf ## Create a vertica container and start the database.
	bin/vertica-install

.PHONY: vertica-stop
vertica-stop: ## Stop the vertica container.
	bin/vertica-stop

.PHONY: vertica-start
vertica-start: etc/vertica-demo.conf ## start/restart the vertica container.
	bin/vertica-start

.PHONY: vertica-uninstall
vertica-uninstall: ## Remove the vertica container.
	bin/vertica-uninstall

.PHONY: vsql
vsql:
	bin/vsql -c "$(QUERY)"

.PHONY: verticalab-start
verticalab-start: ## Start a jupyterlab
	bin/verticalab -c "$(VERTICALAB_CONTAINER_NAME)" -i "$(VERTICALAB_IMG)" -p "$(VERTICALAB_PORT)"

.PHONY: verticalab-install
verticalab-install: ## Build the image to use for the demo
	scripts/docker-build.sh

.PHONY: verticalab-stop
verticalab-stop: ## Shut down the jupyterlab server and remove the container
	docker stop "$(VERTICALAB_CONTAINER_NAME)"

.PHONY: get-ip
get-ip: ## Get the ip of the Vertica container
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$(VERTICA_CONTAINER_NAME)"
