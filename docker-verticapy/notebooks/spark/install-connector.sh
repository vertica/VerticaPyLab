#!/usr/bin/env bash

version=$(curl --silent "https://api.github.com/repos/vertica/spark-connector/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'| sed 's/v//g')

mvn -U dependency:copy -Dartifact=com.vertica.spark:vertica-spark:$version -DoutputDirectory=/project/notebooks/spark 2> /dev/null

