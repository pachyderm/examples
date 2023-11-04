import pandas as pd
import os, argparse
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from UtilTextClassification import plot_freq


def load_files(input_dir):
    df_combined = pd.DataFrame()
    for dirpath, dirs, files in os.walk(input_dir):
        for file in files:
            if file.endswith(".csv"):
                df_raw = pd.read_csv(os.path.join(dirpath, file), index_col=0)
                df_raw = df_raw[pd.notnull(df_raw["description"])]
                df = df_raw[["variety", "description"]]
                df_combined = pd.concat([df_combined, df], axis=0)
    return df_combined


def clean_text(text):
    extras = [
        ".",
        ",",
        '"',
        "'",
        "'",
        "?",
        "!",
        ":",
        ";",
        "(",
        ")",
        "[",
        "]",
        "{",
        "}",
        "cab",
        "%",
    ]
    stop_words = set(stopwords.words("english"))
    stop_words.update(extras)
    text = str(text)

    word_tokens = word_tokenize(text)

    filtered_sentence = [
        word for word in word_tokens if word.lower() not in stop_words
    ]
    text = " ".join(filtered_sentence)

    return text


def main(input_dir, output_dir, dataset_size, min_reviews, top_n, stopwords, label_indexes):
    args = parser.parse_args()
    data = load_files(input_dir)
    data.drop_duplicates(subset=["description"])
    if top_n > 0:
        top_x = data["variety"].value_counts().nlargest(top_n)
        data = data[data["variety"].isin(top_x.index)]
    if dataset_size > 0:
        data = data[:dataset_size]
    data = data.groupby("variety").filter(lambda x: len(x) >= min_reviews)
    data = data.reset_index(drop=True)
    if stopwords:
        data["description"] = data["description"].apply(clean_text)
    print(data.describe())
    # Label distributed fequency.
    plt = plot_freq(data, col=["variety"], top_classes=30)
    plt.savefig(os.path.join(output_dir, "label_freq.png"))
    if label_indexes:
        data["variety"] = data["variety"].astype("category")
        data["variety"] = data["variety"].cat.codes
    data.to_csv(os.path.join(output_dir, "data.csv"), index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_dir",
        default="data",
        help="Name of input directory that stores the wine reviews",
    )
    parser.add_argument(
        "--output_dir",
        default="output",
        help="Name of output directory that stores the combined data",
    )
    parser.add_argument(
        "--dataset_size",
        type=int,
        default=0,
        help="Max number of rows, 0 is no limit",
    )
    parser.add_argument(
        "--min_reviews",
        type=int,
        default=2,
        help="Minimum number of reviews per varietal",
    )
    parser.add_argument(
        "--top_n",
        type=int,
        default=0,
        help="Limit to top n varietals, 0 is no limit",
    )
    parser.add_argument(
        "--remove_stop_words",
        type=bool,
        default=False,
        help="Remove Stop words",
    )
    parser.add_argument(
        "--label-indexes",
        type=bool,
        default=False,
        help="Use label indexes instead of label names",
    )
    args = parser.parse_args()
    main(
        input_dir=args.input_dir,
        output_dir=args.output_dir,
        dataset_size=args.dataset_size,
        min_reviews=args.min_reviews,
        top_n=args.top_n,
        stopwords=args.remove_stop_words,
        label_indexes=args.label_indexes,
    )
