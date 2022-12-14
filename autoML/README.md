# AutoML Pipeline in Pachyderm
This repository contains a Pachyderm pipeline for automated machine learning training on CSV files. The pipeline uses the [mljar-supervised](https://github.com/mljar/mljar-supervised) package to perform automated feature engineering, model selection, and hyperparameter tuning, making it easy to train high-quality machine learning models on structured data.

With this pipeline, you can easily train a machine learning model on a CSV file by simply uploading the file to Pachyderm. The pipeline will automatically run, handling all of the preprocessing and modeling steps automatically, allowing you to focus on evaluating the trained mode and improving your data. 

## Requirements
- Pachyderm installed and running on your cluster

## Usage

1. Upload your CSV file to Pachyderm by creating a new data repository and committing your data: 

```bash
pachctl create repo csv-data
pachctl put file csv_data@master:housing-simplified.csv -f ../housing-prices-intermediate/data/housing-simplified-1.csv
```

2. Create the AutoML Pipeline

```bash
pachctl update pipeline --jsonnet ./pachyderm/automl.jsonnet  \
    --arg name="regression" \
    --arg input="csv_data" \
    --arg target_col="MEDV" \
    --arg args="--mode Explain --random_state 42"
```
The model will automatically start training. Wait for the pipeline to complete. The trained model and evaluation metrics will be output to the AutoML output repo.

3. Update the dataset (Pachyderm retrains the model automatically)

```bash
pachctl put file csv_data@master:housing-simplified.csv -f ../housing-prices-intermediate/data/housing-simplified-error.csv
```

4. Update the dataset again (removing the error column)

```bash
pachctl put file csv_data@master:housing-simplified.csv -f ../housing-prices-intermediate/data/housing-simplified-2.csv
```
