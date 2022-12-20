# Google BigQuery Connector for Pachyderm
This connector ingests the result of a BigQuery query into Pachyderm. With this connector, you can easily create pipelines that read data from BigQuery and process it using Pachyderm's powerful data parallelism and versioning capabilities. It uses python and the python-bigquery-pandas library built by Google. 

## Getting started
To use this connector, you will need to have a Google Cloud Platform account with a project that has BigQuery enabled. You will also need to create a service account and download a JSON key file for authenticating with the BigQuery API.

Once you have these, you can use the connector by simply specifying your service account key file and the name of your BigQuery query in the jsonnet pipeline spec for your pipeline.

### Prerequisites
Before using this connector, you will need to create a BigQuery dataset and a service account with the necessary permissions.

1. Go to the BigQuery web UI and create a new dataset.
2. In the GCP Console, go to the IAM & admin section and create a new [service account](https://console.cloud.google.com/iam-admin/serviceaccounts/).
3. Grant the service account the BigQuery Data Viewer and BigQuery Data Editor roles for the dataset you created in step 1.
4. Download the private key file for the service account and save it to a secure location.

### Usage
The underlying code is a Python script that ingests data from a BigQuery query and saves the results as a parquet file.

```
Create a parquet file from BigQuery using pandas-gbq

optional arguments:
  -h, --help            show this help message and exit
  -i INPUT_QUERY, --input_query INPUT_QUERY
                        Input query to run on BigQuery
  -o OUTPUT_FILE, --output_file OUTPUT_FILE
                        Output file path for the parquet file
  -p PROJECT_ID, --project_id PROJECT_ID
                        Google Cloud Project ID
  -c CREDENTIALS_FILE, --credentials_file CREDENTIALS_FILE
                        Google Cloud Service account file
```

1. Once you have a service account key, save it with a descriptive name. In this example, we will use `gbq-pachyderm-creds.json`

2. Create the secret (be sure to add the namespace if your cluster is deployed in one).

```bash
kubectl create secret generic gbqsecret --from-file=gbq-pachyderm-creds.json
```
With a namespace
```bash
kubectl create secret generic gbqsecret --from-file=gbq-pachyderm-creds.json -n mynamespace
```

3. Run the pipeline template with jsonnet.  

```bash
$ pachctl update pipeline --jsonnet gbq_ingest.jsonnet \
--arg inputQuery="SELECT country_name, alpha_2_code FROM bigquery-public-data.utility_us.country_code_iso WHERE alpha_2_code LIKE 'A%'" \
--arg outFile="gbq_output.parquet" \
--arg project="<project_name>" \
--arg cronSpec="@every 30s"
```

## Configuring your own pipeline spec
You can configure your own pipeline spec with the secret by using these parameters in the pipeline spec. 

```json
"secrets": [ {
    "name": "gbqsecret",
    "mount_path": "/kubesecret/"}]
```
and
```json
    "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/kubesecret/gbq-pachyderm-creds.json"
    },
```