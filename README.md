# Vertica Demo
Use Docker to start Vertica database on the local machine.  It will be a
single node vertica using the community license and thus has limitations, but
it should be enough to demonstrate many features of Vertica

## Prerequisites
* install docker
* download this vertica-demo project
* open up a bash prompt in this directory

## Quick Start
These commands will create a vertica database and start it
```
bin/vertica-setup
bin/vsql -c "select version();"
```
Run a simple vsql query to test it.
```
bin/vsql -c "select version();"
```
When you're done, this command will stop vertica
```
bin/vertica-stop
```
And if you want to start it back up without erasing it
```
bin/vertica-restart
```
admintools give you more control
```
bin/admintools --help
```
