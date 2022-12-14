import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from supervised.automl import AutoML

import argparse
import os

parser = argparse.ArgumentParser(description="Structured data regression")
parser.add_argument("--input",
                    type=str,
                    help="csv file with all examples")
parser.add_argument("--target-col",
                    type=str,
                    help="column with target values")
parser.add_argument("--mode",
                    type=str,
                    default='Explain',
                    help="mode")
parser.add_argument("--random_state",
                    type=int,
                    default=42,
                    help="random seed")
parser.add_argument("--output",
                    metavar="DIR",
                    default='./output',
                    help="output directory")

def load_data(input_csv, target_col):
    # Load the data
    data = pd.read_csv(input_csv, header=0)
    targets = data[target_col]
    features = data.drop(target_col, axis = 1)
    
    # Create data splits
    X_train, X_test, y_train, y_test = train_test_split(
        features,
        targets,
        test_size=0.25,
        random_state=123,
    )
    return X_train, X_test, y_train, y_test


def main():
    args = parser.parse_args()
    if os.path.isfile(args.input):
        input_files = [args.input]
    else:  # Directory
        for dirpath, dirs, files in os.walk(args.input):  
            input_files = [ os.path.join(dirpath, filename) for filename in files if filename.endswith('.csv') ]
    print("Datasets: {}".format(input_files))
    os.makedirs(args.output, exist_ok=True)

    for filename in input_files:

        experiment_name = os.path.basename(os.path.splitext(filename)[0])
        # Data loading and Exploration
        X_train, X_test, y_train, y_test = load_data(filename, args.target_col)
       
        # Fit model
        automl = AutoML(total_time_limit=60*60, results_path=args.output) # 1 hour
        automl.fit(X_train, y_train)
        
        # compute the MSE on test data
        predictions = automl.predict_all(X_test)
        print("Test MSE:", mean_squared_error(y_test, predictions))


if __name__ == "__main__":
    main()