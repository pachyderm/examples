import argparse
import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib import pyplot
from os import path

parser = argparse.ArgumentParser(description="Feature cleaning for KKBox Dataset")
parser.add_argument("--data", type=str, help="")
parser.add_argument('--inference', action='store_true')
parser.add_argument(
    "--output", metavar="DIR", default="./output", help="output directory"
)


def column_subtractor(df: pd.DataFrame, newCol: str, col1: str, col2: str):
    """
    Creates a column which is the result of a subtraction
    between the values in two cols, col1 and col2
    """
    df[newCol] = df[col1] - df[col2]


def discount_checker(df: pd.DataFrame, newCol: str, checkCol: str):
    """
    Creates a column which takes on values 1 or 0
    1 indicating the value in checkCol is greater than zero
    0 indicating otherwise
    """
    df[newCol] = df[checkCol].apply(lambda x: 1 if x > 0 else 0)


def divide_col_values(df: pd.DataFrame, newCol: str, col1: str, col2: str):
    """
    Creates a new col which is the quotient of a divident(col1)
    and a divisor(col2)
    """
    df[newCol] = df[col1] / df[col2]


def int_to_date_conversion(df: pd.DataFrame, cols: list):
    """
    Convert integers into datetime
    """
    for col in cols:
        df[col] = pd.to_datetime(df[col], format="%Y%m%d")


def datetime_delta_to_int(df: pd.DataFrame, col: str):
    """
    Convert a timedelta value to an integer
    """
    df[col] = df[col] / np.timedelta64(1, "D")
    df[col] = df[col].astype(int)


def check_values(
    df: pd.DataFrame, newCol: str, col1: str, val1: int, col2: str, val2: int
):
    """
    Creates a column with values
    1 - indicating condition is met
    0 - indicating condition is not met
    """
    df[newCol] = (df[col1] == val1) == (df[col2] == val2)
    df[newCol] = df[newCol].astype(int)


def aggregator(df: pd.DataFrame, group: str, aggs: dict):
    """
    Returns an aggregrated DataFrame
    """
    grouped_df = df.groupby(group).agg(aggs)
    grouped_df.reset_index(inplace=True)
    return grouped_df


aggregrations = {
    "is_churn": pd.Series.mode,
    "city": "max",
    "bd": "mean",
    # 'gender': pd.Series.mode,
    "registered_via": "median",
    # 'registration_init_time': pd.Series.mode,
    "payment_method_id": "median",
    "payment_plan_days": "median",
    "plan_list_price": "mean",
    "actual_amount_paid": "mean",
    "is_auto_renew": "median",
    "is_cancel": "median",
    "discount": "mean",
    "is_discount": "median",
    "amt_per_day": "mean",
    "registration_duration": "max",
    "membership_duration": "max",
    "reg_mem_duration": "max",
    "date": "nunique",
    "num_25": "mean",
    "num_50": "mean",
    "num_75": "mean",
    "num_985": "mean",
    "num_100": "mean",
    "num_unq": "mean",
    "total_secs": "mean",
}


def main():
    args = parser.parse_args()
    
    if args.inference: 
        aggregrations.remove("is_churn")
    
    # reading data csv
    data_features = pd.read_csv(args.data)

    column_subtractor(
        data_features, "discount", "plan_list_price", "actual_amount_paid"
    )
    column_subtractor(
        data_features, "discount", "plan_list_price", "actual_amount_paid"
    )
    discount_checker(data_features, "is_discount", "discount")
    divide_col_values(
        data_features, "amt_per_day", "actual_amount_paid", "payment_plan_days"
    )
    int_to_date_conversion(
        data_features,
        [
            "date",
            "transaction_date",
            "membership_expire_date",
            "registration_init_time",
        ],
    )

    column_subtractor(
        data_features,
        "registration_duration",
        "membership_expire_date",
        "registration_init_time",
    )
    column_subtractor(
        data_features,
        "membership_duration",
        "membership_expire_date",
        "transaction_date",
    )
    datetime_delta_to_int(data_features, "registration_duration")
    datetime_delta_to_int(data_features, "membership_duration")
    column_subtractor(
        data_features,
        "reg_mem_duration",
        "registration_duration",
        "membership_duration",
    )
    check_values(
        data_features,
        "autorenew_but_not_cancel",
        "is_auto_renew",
        1,
        "is_cancel",
        0,
    )
    check_values(
        data_features,
        "notAutorenew_but_cancel",
        "is_auto_renew",
        0,
        "is_cancel",
        1,
    )
    grouped_features = aggregator(data_features, "msno", aggregrations)
    
    if args.inference: 
        grouped_features.to_csv(path.join(args.output, "inference_features.csv"))
    else:
        grouped_features.to_csv(path.join(args.output, "training_data_features.csv"))


if __name__ == "__main__":
    main()
