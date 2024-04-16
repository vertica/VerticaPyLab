# Copyright 2023 Open Text

ARG PYTHON_VERSION="3.9-slim-buster"
ARG SPARK_VERSION="3.3.2"
FROM python:${PYTHON_VERSION}

ENV PIP_NO_CACHE_DIR=true
ARG SPARK_VERSION

WORKDIR /project

COPY  requirements.txt requirements.txt
COPY ./bin /usr/bin/
COPY ./extensions-v2/ /project/

ENV SHELL "/bin/bash"
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -yqq \
      software-properties-common \
      gpg \
      libgdal-dev \
      g++ \
      git \
      ssh \
      graphviz \
      openjdk-11-jdk \
      scala \
      maven \
      wget \
      curl \
      dirmngr \
      apt-transport-https \
      lsb-release ca-certificates \
      && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
      && apt-get -y install nodejs \
      && pip install --upgrade pip \
      && pip install -r requirements.txt \
      && pip install /project/vertica_tools \
      && pip install PySpark==${SPARK_VERSION} PrettyTable \
      && rm -r /project/vertica_tools \
      && chmod 755 /usr/bin/admintools \
      && chmod 755 /usr/bin/vsql \
      && chmod 755 /usr/bin/run-vsql \
      && chmod 755 /usr/bin/run-admintools \
      && rm requirements.txt \
      && apt-get clean

EXPOSE 8888

ENV SPARK_HOME=/opt/spark
ENV SPARK_VERSION=${SPARK_VERSION}
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]