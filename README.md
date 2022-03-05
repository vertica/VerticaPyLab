# Vertica Demo
Use Docker to start Vertica database on the local machine.  It will be a
single node vertica using the community license and thus has limitations, but
it should be enough to demonstrate many features of Vertica

## Prerequisites
* the docker service must be running
* the docker-compose extension must be installed

## Quick Start
These commands will grab this repo, start vertica, and run a simple vsql query to test it.
```
git clone https://github.com/vertica/vertica-demo.git
PATH=$PWD/vertica-demo/bin:$PATH
vertica-start
vsql -c "select version();"
```
