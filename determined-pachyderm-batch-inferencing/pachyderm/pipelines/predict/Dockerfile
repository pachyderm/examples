FROM ubuntu:22.04

RUN apt-get update -qqy && apt-get install -qqy \
  python3 \
  python3-pip \
  && pip install \
    numpy \
    matplotlib \
    scikit-image \
    Pillow \
    python_pachyderm \
    determined \
  && pip install \
    torch \
    torchvision \
    --index-url https://download.pytorch.org/whl/cpu

COPY predict.py /predict.py
