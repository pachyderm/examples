import argparse
import pandas as pd
from os import path

parser = argparse.ArgumentParser(description="Data Cleaning for KKBox Dataset")
parser.add_argument("--data", type=str, help="")
parser.add_argument('--inference', action='store_true')
parser.add_argument(
    "--output", metavar="DIR", default="./output", help="output directory"
)


def drop_rows_with_missing_dates(df: pd.DataFrame, cols: list):
    """
    Drops rows with missing values
    """
    df.dropna(axis=0, how="any", subset=cols, inplace=True)


def replace_value_in_col(
    df: pd.DataFrame, col: str, valToReplace: str, replaceWith: str
):
    """
    Replace the value in a column with another value
    """
    df[col] = df[col].replace(to_replace=valToReplace, value=replaceWith)


def impute_col_value(df: pd.DataFrame, col: str, impute_value: float):
    """
    Impute missing values in a column with some defined value
    """
    df[col] = df[col].fillna(impute_value)

col_names = [
            "msno",
            "date",
            "num_25",
            "num_50",
            "num_75",
            "num_985",
            "num_100",
            "num_unq",
            "total_secs",
            "is_churn",
            "payment_method_id",
            "payment_plan_days",
            "plan_list_price",
            "actual_amount_paid",
            "is_auto_renew",
            "transaction_date",
            "membership_expire_date",
            "is_cancel",
            "city",
            "bd",
            "gender",
            "registered_via",
            "registration_init_time",
        ]

def main():
    args = parser.parse_args()
    
    # TODO: Infer if data is inference or training automatically 
    if args.inference: 
        col_names.remove("is_churn")

    data = pd.read_csv(
        args.data,
        names=col_names,
    )

    drop_rows_with_missing_dates(
        data,
        cols=[
            "registration_init_time",
            "membership_expire_date",
            "transaction_date",
            "date",
        ],
    )

    mode_impute_cols = [
        "city",
        "is_cancel",
        "payment_method_id",
        "gender",
        "plan_list_price",
        "actual_amount_paid",
        "payment_plan_days",
    ]
    for col in mode_impute_cols:
        impute_col_value(data, col, data[col].mode())
    # impute cols with median value
    median_impute_cols = ["bd"]
    for col in median_impute_cols:
        impute_col_value(data, col, data[col].median())
    # impute cols with zero
    zero_impute_cols = [
        "is_auto_renew",
        "num_25",
        "num_50",
        "num_75",
        "num_985",
        "num_unq",
        "total_secs",
    ]
    for col in zero_impute_cols:
        impute_col_value(data, col, 0)

    replace_value_in_col(data, "gender", "male", 1)
    replace_value_in_col(data, "gender", "female", 2)

    if args.inference:
         data.to_csv(path.join(args.output, "prediction_data.csv"))
    else:
        data.to_csv(path.join(args.output, "training_data_model.csv"))


if __name__ == "__main__":
    main()
