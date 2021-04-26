import os
import tempfile
import argparse
import logging
import json
import pandas as pd
from sklearn.model_selection import train_test_split

parser = argparse.ArgumentParser(description="Convert Label Studio Completions to Financial Phrase Bank dataset")
parser.add_argument("--completions-dir",
                    help="directory for completions",
                    default="output/completions/")
parser.add_argument("--output-dir",
                    help="output directory for dataset files: train.csv, validation.csv, and test.csv",
                    default="output/completions/")
parser.add_argument("--base-dataset",
                    help="(optional) location of financial phrase bank data",
                    default="data/sentiment_data/")
parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_true")

def collate_completions(completions_dir):
    dataset_file = tempfile.NamedTemporaryFile(mode='a')
    # Iterate all files 
    for dirpath, dnames, fnames in os.walk(completions_dir):
        for f in fnames:
            with open(os.path.join(dirpath, f)) as completions_file:
                completions_data = json.load(completions_file)
                example = completions_data['task']['data']['text']
                # Assumption: last completion is newest
                label = completions_data['result'][0]['value']['choices'][0].lower()
                dataset_file.write("{example}@{label}\n".format(example=example, label=label))
    return dataset_file

def main():
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    
    # Convert completions to FPB format
    completions_dataset = collate_completions(args.completions_dir)

    # Load FPB dataset
    data = []
    for dirpath, dnames, fnames in os.walk(args.base_dataset):
        for f in fnames:
            data = pd.read_csv(os.path.join(dirpath, f), sep='.@', names=['text','label'])

    # Add completions if they exist
    if os.stat(completions_dataset.name).st_size != 0:
        completions_data = pd.read_csv(args.base_dataset, sep='.@', names=['text','label'])
        data.append(completions_data, ignore_index=False)

    train, test = train_test_split(data, test_size=0.2, random_state=0)
    train, valid = train_test_split(train, test_size=0.1, random_state=0)

    train.to_csv(os.path.join(args.output_dir, 'train.csv'), sep='\t')
    test.to_csv(os.path.join(args.output_dir, 'test.csv'), sep='\t')
    valid.to_csv(os.path.join(args.output_dir, 'validation.csv'), sep='\t')

if __name__ == "__main__":
    main()