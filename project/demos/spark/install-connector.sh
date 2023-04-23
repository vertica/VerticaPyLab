#!/bin/bash -e

# This script downloads the latest release of the Spark Connector from Maven. Since the latest release in Maven
# points to the Slim packaged Jar the script first scrapes the version from the GitHub releases page to specify
# the fully loaded Jar.
#

# bash -e (see line 1 above) will abort the script with any failure, and this
# trap command will print "BUILD FAILURE" if that happens.
trap ' tput setaf 1; echo "BUILD FAILURE"; tput sgr0; ' EXIT

if ! [[ -d /opt/spark ]] ; then
  echo "Installing Spark..."
  echo

  cd /opt
  curl --silent https://dlcdn.apache.org/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz | tar xzf -
  mv spark-3* spark
fi

version=$(curl --silent "https://api.github.com/repos/vertica/spark-connector/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'| sed 's/v//g')

echo "Installing Spark Connector..."
echo

mvn -U dependency:copy --quiet -Dartifact=com.vertica.spark:vertica-spark:$version -DoutputDirectory=/project/demos/spark 2> /dev/null

# remove the trap so we don't declare the build a failure
trap EXIT

tput setaf 2
echo "BUILD SUCCESS"
tput sgr0