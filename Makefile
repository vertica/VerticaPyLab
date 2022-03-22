
DEMO_IMG?=vertica-notebook
DEMO_CONTAINER_NAME?=demo
PORT=-p 8888:8888
RANDOM_PORT?=false
QUERY?="select version();"
VERTICA_CONTAINER_NAME=vertica-demo

ifeq ($(RANDOM_PORT), true)
PORT=-P
endif



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


.PHONY: vertica-notebook
vertica-notebook: ## Start a jupyterlab
	docker run --rm -it $(PORT) --name $(DEMO_CONTAINER_NAME) $(DEMO_IMG)

.PHONY: docker-build-notebook
docker-build-notebook:
	docker build -t $(DEMO_IMG) docker-verticapy/

.PHONY: docker-push-notebook
docker-push-notebook:
	docker push $(DEMO_IMG)

.PHONY: docker-stop-notebook
docker-stop-notebook:
	docker stop $(DEMO_CONTAINER_NAME)

.PHONY: get-port
get-port:
	docker port $(DEMO_CONTAINER_NAME) 8888

.PHONY: get-ip
get-ip:
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(VERTICA_CONTAINER_NAME)



