FROM python:3.9

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg libsm6 libxext6 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

USER pipeline
RUN pip install opencv-python==4.5.5.64 matplotlib==3.5.1 'lightning-flash[image]' 'icevision' 

RUN pip install script_to_pipeline==0.2.0a0

WORKDIR /workdir/

COPY *.py /workdir/