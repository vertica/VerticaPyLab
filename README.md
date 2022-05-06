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
make vertica-install
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
or
```
bin/vsql -c "your-custom-query"
```
When you're done, this command will stop vertica
```
make vertica-stop
```
And if you want to start it back up without erasing it
```
make vertica-start
```
Or if you want to remove it and recover the disk space
```
make vertica-uninstall
```
admintools give you more control
```
bin/admintools --help
```
get ip of the container to use it on your notebook for instance
```
make get-ip
```

## VerticaLab
Build locally a jupyterlab image with verticapy installed. You can then use that image to create a container with  your notebooks already imported which makes demo very easy.

### Prerequisites
Set up Vertica nodes. If you do not have access to any, you can easily set up a single node vertica. See the section on [`Vertica`](#Vertica) for that.

### Quick Start
1. Build the image

    Put the notebooks/data you would like to import in your image respectively in notebooks/data folders.
    ```
    make verticalab-install
    ```
    If you do not want to use the default image name, set it on VERTICALAB_IMG
    ```
    export VERTICALAB_IMG=<your-custom-name>
    make verticalab-install
    ```
2. Start jupyterlab in docker
    ```
    make verticalab-start
    ```
    This will create a container using the default 8889 port. Then just open the displayed link in a browser.

    By default, verticalab notebooks will be isolated from the host machine and the only present files/dirs are those loaded at build time. However we offer the possibility to start from any directory of your choice. That way you will have access to the resources in that local directory and the changes you make will persist even after the container deletion. You just have to set VERTICALAB_PROJECT env var:

        - VERTICALAB_PROJECT: the localhost path that will be used as shared volume with verticalab docker container.

    So if you want to use your home directory as shared volume:
    ```
    make verticalab-start VERTICALAB_PROJECT=$HOME
    ```
    If you want to use another directory:
     ```
    make verticalab-start VERTICALAB_PROJECT=<your-dir>
    ```
4. Once you are done run the following command to stop the container.
    ```
    make verticalab-stop
    ```

### Run with your own settings

1. Create a configuration file
    ```
    make config
    ```
2. Edit settings in the configuration file
    ```
    vi config
    ```
3.  You can directly use the commands in bin/ if you add it to your PATH with
    ```
    eval $(make env)
    ```
    Or, put it in your bash_profile for future logins
    ```
    make env >> ~/.bash_profile
    ```
