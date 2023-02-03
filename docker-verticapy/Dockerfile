ARG PYTHON_VERSION="3.8-slim-buster"
FROM python:${PYTHON_VERSION}

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /project

COPY  requirements.txt requirements.txt
COPY ./data /project/data
COPY ./notebooks /project/notebooks
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
    wget

RUN apt-get upgrade -y
RUN apt-get clean
   
# Install python dependencies
RUN pip install --upgrade pip \
    pip install -r requirements.txt \
    && rm requirements.txt \
    && apt-get -y install curl dirmngr apt-transport-https lsb-release ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get -y install nodejs \
    && pip install /project/theme \
    && pip install /project/verticatools \
    && pip install /project/sql-editor \
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

# Install Spark
RUN wget https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz \
    && tar xvf spark-3* \
    && rm spark-3*.tgz \
    && mv spark-3* /opt/ \
    && mv /opt/spark-3* /opt/spark

ENV SPARK_HOME=/opt/spark

EXPOSE 8888

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]
