FROM python:3.7-slim-buster
RUN apt-get update && apt-get -y update
RUN apt-get install -y build-essential python3-pip python3-dev
RUN pip3 -q install pip --upgrade

WORKDIR /workdir/

COPY requirements.txt /workdir/
RUN pip3 install -r requirements.txt

COPY *.py /workdir/