# Churn Prediction with Snowflake

[Predicting churn](https://www.investopedia.com/terms/c/churnrate.asp) is a task to determine whether a user will renew their subscription or not to a particular service. 

In this example, we use the [KKBox Churn Prediction challenge dataset](https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge/data) from [Kaggle](https://www.kaggle.com/) to show a real world setup for predicting churn for a music service. To this end, we use [Snowflake](https://www.snowflake.com/) as our data warehouse where our source data resides and [Pachyderm](https://www.pachyderm.com/) as our data versioning and processing platform for non-SQL transformations. 

Specifically, this example shows how to integrate with and use data from a data warehouse to apply coding

In it you'll learn how to:
- Ingest data from Snowflake using the [Data Warehouse Integration](https://docs.pachyderm.com/latest/how-tos/basic-data-operations/sql-ingest/#data-warehouse-integration)
- Transform your data to prepare it for model training
- Train a churn model
- Predict on new data with our churn model
- Egress our predictions back to Snowflake using [Pachyderm's Egress Feature](https://docs.pachyderm.com/latest/how-tos/basic-data-operations/export-data-out-pachyderm/sql-egress/#egress-to-an-sql-database)

## Requirements

## Churn

## KKBox Dataset

## Set Up

### Putting Data in Snowflake

## Pachyderm Pipelines

## 