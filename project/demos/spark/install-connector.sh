#!/usr/bin/env bash

# This script downloads the latest release of the Spark Connector from Maven. Since the latest release in Maven
# points to the Slim packaged Jar the script first scrapes the version from the GitHub releases page to specify
# the fully loaded Jar.

version=$(curl --silent "https://api.github.com/repos/vertica/spark-connector/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'| sed 's/v//g')

echo "Installing..."
echo
mvn -U dependency:copy --quiet -Dartifact=com.vertica.spark:vertica-spark:$version -DoutputDirectory=/project/demos/spark 2> /dev/null && echo -e "\e[32mBUILD SUCCESS" || echo -e "\e[31mBUILD FAILURE"

exit 0
