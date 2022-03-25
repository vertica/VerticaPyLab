FROM python:3.8

WORKDIR /project
VOLUME /project

RUN pip install \
    jupyterlab \
    verticapy[all]

COPY ./data /project/data
COPY ./notebooks /project/notebooks

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]