# Makefile for vertica-demo
# Run "make help" for instructions on installing and starting the demo

# Release Engineering:
# This is the version of the dockerhub image for the Jupyter Notebook that
# is built/cached from this code base.  
# Demo Users :
#   1) check out a stable released version.  
#   2) "make verticalab-install"
# Developers of Vertica-Demo : 
#   1) "git checkout -b <branch name>" to create a git branch and checkout
#   2) set the version number in etc/vertica-demo.conf (VERTICALAB_IMG_VERSION=v0.1)
#   3) make the desired changes verticalab demos
#   4) build with "make verticalab-build"
#   5) start with "make verticalab-start" and open the URL provided
#   6) test changes and cycle back to step 3 if needed
#   7) submit changes with git commit, git push, create PR, get approval, merge to main
# Release process :
#   1) Use the above developer steps to set the desired version
#   2) create a release in github with the tag set to the version (i.e., v0.1)
#   3) create a release in docker hub with "VERTICALAB_LATEST=1 make verticalab-push"

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
	if [[ -r etc/vertica-demo.conf ]]; then \
	  echo DEFAULTS HAVE CHANGED.  Please update etc/vertica-demo.conf.; \
	  diff etc/vertica-demo.conf etc/vertica-demo.conf.default; \
	  exit 1; \
	fi
	cp -n etc/vertica-demo.conf.default etc/vertica-demo.conf
	source etc/vertica-demo.conf; \
	docker container rm "$$VERTICA_CONTAINER_NAME" >/dev/null 2>&1 || true

.PHONY: vertica-install
vertica-install: etc/vertica-demo.conf ## Create a vertica container and start the database.
	@bin/vertica-install

.PHONY: vertica-stop
vertica-stop: ## Stop and delete the vertica container.
	@bin/vertica-stop

.PHONY: vertica-start
vertica-start: etc/vertica-demo.conf ## start/restart the vertica container.
	@source etc/vertica-demo.conf; \
	if (($$(docker ps -a --no-trunc -q -f NAME="$$VERTICA_CONTAINER_NAME" | wc -l)==0)); then \
	    $(MAKE) vertica-install; \
	else \
	    bin/vertica-start; \
	fi

.PHONY: vertica-uninstall
vertica-uninstall: etc/vertica-demo.conf ## Remove the vertica container and associated images.
	@source etc/vertica-demo.conf; \
	bin/vertica-uninstall; \
	docker image rm "$$VERTICA_DOCKER_IMAGE"

.PHONY: vsql
vsql: ## Run a basic sanity test (optional -DQUERY="select 'whatever')
	@bin/vsql -c "$(QUERY)"

.PHONY: verticalab-start
verticalab-start: etc/vertica-demo.conf ## Start a jupyterlab
	@source etc/vertica-demo.conf; \
	if (($$(docker ps --no-trunc -q -f NAME="$$VERTICALAB_CONTAINER_NAME" | wc -l)==0)); then \
	    if [[ -z $$(docker image ls -q "vertica/$$VERTICALAB_IMG:$$VERTICALAB_IMG_VERSION" 2>&1) ]]; then \
	      $(MAKE) verticalab-install || exit 1; \
	    fi; \
	    docker container rm "$$VERTICALAB_CONTAINER_NAME" >/dev/null 2>&1; \
	    bin/verticalab; \
	else \
	  echo "$$VERTICALAB_CONTAINER_NAME is already running"; \
	fi

# this builds the image from the python base image for the purposes of
# testing it locally before pushing it to dockerhub
.PHONY: verticalab-build
verticalab-build: etc/vertica-demo.conf
	@source etc/vertica-demo.conf; \
	if [[ $$VERTICALAB_IMG_VERSION == latest ]] ; then \
	  echo "Set a version number for VERTICALAB_IMG_VERSION in etc/vertica-demo.conf"; \
	  exit 1; \
	fi; \
	bin/verticalab-build

# this builds images for multiple platforms and pushes them to docker hub
# run "docker login" first to supply credentials that are authorized to update
# the vertica docker hub images.
.PHONY: verticalab-push
verticalab-push: etc/vertica-demo.conf
	@source etc/vertica-demo.conf; \
	if [[ $$VERTICALAB_IMG_VERSION == latest ]] ; then \
	  echo "Set a version number for VERTICALAB_IMG_VERSION in etc/vertica-demo.conf"; \
	  exit 1; \
	fi; \
	declare -a SECOND_TAG=(); \
	if (($$VERTICALAB_LATEST)); then \
	  SECOND_TAG+=(-t "vertica/$$VERTICALAB_IMG:latest"); \
	fi; \
	docker context create mycontext; \
	docker buildx create mycontext --name mybuilder; \
	docker buildx inspect --bootstrap; \
	docker buildx build --platform=linux/arm64,linux/amd64 --build-arg PYTHON_VERSION=$$PYTHON_VERSION -t "vertica/$$VERTICALAB_IMG:$$VERTICALAB_IMG_VERSION" "$${SECOND_TAG[@]}" /Users/bronson/src/vertica-demo/docker-verticapy/ --push

.PHONY: verticalab-install
verticalab-install: etc/vertica-demo.conf ## Install the image to use for the demo
	@source etc/vertica-demo.conf; \
	docker pull "vertica/$$VERTICALAB_IMG:$$VERTICALAB_IMG_VERSION";

.PHONY: verticalab-stop
verticalab-stop: ## Shut down the jupyterlab server and remove the container
	@source etc/vertica-demo.conf; \
	docker stop "$$VERTICALAB_CONTAINER_NAME"

.PHONY: verticalab-uninstall
verticalab-uninstall: ## Remove the verticalab container and associated images.
	@source etc/vertica-demo.conf; \
	docker stop "$$VERTICALAB_CONTAINER_NAME" >/dev/null 2>&1; \
	docker image rm "vertica/$$VERTICALAB_IMG"; \
	docker image rm "python:$$PYTHON_VERSION"

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
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$$VERTICA_CONTAINER_NAME"

.PHONY: test
test: ## suite of tests to make sure everything is working
	@source etc/vertica-demo.conf; \
	docker exec -i "$$VERTICALAB_CONTAINER_NAME" vsql -c "select version();"
