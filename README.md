# Vertica Demo

## Vertica
Use Docker to start Vertica database on the local machine.  It will be a
single node vertica using the community license and thus has limitations, but
it should be enough to demonstrate many features of Vertica

### Prerequisites
* install docker
* download this vertica-demo project
* open up a bash prompt in this directory

### Quick Start
These commands will create a vertica database and start it
```
make vertica-setup
make vsql
```
Run a simple vsql query to test it.
```
make vsql
```
or 
```
make vsql QUERY="'your-custom-query'"
```
When you're done, this command will stop vertica
```
make vertica-stop
```
And if you want to start it back up without erasing it
```
make vertica-restart
```
admintools give you more control
```
bin/admintools --help
```
get ip of the container to use it on your notebook for instance
```
make get-ip
```

## Vertica Notebook
Build locally a jupyterlab image with verticapy installed. You can then use that image to create a container with  your notebooks already imported which makes demo very easy.

### Prerequisites
Set up Vertica nodes. If you do not have access to any, you can easily set up a single node vertica. See the section on [`Vertica`](#Vertica) for that.

### Quick Start
1. Build the image

    Put the notebooks/data you would like to import in your image respectively in notebooks/data folders.
    ```
    make docker-build-notebook
    ```
    If you do not want to use the default image name, set it on DEMO_IMG 
    ```
    export DEMO_IMG=<your-custom-name>
    make docker-build-notebook
    ```
2. Push the image in a repo

    If you are not interested in pushing this image you can skip this step.
    ```
    make docker-push-notebook
    ```
3. Start jupyterlab in docker
    ```
    make vertica-notebook
    ```
    This will create a container using the default 8888 port. Then just open the link in a browser.
4. Once you are done open a new session and run the following command to stop the container.
    ```
    make docker-stop-notebook
    ```

### Run with a random port

If port 8888 is not available, you can use a random port just by setting RANDOM_PORT to true
```
export RANDOM_PORT=true
make vertica-notebook
```
To see what port has been chosen, open another session and run
```
make get-port
```
You will get something like this 0.0.0.0:xxxx. Open the jupyterlab link and replace 8888 by that port.