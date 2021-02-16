import argparse
import os
from os import path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
from utils import load_data

from sklearn.model_selection import train_test_split

parser = argparse.ArgumentParser(description="Structured data regression")
parser.add_argument("--input",
                    type=str,
                    help="csv file with all examples")
parser.add_argument("--output",
                    metavar="DIR",
                    default='./output',
                    help="output directory")
parser.add_argument("--test-size",
                    type=float,
                    default=0.2,
                    help="percentage of data to use for testing (\"0.2\" = 20% used for testing, 80% for training")
parser.add_argument("--seed",
                    type=int,
                    default=42,
                    help="random seed")

def main():
    args = parser.parse_args()
    if os.path.isfile(args.input):
        input_files = [args.input]
    else:  # Directory
        for dirpath, dirs, files in os.walk(args.input):  
            input_files = [ os.path.join(dirpath, filename) for filename in files if filename.endswith('.csv') ]
    print("Datasets: {}".format(input_files))

    for filename in input_files:
        file_basename = os.path.basename(os.path.splitext(filename)[0])
        os.makedirs(os.path.join(args.output,file_basename), exist_ok=True)
        # Data loading 
        data = load_data(filename)
        train, test = train_test_split(data, test_size=args.test_size, random_state=args.seed)
        

        train.to_csv(os.path.join(args.output, file_basename, 'train.csv'), header=True, index=False)
        test.to_csv(os.path.join(args.output, file_basename, 'test.csv'), header=True, index=False)


if __name__ == "__main__":
    main()