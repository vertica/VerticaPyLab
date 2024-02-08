# Copyright 2023 Open Text

ARG PYTHON_VERSION="3.9-slim-buster"
ARG GF_PORT=3000
ARG SPARK_VERSION="3.3.2"
FROM python:${PYTHON_VERSION}

ENV PIP_NO_CACHE_DIR=1
ARG GF_PORT
ARG SPARK_VERSION

WORKDIR /project

COPY  requirements.txt requirements.txt

RUN apt-get update \
    && apt-get install -y \
      software-properties-common \
      gpg \
      libgdal-dev \
      g++ \
      ssh \
      graphviz \
      openjdk-11-jdk \
      scala \
      maven \
      wget \
      curl \
      dirmngr \
      apt-transport-https \
      lsb-release ca-certificates

RUN apt-get upgrade -y
RUN apt-get clean

ENV SPARK_HOME=/opt/spark
ENV SPARK_VERSION=${SPARK_VERSION}

# Install python dependencies
RUN    pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install PySpark==${SPARK_VERSION} \
    && pip install PrettyTable \
    && rm requirements.txt \
    # Install nodejs
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get -y install nodejs


EXPOSE 8888

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]
