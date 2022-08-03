FROM python:3.9

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg libsm6 libxext6 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* 

WORKDIR /workdir/

COPY requirements.txt /workdir/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt


COPY *.py /workdir/