import argparse
import pandas as pd
import pickle
from sklearn.linear_model import LogisticRegression
from os import path

parser = argparse.ArgumentParser(description="Train a churn classification model on KKBox features")
parser.add_argument("--dataset", type=str, help="")
parser.add_argument(
    "--output", metavar="DIR", default="./output", help="output directory"
)


def churn_classifier(X_train, y_train, clf):
    """
    Params:
    X_train: training data features
    y_train: training data lables
    clf: classifier object

    Returns:
    Fitted model
    """
    clf.fit(X_train, y_train)
    return clf


def save_classifier(clf, location: str):
    pickle.dump(clf, open(location, "wb"))


def main():
    args = parser.parse_args()
    # reading train csv
    grouped_training = pd.read_csv(args.dataset)
    
    # TODO: fix feature 'amt_per_day' NaN issue
    grouped_training = grouped_training.dropna()

    X_train = grouped_training.drop(labels=["is_churn", "msno"], axis=1)
    Y_train = grouped_training["is_churn"]

    # LogisticRegression
    classifier = LogisticRegression(solver="liblinear", max_iter=1000)
    churn_classifier(X_train, Y_train, classifier)
    save_classifier(classifier, path.join(args.output, "logistic_regression.sav"))


if __name__ == "__main__":
    main()
