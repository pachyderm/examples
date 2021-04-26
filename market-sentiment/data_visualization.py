# Python libraries
from tqdm import tqdm
import os
import logging
import random
import json
import argparse

# Data Science modules
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from market_sentiment.nlp_utils import *
from market_sentiment.data_utils import *
from market_sentiment.visualize import visualize_frequent_words, generate_word_cloud

plt.style.use("ggplot")

# Import Scikit-learn moduels
from sklearn.preprocessing import LabelEncoder

parser = argparse.ArgumentParser(description="Sentiment Analysis Trainer")
parser.add_argument("--data-file",
                    help="text file for dataset",
                    default="data/FinancialPhraseBank-v1.0/Sentences_75Agree.txt")
parser.add_argument("--sentiment-words-file",
                    help="csv with sentiment word list",
                    default="resources/LoughranMcDonald_SentimentWordLists_2018.csv")
parser.add_argument("--output-dir",
                    metavar="DIR",
                    default="./output",
                    help="output directory for model")
parser.add_argument("--seed",
                    type=int,
                    default=42,
                    help="random seed value")
parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_true")


# Set Seaborn Style
sns.set(style="white", palette="deep")


def create_vis(filename, sentiment_words_file, output_dir, seed=42):
    train_df = load_finphrase(filename)

    # Samples
    pd.set_option("display.max_colwidth", -1)
    logging.debug(train_df.sample(n=1, random_state=seed))


    # Encode the label
    le = LabelEncoder()
    le.fit(train_df["label"])
    train_df["label"] = le.transform(train_df["label"])
    logging.debug(list(le.classes_))
    logging.debug(train_df["label"])

    corpus = create_corpus(train_df)
    fig = visualize_frequent_words(corpus, stop_words)
    fig.savefig(os.path.join(output_dir, 'frequent_words.png'))

    wordcloud = generate_word_cloud(corpus, stop_words)
    wordcloud.to_file(os.path.join(output_dir, 'word_cloud.png'))

    # Load sentiment data
    sentiment_df = pd.read_csv(sentiment_words_file)

    # Make all words lower case
    sentiment_df["word"] = sentiment_df["word"].str.lower()
    sentiments = sentiment_df["sentiment"].unique()
    sentiment_df.groupby(by=["sentiment"]).count()

    sentiment_dict = {
        sentiment: sentiment_df.loc[sentiment_df["sentiment"] == sentiment][
            "word"
        ].values.tolist()
        for sentiment in sentiments
    }


    columns = [
        "tone_score",
        "word_count",
        "n_pos_words",
        "n_neg_words",
        "pos_words",
        "neg_words",
    ]

    # Analyze tone for original text dataframe
    print(train_df.shape)
    tone_lmdict = [
        tone_count_with_negation_check(sentiment_dict, x.lower())
        for x in tqdm(train_df["sentence"], total=train_df.shape[0])
    ]
    tone_lmdict_df = pd.DataFrame(tone_lmdict, columns=columns)
    train_tone_df = pd.concat([train_df, tone_lmdict_df.reindex(train_df.index)], axis=1)
    train_tone_df.head()

    # Show corelations to next_decision
    plt.figure(figsize=(10, 6))
    corr_columns = ["label", "n_pos_words", "n_neg_words"]
    sns.heatmap(
        train_tone_df[corr_columns].astype(float).corr(),
        cmap="coolwarm",
        annot=True,
        fmt=".2f",
        vmin=-1,
        vmax=1,
    )
    plt.savefig(os.path.join(output_dir, 'correlation.png'))
    

def main():
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    os.makedirs(args.output_dir, exist_ok=True)

    # Set Random Seed
    random.seed(args.seed)
    np.random.seed(args.seed)
    
    filename = args.data_file
    sentiment_words_file = args.sentiment_words_file
    create_vis(filename, sentiment_words_file, args.output_dir, args.seed)


if __name__ == "__main__":
    main()
