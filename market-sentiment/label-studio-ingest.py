import os
import argparse
import logging
import json

from market_sentiment.data_utils import *


parser = argparse.ArgumentParser(description="Sentiment Analysis Trainer")
parser.add_argument(
    "--dataset-file",
    help="text file for dataset",
    default="data/FinancialPhraseBank-v1.0/Sentences_75Agree.txt",
)
parser.add_argument(
    "--output-file",
    help="text file for label studio file",
    default="output/fpb_dataset.jsonl",
)
parser.add_argument(
    "-v", "--verbose", help="increase output verbosity", action="store_true"
)


def main():
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    df = load_finphrase(args.dataset_file)
    ls_data = df_to_ls(df)
    with open(args.output_file, "w") as f:
        f.write(ls_data)


if __name__ == "__main__":
    main()
