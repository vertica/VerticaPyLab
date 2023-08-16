# VerticaPyLab





https://github.com/vertica/VerticaPyLab/assets/46414488/cab03af1-ba0e-4495-b5c1-1da2c1a7a3a9





This git repo includes scripts that let you create and run a single-node Vertica database 
on a local machine. It uses the Community Edition (CE) license (limited to  of 1TB of data).

The Docker image verticapylab is a custom JupyterLab environment. 
verticapylab provides extensions for autocompletion, graphics, options to run
vsql or admintools, etc. and uses the lastest VerticaPy version.


## Quickstart

1. Clone this repository.
2. Open a terminal in the `VerticaPyLab` directory.
3. Start all services(Vertica, Grafana, VerticaPyLab)
    ```
    make all
    ```
4. Open the displayed link in a browser.
5. Stop all services
   ```
   make stop
   ```
6. Clean up your environment and delete all images
   ```
   make uninstall
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

Grafana is an open-source observability platform for visualizing metrics, logs, and traces collected from your applications. When Verticalab is installed, a grafana container is created and connected to the single node database.  Two extensions are available on the jupyterlab launcher to make use of it:

- Grafana: Opens a new tab containing a Grafana Explorer for running sql queries.
- Performance: Opens a new tab containing a performance dashboard to visualize CPU usage, Memory usage, SQL statements, etc..

## Contributing
For a short guide on contribution standards, see [CONTRIBUTING.md](CONTRIBUTING.md)

## Getting started on Windows

See the [Windows guide](windows/README.md).
