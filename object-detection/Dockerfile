FROM python:3.9

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg libsm6 libxext6 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

USER pipeline
WORKDIR /workdir/

COPY requirements.txt /workdir/
RUN pip install -r requirements.txt

# RUN pip install script_to_pipeline==0.2.0a0

COPY *.py /workdir/