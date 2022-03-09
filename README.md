# Vertica Demo
Use Docker to start Vertica database on the local machine.  It will be a
single node vertica using the community license and thus has limitations, but
it should be enough to demonstrate many features of Vertica

## Prerequisites
* docker must be installed and running

## Quick Start
These commands will grab this repo, start vertica, and run a simple vsql query to test it.
```
git clone https://github.com/vertica/vertica-demo.git
cd vertica-demo
bin/vertica-start
bin/vsql -c "select version();"
```
