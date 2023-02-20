import pandas as pd
import os, argparse
from UtilTextClassification import  evaluate, load_data
import spacy
from spacy.tokens import DocBin


def load_model(model_dir):
    print("Loading from", model_dir)
    nlp = spacy.load(model_dir)
    return nlp

def test_model(nlp,test_list):
    text, label = list(zip(*test_list))
    evaluate(nlp, text, label, label_names=None)

def convert(df, cats, outfile, mode):
    nlp = spacy.blank("en")
    db = DocBin()
    for ind in df.index:
        doc = nlp.make_doc(df["description"][ind])
        doc.cats = cats.copy()
        doc.cats[df["variety"][ind]] = 1
        db.add(doc)
    db.to_disk(outfile)

def main(input_dir, output_dir):
    train_filename = os.path.join(input_dir, "train.csv")
    test_filename = os.path.join(input_dir, "test.csv")
    valid_filename = os.path.join(input_dir, "valid.csv")
    labels_filename = os.path.join(input_dir, "labels.csv")
    # Data loading
    print("Loading data...")
    train_data, train_features, train_targets = load_data(
        train_filename, "variety"
    )
    print(
        "Training set has {} data points with {} variables each.".format(
            *train_data.shape
        )
    )
    test_data, test_features, test_targets = load_data(
        test_filename, "variety"
    )
    print(
        "Testing set has {} data points with {} variables each.".format(
            *test_data.shape
        )
    )
    print("Loading validation data...")
    valid_data, valid_features, valid_targets = load_data(
        valid_filename, "variety"
    )
    print(
        "Validation set has {} data points with {} variables each.".format(
            *valid_data.shape
        )
    )
    #train_y_df = pd.get_dummies(train_targets)
    #valid_y_df = pd.get_dummies(valid_targets)
    #test_y_df = pd.get_dummies(test_targets)

    # Convert to list.
    #train_ls = df2list(train_features['description'], train_y_df)
    #valid_ls = df2list(valid_features['description'], valid_y_df)
    #test_ls = df2list(test_features['description'], test_y_df)
    
    # Train the model

    labels = pd.read_csv(labels_filename, header=0)['0'].tolist()
    cats =  {category: 0 for category in labels}
    convert(train_data, cats, os.path.join(output_dir, "train.spacy"), "training")
    convert(valid_data, cats, os.path.join(output_dir, "valid.spacy"), "validation")
    convert(test_data, cats, os.path.join(output_dir, "test.spacy"), "testing")
    #spacy_train(train_ls, valid_ls, output_dir, labels)
    #nlp = spacy.load("en_core_web_sm")
    #traindoc = create_docs(nlp, train_data, train_features, train_targets)
    #validdoc = create_docs(nlp, valid_data, valid_features, valid_targets)
    #doc_bin = DocBin(docs=traindoc)
    #doc_bin.to_disk(os.path.join(output_dir, "./data/train.spacy"))
    # repeat for validation data
    #doc_bin = DocBin(docs=validdoc)
    #doc_bin.to_disk(os.path.join(output_dir,"./data/valid.spacy"))
    #model = load_model(output_dir)
    #test_model(model, valid_ls)
    #test_model(model, test_ls)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_dir",
        type=str,
        help="directory with train.csv, valid.csv, and test.csv",
    )
    parser.add_argument(
        "--output_dir",
        metavar="DIR",
        default="./model",
        help="output directory",
    )
    args = parser.parse_args()
    main(input_dir=args.input_dir, output_dir=args.output_dir)
