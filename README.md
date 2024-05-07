# VerticaPyLab






https://github.com/vertica/VerticaPyLab/assets/46414488/8bc3e2e2-6718-402d-9195-92a2b8f15efa








This git repo includes scripts that let you create and run a single-node Vertica database 
on a local machine. It uses the Community Edition (CE) license (limited to  of 1TB of data).

The Docker image verticapylab is a custom JupyterLab environment. 
verticapylab provides extensions for autocompletion, graphics, options to run
vsql or admintools, etc. and uses the lastest VerticaPy version.


## Quickstart

Note: Docker is a prerequisite. Docker version 18.09 and higher.

1. Clone this repository.
   ```
   git clone https://github.com/vertica/VerticaPyLab.git
   ```
2. Open a terminal in the `VerticaPyLab` directory.
3. Start all services(Vertica, Grafana, VerticaPyLab)
    ```
    make all
    ```
4. Open the displayed link in a browser.
6. Stop all services

   ```
   make stop
   ```
7. Clean up your environment and delete all images
   ```
   make uninstall
   ```

If you want to connect from a remote then you need to change the binding address before the ``make all`` command. 
Edit the file: etc/VerticaPyLab.conf.default

Change the variable to the following value:

VERTICAPYLAB_BIND_ADDRESS=0.0.0.0

Once Vertica is running, you can also explore the database with [Grafana](#grafana). Go to [Grafana](#grafana) section to see how to start it.

## VerticaPy Development

In order to use VerticaPyLab for development of VerticaPy, the following changes can be made to create a VerticaPyLab image that does not have VerticaPy installed:

1. ``cd`` into VerticaPyLab/docker-verticapy. Edit the ``requirements.txt`` file and remove "verticapy" from the list.
2. Then ``cd`` into VerticaPyLab/etc and edit ``VerticaPyLab.conf.default``. The ``VERTICAPYLAB_IMG_VERSION=latest`` can be changed to any other tag except for "latest". For example: ``VERTICAPYLAB_IMG_VERSION="no_verticapy"``.
3. Then build the image by running ``make verticapylab-build`` in the terminal.
4. Lastly start-up the container using ``make verticapylab-start``.
5. Note that you also need to start Vertica separately by running ``make vertica-start``.

Once VerticaPyLab is up and running. You can copy/clone the latest VerticaPy repo into the ``VerticaPyLab/project/data`` directory.

And then it can be installed using the below command from within the Jupyter Notebook or Terminal while you are inside the VerticaPy directory:

```
pip install .
```

If you want to make changes and test them, then simple uninstall VerticaPy using:

```
pip uninstall -y verticapy
```

Then re-install it.

Note: For your changes to take effect, you must refresh the kernel after the new installation.

## Testing the latest features [Beta version]

This allows the user to build the image locally and try out the latest features that verticapy and verticapylab have. 

Currently this includes

- Connection Page
- QueryProfiler Interface

To get started build the image locally using:

```
TEST_MODE=YES make verticapylab-start
```

After that you can use the Connect tile to connect to your Vertica server.

But if you need to test something locally, you can install and start up a local image of Vertica CE using:

```
make veritca-start
```


## Vertica CE Container

1. To create and start a new Vertica database:
    ```
    make vertica-start
    make vsql
    ```

2.  To start vsql:
    ```
    make vsql
    ```

3.  To start vsql and run a query:
    ```
    make vsql QUERY="'your-custom-query'"
    ```
    or
    ```
    bin/vsql -c "your-custom-query"
    ```

4.  To register Vertica and upgrade the license limit to 1TB:
    ```
    make register
    ```

4.  To stop Vertica:
    ```
    make vertica-stop
    ```

5.  To restart Vertica without erasing the database:
    ```
    make vertica-start
    ```

6.  To delete the existing database:
    ```
    make vertica-uninstall
    ```

7.  To run admintools:
    ```
    bin/admintools --help
    ```

8.  To get the IP address of the container for use with external tools (e.g. a Jupyter notebook):
    ```
    make get-ip
    ```

## VerticaPyLab

You can build a JupyterLab image with VerticaPy installed, and then use that image to create a container that imports your existing notebooks.

### Prerequisites

A Vertica database. To get a simple single-node Vertica CE database, see the [Vertica quickstart guide](#Vertica-CE-Container).

### Quickstart - VerticaPyLab

1. Build and start JupyterLab in docker. This creates a container on port 8889 (default):
    ```
    make verticapylab-start
    ```
    Note: If the container already exists, this command will simply display the link to access verticapylab

2. Open the displayed link in a browser.
3. To stop the container:
    ```
    make verticapylab-stop
    ```

6. To uninstall verticapylab(delete docker image and dependencies):
    ```
    make verticapylab-uninstall
    ```

### Shared Volumes

verticapylab mounts <b>project</b> directory into the container. That allows you to import your files(notebooks, data, etc...) and also save your work on your local machine after the container is deleted.

## Spark

A Docker environment can be installed and ran to facilitate the included Jupyter examples that use the Spark-Connector alongside Vertica.

1. Follow the steps above to set up Vertica and VerticaPyLab. Running `make all` will start both.
2. From there you can run `make spark-start` to start the Spark environment.

This will create a Docker group with three containers for Spark, a Spark-Worker, and HDFS.
Inside of VerticaPyLab you can find the Spark examples within `demos/spark/`.  

The examples contain:

* The basic read/write with Spark Connector
* A complex arrays read/write with Spark Connector
* Linear Regression examples using:
    * Apache Spark
    * VerticaPy
    * Direct Vertica (SQL Execution)

Each example is annotated and walks you through step-by-step through various Spark jobs. Simply execute each cell by hitting `Shift-Enter`. 

## Grafana

Grafana is an open-source observability platform for visualizing metrics, logs, and traces collected from your applications. VerticaPyLab has two extensions on the jupyterlab launcher to access Grafana once it is installed:

- Grafana: Opens a new tab containing a Grafana Explorer for running sql queries.
- Performance: Opens a new tab containing a performance dashboard to visualize CPU usage, Memory usage, SQL statements, etc..

Here are the commands to install, stop and uninstall Grafana: 

- Start Grafana container:
  `make  grafana-start` and open `http://localhost:3000`
- Stop Grafana: 
  `make grafana-stop`
- Remove the grafana container and its associated images:
  `make grafana-uninstall`

Grafana is pre-configured to connect to the Vertica container(if running) but you can also use it to connect to your own data sources but you must configure it yourself.

## Prometheus

Prometheus a monitoring and alerting system that is very popular with cloud native deployments. It collects time series events for different machines, called targets.
In version 23.3.0, Vertica introduced in-database metrics. Vertica is already very rich in metrics with the various system and DC tables that it offers, but now you can get them cheaply with Prometheus in-database metrics.

We provide a few commands that can help you set up Prometheus to fetch metrics from your remote cluster nodes or from the CE vertica container installed with VerticaPyLab:
- Configure Prometheus. if you do not have your own db, Prometheus is configured to use the single node CE database:
    
  Edit prometheus.yml and add your own section to tell Prometheus how to access your nodes.
- Start Prometheus container:

  `make prom-start` and open `http://localhost:9090`
  
- Stop Prometheus container:

  `make prom-stop`
- Delete the prometheus container and its associated images:

  `make prom-uninstall`

Once installed, Prometheus can be used as a DataSource by [Grafana](#grafana)


## Contributing
For a short guide on contribution standards, see [CONTRIBUTING.md](CONTRIBUTING.md)

## Getting started on Windows

See the [Windows guide](windows/README.md).


