import Algorithmia
from Algorithmia import ADK
import torch as th
import python_pachyderm
import json


from pathlib import Path
import shutil
import os
import logging
import sys
import hashlib

from textblob import TextBlob
from transformers import AutoModelForSequenceClassification
import finbert.finbert as finbert
import finbert.utils as tools
from numpy import argmax

import nltk

MODEL_VERSION = 'master'

def load():
    output = {}
    output['client'] = Algorithmia.client()
    
    output['pach_client'] = python_pachyderm.Client(host=os.environ["PACH_HOST"],
                                        port=os.environ["PACH_PORT"],
                                        auth_token=os.environ["PACH_AUTH"],
                                        tls=True)
    
    # Download the model and config
    Path("/tmp/trained_model").mkdir(parents=True, exist_ok=True)
    with open("/tmp/trained_model/config.json", "wb") as f:
        f.write(output['pach_client'].get_file(("train_model", MODEL_VERSION), "config.json").read())
        
    with open("/tmp/trained_model/pytorch_model.bin", "wb") as f:
        f.write(output['pach_client'].get_file(("train_model", MODEL_VERSION), "pytorch_model.bin").read())
    
    
    output['classification_model_path'] = Path("/tmp/trained_model/")
    output['classification_model'] = AutoModelForSequenceClassification.from_pretrained(
        output['classification_model_path'], cache_dir=None, num_labels=3
    )
    
    nltk.download('stopwords')
    nltk.download('punkt')
    nltk.download('wordnet')

    return output
    
def format_prediction(pred):
    text = pred["text"]
    score_idx = argmax(pred["ndarray"])
    score = pred["ndarray"][score_idx]
    sentiment_class = pred["names"][score_idx]
    prediction= {
                "data": {"text": text},
                "predictions": [
                    {
                        "result": [
                            {
                                "value": {"choices": [sentiment_class]},
                                "from_name": "sentiment",
                                "to_name": "text",
                                "type": "choices",
                            }
                        ],
                        "score": score,
                        "model_version": MODEL_VERSION,
                    }
                ],
            }
    return prediction

def apply(input, output):
  if isinstance(input, dict):
    text = str(input['text'])
    result = finbert.predict(text,output['classification_model'])
    blob = TextBlob(text)
    result['textblob_prediction'] = [sentence.sentiment.polarity for sentence in blob.sentences]
    resp = {"text": text, "ndarray": result.logit.mean().tolist(), "names":["Positive", "Negative", "Neutral"]}
    
    md5 = hashlib.md5()
    md5.update(text.encode())
    filename = str(md5.hexdigest()) + '.json'
    
    with output['pach_client'].commit("raw_data", "master") as commit:
        output['pach_client'].put_file_bytes(commit, filename, json.dumps(format_prediction(resp)).encode('utf-8'))
    
    return resp
  else:
      raise Exception('input must be a json object.')

# This code turns your library code into an algorithm that can run on the platform.
# If you intend to use loading operations, remember to pass a `load` function as a second variable.
algo = Algorithmia.ADK(apply, load)
# The 'serve()' function actually starts the algorithm, you can follow along in the source code
# to see how everything works.
algo.init()