FROM python:3.8.11

RUN apt-get update && apt-get install -y python3-opencv

RUN pip install requests

WORKDIR /workdir/
COPY requirements.txt .
COPY superb_import.py .

RUN pip install -r requirements.txt