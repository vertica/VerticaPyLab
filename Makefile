# Makefile for VerticaPyLab
# Copyright 2023 Open Text
#
# Run "make help" for instructions on installing and starting the services

# Release Engineering:
# This is the version of the dockerhub image for the Jupyter Notebook that
# is built/cached from this code base.
# Users :
#   1) check out a stable released version.
#   2) "make all"
# Developers of VerticaPyLab :
#   1) "git checkout -b <branch name>" to create a git branch and checkout
#   2) set the version number in etc/VerticaPyLab.conf (VERTICAPYLAB_IMG_VERSION=anything)
#   3) make the desired changes
#   4) build with "make verticapylab-build"
#   5) start with "make verticapylab-start" and open the URL provided
#   6) test changes and cycle back to step 3 if needed
#   7) submit changes with git commit, git push, create PR, get approval, merge to main
# Release process :
#   1) create a git branch and checkout (git checkout -b Release_v0.0.0)
#   2) set the version number in etc/VerticaPyLab.conf* (VERTICAPYLAB_IMG_VERSION=v0.0.0)
#   3) create a release in github with the tag set to the version
#   4) docker login
#   5) create a release in docker hub with "make verticapylab-push"
#   6) move the latest release to this version with "make verticapylab-push-latest"
# Spark installation :
#   1) follow the steps above to set up Vertica and VERTICAPYLAB.
#   2) run "make spark-install" to install and start the Spark environment.

QUERY?=select version();
SHELL:=/bin/bash
SPARK_ENV_FILE:=docker-spark/docker/.env
GF_ENV_FILE:=docker-grafana/.env
export VERSION=v0.2.0

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' "$(firstword $(MAKEFILE_LIST))"

# Keep a copy of the default conf
.PHONY: config
config: etc/VerticaPyLab.conf ## Edit the configuration file
	@echo "Editing configuration settings in $$PWD/etc/VerticaPyLab.conf"
	@if [[ -x $$VISUAL ]] ; then \
	  "$$VISUAL" "$$PWD/etc/VerticaPyLab.conf"; \
	elif [[ -x $$EDITOR ]] ; then \
	  "$$EDITOR" "$$PWD/etc/VerticaPyLab.conf"; \
	else \
	  echo "Could not find editor $$VISUAL"; \
	fi

.PHONY: env
env: ## set up an environment by running "eval $(make env)"
	@echo 'PATH="'$$PWD'/bin:$$PATH"'

all: ## quickstart: install and run all containers
	$(MAKE) vertica-start
	$(MAKE) grafana-start
	$(MAKE) verticapylab-start

# create new conf file or update timestamp if exists
etc/VerticaPyLab.conf: etc/VerticaPyLab.conf.default
	@# If VerticaPyLab.conf.default changes in a breaking
	@# way, update this version number
	@ conf_version="VerticaPyLab configuration file V1"; \
	if [[ -r $@ ]]; then \
	  if ! grep "$$conf_version" "$@" >/dev/null 2>&1; then \
	    echo "WARNING: default configuration changed.  Please review etc/VerticaPyLab.conf" >&2; \
	  fi; \
	else \
	  ( \
	    echo '#!/bin/bash'; \
	    echo; \
	    echo "# $$conf_version"; \
	    echo; \
	    echo '# Keep this at the top so everything below will override the defaults'; \
	    echo 'source $$BASH_SOURCE.default'; \
	    echo; \
	    perl -pE 'next if m,#!/bin/bash,; s/^([^#])/#$$1/' etc/VerticaPyLab.conf.default; \
	  ) > $@; \
	fi

.PHONY: vertica-install
vertica-install: etc/VerticaPyLab.conf ## Create a vertica container and start the database.
	@bin/vertica-install

.PHONY: vertica-stop
vertica-stop: ## Stop and delete the vertica container.
	@bin/vertica-stop

.PHONY: vertica-start
vertica-start: etc/VerticaPyLab.conf ## start/restart the vertica container.
	@source etc/VerticaPyLab.conf; \
	if [[ -z $$VERTICA_EULA ]] || [[ -z $$(docker ps -a --no-trunc -q -f NAME="$$VERTICA_CONTAINER_NAME") ]]; then \
	    $(MAKE) vertica-install; \
	else \
	    bin/vertica-start; \
	fi

.PHONY: vertica-uninstall
vertica-uninstall: etc/VerticaPyLab.conf ## Remove the vertica container and associated images.
	@source etc/VerticaPyLab.conf; \
	bin/vertica-uninstall; \
	docker image rm "$$VERTICA_DOCKER_IMAGE"

.PHONY: vsql
vsql: ## Run a basic sanity test (optional -DQUERY="select 'whatever')
	@bin/vsql -c "$(QUERY)"

.PHONY: verticapylab-start
verticapylab-start: etc/VerticaPyLab.conf ## Start a jupyterlab
	@source etc/VerticaPyLab.conf; \
	if [[ $$(tr '[:lower:]' '[:upper:]'<<< $${TEST_MODE}) == "YES" ]] ; then \
		VERTICAPYLAB_IMG_VERSION=$(VERSION); \
	fi; \
	if (($$(docker ps --no-trunc -q -f NAME="$$VERTICAPYLAB_CONTAINER_NAME" | wc -l)==0)); then \
	    if [[ -z $$(docker image ls -q "opentext/$$VERTICAPYLAB_IMG:$$VERTICAPYLAB_IMG_VERSION" 2>&1) ]]; then \
		  if [[ $$(tr '[:lower:]' '[:upper:]'<<< $${TEST_MODE}) == "YES" ]] ; then \
		    echo "Building image opentext/$$VERTICAPYLAB_IMG:$$VERTICAPYLAB_IMG_VERSION"; \
		    TEST_MODE=yes $(MAKE) verticapylab-build; \
		  else \
		    $(MAKE) verticapylab-install || exit 1; \
		  fi; \
	    fi; \
	    docker container rm "$$VERTICAPYLAB_CONTAINER_NAME" >/dev/null 2>&1; \
	fi; \
	bin/verticapylab;

# this builds the image from the python base image for the purposes of
# testing it locally before pushing it to dockerhub
.PHONY: verticapylab-build
verticapylab-build: etc/VerticaPyLab.conf
	bin/verticapylab-build

# this builds images for multiple platforms and pushes them to docker hub
# run "docker login" first to supply credentials that are authorized to update
# the vertica docker hub images.
.PHONY: verticapylab-push
verticapylab-push: etc/VerticaPyLab.conf
	source etc/VerticaPyLab.conf; \
	if [[ $$VERTICAPYLAB_IMG_VERSION == latest ]] ; then \
	  echo "Set a version number for VERTICAPYLAB_IMG_VERSION in etc/VerticaPyLab.conf"; \
	  exit 1; \
	fi; \
	docker context create mycontext; \
	docker buildx create mycontext --name mybuilder --use; \
	docker buildx inspect --bootstrap; \
	docker buildx build --platform=linux/arm64,linux/amd64 --build-arg PYTHON_VERSION=$$PYTHON_VERSION --build-arg GF_PORT=$$GF_PORT -t "opentext/$$VERTICAPYLAB_IMG:$$VERTICAPYLAB_IMG_VERSION" $$PWD/docker-verticapy/ --push

verticapylab-push-latest: etc/VerticaPyLab.conf
	@# This should use the cache from the last buildx and just push the new tag.
	source etc/VerticaPyLab.conf; \
	docker buildx build --platform=linux/arm64,linux/amd64 --build-arg PYTHON_VERSION=$$PYTHON_VERSION --build-arg GF_PORT=$$GF_PORT -t "opentext/$$VERTICAPYLAB_IMG:latest" $$PWD/docker-verticapy/ --push

.PHONY: verticapylab-install
verticapylab-install: etc/VerticaPyLab.conf ## Download the image to use
	@source etc/VerticaPyLab.conf; \
	docker pull "opentext/$$VERTICAPYLAB_IMG:$$VERTICAPYLAB_IMG_VERSION";

.PHONY: verticapylab-stop
verticapylab-stop: ## Shut down the jupyterlab server and remove the container
	@source etc/VerticaPyLab.conf; \
	docker stop "$$VERTICAPYLAB_CONTAINER_NAME"

.PHONY: verticapylab-uninstall
verticapylab-uninstall: ## Remove the verticapylab container and associated images.
	@source etc/VerticaPyLab.conf; \
	if [[ $$(tr '[:lower:]' '[:upper:]'<<< $${TEST_MODE}) == "YES" ]] ; then \
		VERTICAPYLAB_IMG_VERSION=$(VERSION); \
	fi; \
	docker stop "$$VERTICAPYLAB_CONTAINER_NAME" >/dev/null 2>&1; \
	docker image rm "opentext/$$VERTICAPYLAB_IMG:$$VERTICAPYLAB_IMG_VERSION"

# these set of commands handle the Spark Docker environment
$(SPARK_ENV_FILE): etc/VerticaPyLab.conf
	@source etc/VerticaPyLab.conf; \
	echo "SPARK_INSTALL=$$SPARK_VERSION" > $(SPARK_ENV_FILE)

# spark-start will build the images and start them
.PHONY: spark-install
spark-install: $(SPARK_ENV_FILE)
	cd docker-spark/docker && docker-compose up -d

.PHONY: spark-start
spark-start: spark-install

.PHONY: spark-stop
spark-stop:
	cd docker-spark/docker && docker-compose stop

.PHONY: spark-uninstall
spark-uninstall: spark-stop
	cd docker-spark/docker && docker-compose rm -f && \
	docker image rm docker-spark && \
	docker image rm docker-spark-worker && \
	docker image rm mdouchement/hdfs  

# A set of command to handle grafana
$(GF_ENV_FILE): ## Set environment variables to run grafana with docker-compose
	@bin/grafana

.PHONY: grafana-install
grafana-install: $(GF_ENV_FILE) ## Create grafana container
	cd docker-grafana && docker-compose up -d

.PHONY: grafana-start
grafana-start: grafana-install ## Start grafana container

.PHONY: grafana-stop
grafana-stop: ## Stop grafana
	cd docker-grafana && docker-compose stop

.PHONY: grafana-uninstall
grafana-uninstall: grafana-stop## Remove the grafana container and its associated images
	@source etc/VerticaPyLab.conf; \
	cd docker-grafana && docker-compose rm -f; \
	docker image rm grafana/grafana-enterprise:$$GF_VERSION

# A set of commands to handle Prometheus
.PHONY: prom-start
prom-start: etc/VerticaPyLab.conf ## Start prometheus container
	cd docker-prometheus && docker-compose up -d

.PHONY: prom-stop
prom-stop: ## Stop prometheus
	cd docker-prometheus && docker-compose stop

.PHONY: prom-uninstall
prom-uninstall: prom-stop ## Remove the prometheus container and its associated images
	@source etc/VerticaPyLab.conf; \
	cd docker-prometheus && docker-compose rm -f; \
	docker image rm prom/prometheus:$$PROM_VERSION

# aliases for convenience
start: all

stop: verticapylab-stop grafana-stop vertica-stop

uninstall: verticapylab-uninstall grafana-uninstall vertica-uninstall

.PHONY: reguster
register: etc/VerticaPyLab.conf ## Register vertica to increase data limit to 1TB
	@bin/vertica-register

.PHONY: get-ip
get-ip: etc/VerticaPyLab.conf ## Get the ip of the Vertica container
	@source etc/VerticaPyLab.conf; \
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$$VERTICA_CONTAINER_NAME"

.PHONY: test
test: ## suite of tests to make sure everything is working
	@source etc/VerticaPyLab.conf; \
	docker exec -i "$$VERTICAPYLAB_CONTAINER_NAME" vsql -c "select version();"; \
	docker exec -i grafana ls /var/lib/grafana/plugins | grep -q vertica-grafana-datasource || exit 1; \
    docker exec -i grafana ls /var/lib/grafana/dashboards | grep -q dashboard.json || exit 1; \
    docker exec -i grafana cat /etc/grafana/provisioning/datasources/sample.yaml | grep -q "url: $$VERTICA_CONTAINER_NAME:$$VERTICA_PORT" || exit 1