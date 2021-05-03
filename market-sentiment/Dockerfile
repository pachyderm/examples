FROM pytorch/pytorch:1.6.0-cuda10.1-cudnn7-runtime

WORKDIR /workdir/
COPY . .
RUN pip install -r requirements.txt

# Install nltk dependencies
RUN python3 -m nltk.downloader stopwords
RUN python3 -m nltk.downloader punkt
RUN python3 -m nltk.downloader wordnet