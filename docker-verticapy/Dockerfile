ARG PYTHON_VERSION="3.8-slim-buster"
FROM python:${PYTHON_VERSION}

WORKDIR /project

RUN apt-get update
RUN apt-get install -y software-properties-common gpg libgdal-dev g++

COPY requirements.txt requirements.txt
RUN pip install --upgrade pip \
    pip install -r requirements.txt \
    && rm requirements.txt

COPY ./data /project/data
COPY ./notebooks /project/notebooks

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]
