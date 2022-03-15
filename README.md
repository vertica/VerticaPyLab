# Vertica Demo
Use Docker to start Vertica database on the local machine.  It will be a
single node vertica using the community license and thus has limitations, but
it should be enough to demonstrate many features of Vertica

## Prerequisites
* install docker
* download this vertica-demo project
* open up a bash prompt in this directory

## Quick Start
These commands will start vertica, and run a simple vsql query to test it.
```
bin/vertica-start
bin/vsql -c "select version();"
```
When you're done, this command will stop vertica
```
bin/vertica-stop
```
