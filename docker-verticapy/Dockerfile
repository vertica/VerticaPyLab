ARG PYTHON_VERSION="3.8-slim-buster"
FROM python:${PYTHON_VERSION}

WORKDIR /project

COPY  requirements.txt requirements.txt
COPY ./data /project/data
COPY ./notebooks /project/notebooks
COPY ./bin /usr/bin/
COPY ./extensions/verticatools/ /project/verticatools

RUN apt-get update \
    && apt-get install -y \
    software-properties-common \
    gpg \
    libgdal-dev \
    g++ \
    ssh 
   
# Install python dependencies
RUN pip install --upgrade pip \
    pip install -r requirements.txt \
    && rm requirements.txt \
    && apt-get -y install curl dirmngr apt-transport-https lsb-release ca-certificates \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get -y install nodejs \
    && pip install /project/verticatools \
    && rm -r /project/verticatools \
    && chmod 755 /usr/bin/admintools \
    && chmod 755 /usr/bin/vsql 
    # Uncomment the jupyter labextension line below to install jupyterlab-chart-editor
    # We are still having some problem to install it in some environments and we are still 
    # investigating.
    # && jupyter labextension install jupyterlab-chart-editor
    

EXPOSE 8888

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]