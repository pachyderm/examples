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

    # def init_metadata(self):
    #     meta = {
    #         "name": "Market Sentiment",
    #         "versions": ["my-model-version-01"],
    #         "platform": "seldon",
    #         "inputs": [
    #             {
    #                 "ndarray": "Sentence" }
    #         ],
    #         "outputs": [{"sentiment_scores": {"names": ["Positive", "Negative", "Neutral"], "shape": [3]}}],
    #         "custom": {
    #             "author": "pachyderm"
    #         }
    #     }

    #     return meta

    def class_names(self):
        return ["Positive", "Negative", "Neutral"]

    def predict(self, X, feature_names, meta):
        text = str(X)
        result = finbert.predict(text,self._classification_model)
        blob = TextBlob(text)
        result['textblob_prediction'] = [sentence.sentiment.polarity for sentence in blob.sentences]
        return result.logit.mean()

    # def class_names(self):
    #     return ["Positive", "Negative", "Neutral"]

    # def metrics(self):
    #     return [
    #         {"type": "COUNTER", "key": "mycounter", "value": 1}, # a counter which will increase by the given value
    #         {"type": "GAUGE", "key": "mygauge", "value": 100},   # a gauge which will be set to given value
    #         {"type": "TIMER", "key": "mytimer", "value": 20.2},  # a timer which will add sum and count metrics - assumed millisecs
    #     ]
