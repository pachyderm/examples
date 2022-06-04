import argparse
import pandas as pd
from os import path

parser = argparse.ArgumentParser(description="Structured data regression")
parser.add_argument("--train",
                    type=str,
                    help="")
parser.add_argument("--memberships",
                    type=str,
                    help="")
parser.add_argument("--user_logs",
                    type=str,
                    help="")
parser.add_argument("--transactions",
                    type=str,
                    help="")
parser.add_argument("--output",
                    metavar="DIR",
                    default='./output',
                    help="output directory")


def drop_rows_with_missing_dates(df:pd.DataFrame, cols:list):
    """
    Drops rows with missing values
    """
    df.dropna(axis=0, how='any', subset=cols, inplace=True)
    
def replace_value_in_col(df:pd.DataFrame, col:str, valToReplace:str, replaceWith:str):
    """
    Replace the value in a column with another value
    """
    df[col] = df[col].replace(to_replace=valToReplace, value=replaceWith)
    
def impute_col_value(df:pd.DataFrame, col:str, impute_value:float):
    """
    Impute missing values in a column with some defined value 
    """
    df[col] = df[col].fillna(impute_value)
    
      

def main():
    args = parser.parse_args()
    # reading train csv
    train_data = pd.read_csv(args.train, names=["msno","is_churn", ])

    # reading members csv
    members_data = pd.read_csv(args.memberships, names=["msno","city","bd","gender","registered_via","registration_init_time"])

    # reading user logs csv
    logs_data = pd.read_csv(args.user_logs, names=["msno","date","num_25","num_50","num_75","num_985", "num_100","num_unq","total_secs"])

    transactions_data = pd.read_csv(args.transactions, names=["msno","payment_method_id","payment_plan_days","plan_list_price","actual_amount_paid","is_auto_renew", "transaction_date","membership_expire_date","is_cancel"])
    
    train = pd.merge(train_data, members_data, on='msno', how='left')
    train = pd.merge(train, logs_data, on='msno', how='left')
    train = pd.merge(train, transactions_data, on='msno', how='left')

    drop_rows_with_missing_dates(train, cols=['registration_init_time', 'membership_expire_date', 'transaction_date', 'date'])

    mode_impute_cols = ['city', 'is_cancel', 'payment_method_id', 'gender', 'plan_list_price', 'actual_amount_paid', 'payment_plan_days']
    for col in mode_impute_cols:
        impute_col_value(train, col, train[col].mode())
    # impute cols with median value
    median_impute_cols = ['bd']
    for col in median_impute_cols:
        impute_col_value(train, col, train[col].median())
    # impute cols with zero
    zero_impute_cols = ['is_auto_renew', 'num_25', 'num_50', 'num_75', 'num_985', 'num_unq', 'total_secs']
    for col in zero_impute_cols:
        impute_col_value(train, col, 0)

    replace_value_in_col(train, 'gender', 'male', 1)
    replace_value_in_col(train, 'gender','female', 2)
    
    train.to_csv(path.join(args.output, 'training_data_model.csv'))
    
if __name__ == "__main__":
    main()
