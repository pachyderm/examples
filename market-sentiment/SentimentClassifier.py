from pathlib import Path
import shutil
import os
import logging
import sys

# os.environ['SENTENCE_TRANSFORMERS_HOME'] = './.config'

from textblob import TextBlob
from transformers import AutoModelForSequenceClassification
 # If running container as non-root

import finbert.finbert as finbert
import finbert.utils as tools

import nltk

class SentimentClassifier(object):
    def __init__(self):
        self._classification_model_path = Path('./trained_model/')
        self._classification_model = AutoModelForSequenceClassification.from_pretrained(self._classification_model_path, cache_dir=None, num_labels=3)

    def predict(self, X, feature_names, meta):
        text = str(X)
        result = finbert.predict(text,self._classification_model)
        blob = TextBlob(text)
        result['textblob_prediction'] = [sentence.sentiment.polarity for sentence in blob.sentences]
        return {"text": text, "ndarray": result.logit.mean().tolist(), "names":["Positive", "Negative", "Neutral"]}