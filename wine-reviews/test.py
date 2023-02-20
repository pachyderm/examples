import spacy
import os
import argparse
import pandas as pd
from UtilTextClassification import (
    evaluate,
    load_data,
    df2list,
    write_classification_report,
)
from spacy.tokens import DocBin


def test_model(nlp, test_list):
    text, label = list(zip(*test_list))
    return evaluate(nlp, text, label, label_names=None)


def main(model_dir, input_dir, output_dir):
    print("Loading Model from", model_dir)
    nlp = spacy.load(model_dir)
    print("Loading test data")
    test_filename = os.path.join(input_dir, "test.spacy")
    #test_data, test_features, test_targets = load_data(test_filename, "variety")
    #print(
    #    "Testing set has {} data points with {} variables each.".format(
    #        *test_data.shape
    #    )
    #)
    test_data = DocBin().from_disk(test_filename)
    nlp.evaluate(test_data)
    #test_y_df = pd.get_dummies(test_targets)
    #test_ls = df2list(test_data["description"], test_y_df)
    #f1_score, class_report = test_model(nlp, test_ls)
    #print(f1_score)
    #textfile = open(os.path.join(output_dir,"f1_score.txt"), "w")
    #textfile.write(f1_score)
    #textfile.close()
    #write_classification_report(class_report, output_dir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--model_dir",
        type=str,
        help="directory with model to test",
    )
    parser.add_argument(
        "--input_dir",
        type=str,
        help="directory with test.csv test data",
    )
    parser.add_argument(
        "--output_dir",
        metavar="DIR",
        default="./model",
        help="output directory",
    )
    args = parser.parse_args()
    main(model_dir=args.model_dir, input_dir=args.input_dir, output_dir=args.output_dir)
