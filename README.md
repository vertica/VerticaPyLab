# Vertica Demo

This Docker image lets you create and run a single-node Vertica database 
on a local machine. It uses the Community Edition (CE) license (limited to  of 1TB of data).

The Docker image also includes VerticaLab, a custom JupyterLab environment. 
VerticaLab provides extensions for autocompletion, graphics, options to run
vsql or admintools, etc. and uses the lastest VerticaPy version.

<div align="center">
    <img src="VerticaLabDiagram.png" alt="VerticaLab" height="40%" width="40%" />
</div>

## Quickstart

1. Clone this repository.
2. Open a terminal in the `vertica-demo` directory.
3. Build and start vertica and verticalab
    ```
    make all
    ```
4. Open the displayed link in a browser.

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

## VerticaLab

You can build a JupyterLab image with VerticaPy installed, and then use that image to create a container that imports your existing notebooks.

### Prerequisites

A Vertica database. To get a simple single-node Vertica CE database, see the [Vertica quickstart guide](#Vertica-CE-Container).

### Quickstart - VerticaLab

1. Move the notebooks you want to import into the `vertica-demo/docker-verticapy/notebooks` directory.
2. Move the data you want to import into the `vertica-demo/docker-verticapy/data` directory.
3. (Optional) To use a different image name, set the `VERTICALAB_IMG` environment variable:
    ```
    export VERTICALAB_IMG=<your-custom-name>
    ```

4. Build and start JupyterLab in docker. This creates a container on port 8889 (default):
    ```
    make verticalab-start
    ```

5. Open the displayed link in a browser.
6. To stop the container:
    ```
    make verticalab-stop
    ```

6. To uninstall the container:
    ```
    make verticalab-uninstall
    ```

## Spark

A Docker environment can be installed and ran to facilitate the included Jupyter examples that use the Spark-Connector alongside Vertica.

1. Follow the steps above to set up Vertica Demo and VerticaLab. Running `make all` will start both.
2. From there you can run `make spark-install` to install and start the Spark environment.

This will create a Docker group with three containers for Spark, a Spark-Worker, and HDFS.
Inside of VerticaLab you can find the Spark examples within `notebooks/spark/`.  

The examples contain:

* The basic read/write with Spark Connector
* A complex arrays read/write with Spark Connector
* Linear Regression examples using:
    * Apache Spark
    * VerticaPy
    * Direct Vertica (SQL Execution)

Each example is annotated and walks you through step-by-step through various Spark jobs. Simply execute each cell by hitting `Shift-Enter`. 

### Shared Volumes

verticalab allows you to import your files(notebooks, data, etc...) and also save your work on your local machine. For that, create a new directory named <b>workspace</b> in the root directory of the project (vertica-demo/workspace). If you do not do it, verticalab will do it for you during the first installation. Put all the files you would like to use in verticalab inside workspace before you start verticalab. That directory will be mounted into verticalab so when it starts, you will see a workspace directory there too.
If when working on verticalab there are some files you would like to keep after the container deletion, just put them inside workspace(on verticalab) and you will find them in your local workspace directory.

### Additional Configuration

1. Create a configuration file:

    ```
    make config
    ```

2. Edit settings in the configuration file:

    ```
    vi config
    ```
    
### Setting PATH

If you want to run commands in `bin/` directly, add it to your PATH:

```
eval $(make env)
```
Or, to put it in your bash_profile for future logins:

```
make env >> ~/.bash_profile
```

## Contributing
For a short guide on contribution standards, see [CONTRIBUTING.md](CONTRIBUTING.md)

## Getting started on Windows

See the [Windows guide](windows/README.md).
