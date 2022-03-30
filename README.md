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
    If you do not want to use the default image name, set it on DEMO_IMG 
    ```
    export DEMO_IMG=<your-custom-name>
    make verticalab-install
    ```
2. Start jupyterlab in docker
    ```
    make verticalab-start
    ```
    This will create a container using the default 8889 port. Then just open the displayed link in a browser.
    
    By default, verticalab notebooks will be isolated from the host machine and the only present files/dirs are those loaded at build time. However we offer the possibility to start from the host $HOME directory. That way you will have access to all the resources and the changes you make will persist even after the container deletion. You just have to set FROM_HOME env var to true.
    ```
    make verticalab-start FROM_HOME=true
    ```
4. Once you are done run the following command to stop the container.
    ```
    make verticalab-stop
    ```

### Run with your own settings

1. With the Makefile

    A set of environment variables you can use to set the port, image, container... you want to use to run the demo.
2. With the scripts

    You can use to directly use the commands in bin/. In order to run them from anywhere on the system, you must:
    - Open the .bash_profile(MacOs)/.bashrc(linux) file in your home directory (for example, /Users/your-user-name/.bash_profile or /home/your-user-name/.bashrc) in a text editor.
    - Add export PATH="your-path:$PATH" to the last line of the file, where your-path is the path to the commands.
    - Save the .bash_profile/.bashrc file.
    - Restart your terminal
