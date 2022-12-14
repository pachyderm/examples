import argparse
import pandas as pd
from google.oauth2 import service_account
from pandas_gbq import read_gbq


def parse_args():
    # Define and parse command line arguments
    parser = argparse.ArgumentParser(description='Create a parquet file from BigQuery using pandas-gbq')
    parser.add_argument('-i', '--input_query', type=str, required=True, help='Input query to run on BigQuery')
    parser.add_argument('-o', '--output_file', type=str, required=True, help='Output file path for the parquet file')
    parser.add_argument('-p', '--project_id', type=str, required=True, help='Google Cloud Project ID')
    parser.add_argument('-c', '--credentials_file', type=str, required=True, help='Google Cloud Service account file')
    return parser.parse_args()


def ingest_query(args):
    # Create credentials for authenticating with Google Cloud API
    credentials = service_account.Credentials.from_service_account_file(
        args.credentials_file,
    )
    
    # Read the query results from BigQuery
    df = read_gbq(args.input_query, project_id=args.project_id, credentials=credentials)

    # Save the results as a parquet file
    df.to_parquet(args.output_file)

if __name__ == '__main__':
    # Call ingest_query() function, passing in parsed command line arguments
    ingest_query(parse_args())