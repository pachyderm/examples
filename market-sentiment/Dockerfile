FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-devel

WORKDIR /workdir/
COPY . .
RUN pip install -r requirements.txt

# Install nltk dependencies
RUN python3 -m nltk.downloader stopwords
RUN python3 -m nltk.downloader punkt
RUN python3 -m nltk.downloader wordnet
