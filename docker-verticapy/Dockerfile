FROM python:3.8-slim-buster

WORKDIR /project

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt \
    && rm requirements.txt

COPY ./data /project/data
COPY ./notebooks /project/notebooks

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]