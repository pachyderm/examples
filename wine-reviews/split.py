import pandas as pd
import os, argparse
from UtilTextClassification import split_size
from sklearn.model_selection import train_test_split


def load_files(input_dir):
    df_raw = pd.read_csv(os.path.join(input_dir, "data.csv"))
    return df_raw


def main(input_dir, output_dir, test_size, valid_num, seed):
    df = load_files(input_dir)
    print("Shape of data: {}".format(df.shape))
    labels = pd.Series(df["variety"].unique())
    labels.to_csv(os.path.join(output_dir, "labels.csv"), index=False)
    print(df['variety'].value_counts())
    train, test = train_test_split(
        df, test_size=test_size, random_state=seed, stratify=df["variety"].values)
    # Prepare valid dataset.
    if valid_num != 0:
        train, valid = train_test_split(
            train,
            test_size=valid_num,
            random_state=seed + 33,stratify=train["variety"].values)

    print("Shape of train: {}".format(train.shape))
    print(
        "Shape of valid: {}".format(
            valid.shape if "valid" in vars() else (0, 0)
        )
    )
    print("Shape of test: {}".format(test.shape))
    test.to_csv(os.path.join(output_dir, "test.csv"), index=False)
    train.to_csv(os.path.join(output_dir, "train.csv"), index=False)
    if valid_num != 0:
        valid.to_csv(os.path.join(output_dir, "valid.csv"), index=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_dir",
        default="data",
        help="Name of input directory that stores the wine reviews",
    )
    parser.add_argument(
        "--output_dir",
        default=".",
        help="Name of output directory that stores the wine reviews",
    )
    parser.add_argument(
        "--test-size",
        type=float,
        default=0.2,
        help='percentage of data to use for testing ("0.2" = 20% used for testing, 80% for training',
    )
    parser.add_argument(
        "--valid-size",
        type=float,
        default=0.2,
        help='percentage of training data to use for validation ("0.2" = 20% used for validation, 80% for training',
    )
    parser.add_argument("--seed", type=int, default=42, help="random seed")
    args = parser.parse_args()
    main(
        input_dir=args.input_dir,
        output_dir=args.output_dir,
        test_size=args.test_size,
        valid_num=args.valid_size,
        seed=args.seed,
    )
