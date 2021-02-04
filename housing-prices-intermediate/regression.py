import argparse
import os
from os import path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
from utils import plot_learning_curve

from sklearn.model_selection import ShuffleSplit
from sklearn import datasets, ensemble, linear_model
from sklearn.model_selection import learning_curve
from sklearn.model_selection import ShuffleSplit
from sklearn.model_selection import cross_val_score 
from sklearn.metrics import r2_score

parser = argparse.ArgumentParser(description="Structured data regression")
parser.add_argument("--input",
                    type=str,
                    help="directory with train.csv and test.csv")
parser.add_argument("--target-col",
                    type=str,
                    default="MEDV",
                    help="column with target values")
parser.add_argument("--output",
                    metavar="DIR",
                    default='./output',
                    help="output directory")

def load_data(input_csv, target_col):
    # Load the Boston housing dataset
    data = pd.read_csv(input_csv, header=0)
    targets = data[target_col]
    features = data.drop(target_col, axis = 1)
    return data, features, targets

def train_model(features, targets):
    # Train a Random Forest Regression model
    reg = ensemble.RandomForestRegressor(random_state=1)
    scores = cross_val_score(reg, features, targets, cv=10)
    print("Cross Val Score: {:2f} (+/- {:2f})".format(scores.mean(), scores.std() * 2))
    reg.fit(features,targets)
    
    return reg

def test_model(model, features, targets):
    # Train a Random Forest Regression model
    score = r2_score(model.predict(features), targets)

    return "Test Score: {:2f}".format(score)

def create_learning_curve(estimator, features, targets):
    plt.clf()

    title = "Learning Curves (Random Forest Regressor)"
    cv = ShuffleSplit(n_splits=10, test_size=0.2, random_state=0)
    plot_learning_curve(estimator, title, features, targets, 
                        ylim=(0.5, 1.01), cv=cv, n_jobs=4)

def main():
    args = parser.parse_args()
    input_dirs = []
    file_list = os.listdir(args.input)
    if 'train.csv' in file_list and 'test.csv' in file_list:
        input_dirs = [args.input]
    else:  # Directory of directories
        for root, dirs, files in os.walk(args.input):  
            for dir in dirs: 
                file_list = os.listdir(os.path.join(root, dir))
                if 'train.csv' in file_list and 'test.csv' in file_list:
                    input_dirs.append(os.path.join(root,dir))
    print("Datasets: {}".format(input_dirs))
    os.makedirs(args.output, exist_ok=True)

    for dir in input_dirs:
        experiment_name = os.path.basename(os.path.splitext(dir)[0])
        train_filename = os.path.join(dir,'train.csv')
        test_filename = os.path.join(dir,'test.csv')
        # Data loading 
        train_data, train_features, train_targets = load_data(train_filename, args.target_col)
        print("Training set has {} data points with {} variables each.".format(*train_data.shape))
        test_data, test_features, test_targets = load_data(test_filename, args.target_col)
        print("Testing set has {} data points with {} variables each.".format(*test_data.shape))

        reg = train_model(train_features, train_targets)
        test_results = test_model(reg, test_features, test_targets)
        create_learning_curve(reg, train_features, train_targets)
        plt.savefig(path.join(args.output, experiment_name + '_cv_reg_output.png'))

        print(test_results)

        # Save model and test score
        joblib.dump(reg, path.join(args.output, experiment_name + '_model.sav'))
        with open(path.join(args.output, experiment_name + '_test_results.txt'), "w") as text_file:
            text_file.write(test_results)

if __name__ == "__main__":
    main()