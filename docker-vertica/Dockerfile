FROM vertica/vertica-k8s:latest

COPY ./bin/ldblink.so /tmp/
COPY dblink.cids /usr/local/etc/
COPY Makefile /home/dbadmin/
COPY odbc.ini /home/dbadmin/
COPY odbcinst.ini /home/dbadmin/


RUN sudo apt update \
    && sudo apt install -y \
    make \
    libc6 \
    libpq5 \
    odbcinst1debian2 \
    unixodbc \
    odbc-postgresql \
    unixodbc-dev \
    # install postgresql locally
    postgresql \ 
    postgresql-contrib \
    && sudo mv /home/dbadmin/odbc* /etc/
    