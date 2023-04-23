ARG PYTHON_VERSION="3.9-slim-buster"
ARG GF_PORT=3000
FROM python:${PYTHON_VERSION}

ENV PIP_NO_CACHE_DIR=1
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ARG GF_PORT

WORKDIR /project

COPY  requirements.txt requirements.txt
COPY ./bin /usr/bin/
COPY ./extensions/ /project/

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
      lsb-release ca-certificates \
    # Set the port number for grafana extensions
    && sed -i s/PORT/${GF_PORT}/ /project/verticatools/src/index.ts

RUN apt-get upgrade -y
RUN apt-get clean

ENV SPARK_HOME=/opt/spark

# Install python dependencies
RUN    pip install --upgrade pip \
    && pip install -r requirements.txt \
    && rm requirements.txt \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get -y install nodejs

RUN    pip install /project/theme \
    && pip install /project/verticatools \
    && pip install PySpark \
    && pip install PrettyTable \
    && rm -r /project/verticatools \
    && rm -r /project/theme \
    && rm -r /project/sql-editor \
    && chmod 755 /usr/bin/admintools \
    && chmod 755 /usr/bin/vsql \
    && chmod 755 /usr/bin/run-vsql \
    && chmod 755 /usr/bin/run-admintools 
    # Uncomment the jupyter labextension line below to install jupyterlab-chart-editor
    # We are still having some problem to install it in some environments and we are still 
    # investigating.
    # && jupyter labextension install jupyterlab-chart-editor


EXPOSE 8888

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]
