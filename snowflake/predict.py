import argparse
import os
from os import path
import pandas as pd
import pickle
import random

parser = argparse.ArgumentParser(description="Predict churn probability for KKBox customers.")
parser.add_argument("--model", type=str, help="")
parser.add_argument("--features", type=str, help="")
parser.add_argument(
    "--output", metavar="DIR", default="./output", help="output directory"
)


def load_model(filename:str):
    model = pickle.load(open(filename), 'rb')
    return model

def make_predictions(model, data:pd.DataFrame, predCol:str):
    data[predCol] = model.predict(data)
    return data


def main():
    args = parser.parse_args()
    
    
    # Load model
    logistic_regression = load_model(args.model)
    
    # load features csv
    feats = pd.read_csv(args.features)
    
    predictions = make_predictions(logistic_regression, feats.drop(columns='msno'), 'churn_prediction')
    
    
    predictions = predictions[['msno', 'churn_prediction']]
    
    os.mkdirs(args.output, exists_ok=True)
    
    predictions.to_csv(path.join(args.output, "predictions.csv"))


if __name__ == "__main__":
    main()
