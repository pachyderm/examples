FROM python:3.10.4


WORKDIR /app

RUN pip install cython spacy
RUN python -m spacy download en_core_web_lg

COPY requirements.txt /app
RUN pip install -r requirements.txt

RUN python -m nltk.downloader stopwords punkt

COPY data_prep.py /app
COPY split.py /app
COPY prep_files.py /app
COPY test.py /app
COPY UtilTextClassification.py /app
COPY config.cfg /app
COPY service.py /app

