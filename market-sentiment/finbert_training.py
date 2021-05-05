#!/usr/bin/env python
# FinBERT Transfer Learning
#
# This notebooks shows how to train and use the FinBERT pre-trained language model for financial sentiment analysis.
from pathlib import Path
import shutil
import os
import logging
import sys
import argparse

sys.path.append("..")

from textblob import TextBlob
from pprint import pprint
from sklearn.metrics import classification_report

from transformers import AutoModelForSequenceClassification

from finbert.finbert import *
import finbert.utils as tools

logging.basicConfig(
    format="%(asctime)s - %(levelname)s - %(name)s -   %(message)s",
    datefmt="%m/%d/%Y %H:%M:%S",
    level=logging.ERROR,
)

parser = argparse.ArgumentParser(description="Finbert Transfer Learning")
parser.add_argument(
    "--lm_path",
    metavar="DIR",
    help="the path for the pre-trained language model (If vanilla Bert is used then no need to set this one)",
    default="/pfs/language_model",
)
parser.add_argument(
    "--cl_path",
    metavar="DIR",
    help="the path where the classification model is saved",
    default="/pfs/out/",
)
parser.add_argument(
    "--cl_data_path",
    metavar="DIR",
    default="/pfs/",
    help="the path of the directory that contains the data files of train.csv, validation.csv, test.csv.",
)
parser.add_argument(
    "--clear_cl_model_path",
    action="store_true",
    help="clean the classification model directory",
)


def clean_model_path(cl_path):
    # Clean the cl_path
    try:
        shutil.rmtree(cl_path)
    except:
        pass


def train(lm_path, cl_data_path, cl_path):
    bertmodel = AutoModelForSequenceClassification.from_pretrained(
        lm_path, cache_dir=None, num_labels=3
    )

    config = Config(
        data_dir=cl_data_path,
        bert_model=bertmodel,
        num_train_epochs=4,
        model_dir=cl_path,
        max_seq_length=48,
        train_batch_size=32,
        learning_rate=2e-5,
        output_mode="classification",
        warm_up_proportion=0.2,
        local_rank=-1,
        discriminate=True,
        gradual_unfreeze=True,
    )

    # `finbert` is our main class that encapsulates all the functionality. The list of class labels should be given in the prepare_model method call with label_list parameter.

    finbert = FinBert(config)
    finbert.base_model = "bert-base-uncased"
    finbert.config.discriminate = True
    finbert.config.gradual_unfreeze = True

    finbert.prepare_model(label_list=["positive", "negative", "neutral"])
    # ## Fine-tune the model
    # Get the training examples
    train_data = finbert.get_data("train")
    model = finbert.create_the_model()

    # Optional: Fine-tune only a subset of the model
    # The variable `freeze` determines the last layer (out of 12) to be freezed. You can skip this part if you want to fine-tune the whole model.

    # This is for fine-tuning a subset of the model.
    freeze = 6

    for param in model.bert.embeddings.parameters():
        param.requires_grad = False

    for i in range(freeze):
        for param in model.bert.encoder.layer[i].parameters():
            param.requires_grad = False

    trained_model = finbert.train(train_examples=train_data, model=model)
    return finbert, trained_model


def test(finbert, trained_model):
    """
    Test the model.

    `bert.evaluate` outputs the DataFrame, where true labels and logit values for each example is given
    """
    test_data = finbert.get_data("test")
    results = finbert.evaluate(examples=test_data, model=trained_model)
    results["prediction"] = results.predictions.apply(lambda x: np.argmax(x, axis=0))

    def report(df, cols=["label", "prediction", "logits"]):
        # print('Validation loss:{0:.2f}'.format(metrics['best_validation_loss']))
        cs = CrossEntropyLoss(weight=finbert.class_weights)
        loss = cs(torch.tensor(list(df[cols[2]])), torch.tensor(list(df[cols[0]])))
        metrics_str = "Loss:{0:.2f}".format(loss)
        metrics_str += "\nAccuracy:{0:.2f}".format(
            (df[cols[0]] == df[cols[1]]).sum() / df.shape[0]
        )
        metrics_str += "\nClassification Report:"
        metrics_str += "\n" + str(classification_report(df[cols[0]], df[cols[1]]))
        return metrics_str

    return report(results, cols=["labels", "prediction", "predictions"])


def main():
    args = parser.parse_args()

    lm_path = Path(args.lm_path)
    cl_path = Path(args.cl_path)
    cl_data_path = Path(args.cl_data_path)
    clear_cl_model_path = args.clear_cl_model_path

    if clear_cl_model_path:
        clean_model_path(cl_path)
    finbert, trained_model = train(lm_path, cl_data_path, cl_path)
    test_report = test(finbert, trained_model)
    with open(os.path.join(args.cl_path, "test_report.txt"), "wb") as f:
        f.write(test_report.encode())


if __name__ == "__main__":
    main()
