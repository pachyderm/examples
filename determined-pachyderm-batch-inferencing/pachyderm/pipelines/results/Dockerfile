FROM ubuntu:22.04

RUN apt-get update -qqy && apt-get install -qqy \
  python3 \
  python3-pip \
  && pip install \
    duckdb \
    pandas \
    scikit-image \
    plotly \
    kaleido

COPY results.py /results.py
