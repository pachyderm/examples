FROM jimmywhitaker/obj-det:dev0.07

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg libsm6 libxext6 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \

USER pipeline
WORKDIR /workdir/

COPY requirements.txt /workdir/
RUN pip install -r requirements.txt


COPY *.py /workdir/