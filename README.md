# Pachyderm Examples
**Pachyderm Examples** is a curated list of examples that use Pachyderm to accomplish various tasks. 

## Getting Started
- [Intro to Pachyderm Tutorial](./Intro%20to%20Pachyderm%20Tutorial.ipynb) - A notebook introduction to Pachyderm, using the `pachctl` command line utility to illustrate the basics of Pachyderm data repositories and pipelines
- [Boston Housing Prices](./housing-prices) - A machine learning pipeline to train a regression model on the Boston Housing Dataset to predict the value of homes.
- [Boston Housing Prices (Intermediate)](./housing-prices-intermediate) - Extends the original Boston Housing Prices example to show a multi-pipeline DAG and data rollbacks. 
- [Market Sentiment](./market-sentiment) - Train and deploy a fully automated financial market sentiment BERT model. As data is manually labeled, the model will automatically retrain and deploy. 
- [Object Detection](./object-detection) - Train an object detector on the COCO128 dataset with Lightning Flash, modify predictions with Label Studio, and version everything in Pachyderm. 

## Notebooks
- [JupyterLab Pachyderm Mount Extension](./Mount%20Extension%20Demo.ipynb) - A notebook showing how to use the [JupyterLab Pachyderm Mount Extension](https://docs.pachyderm.com/latest/how-tos/jupyterlab-extension/) to mount Pachyderm data repositories into your Notebook environment. 
- [Jsonnet Pipeline Specs](./jsonnet/Jsonnet%20Pipeline%20Specs.ipynb) - A notebook introducing and showing how use [Jsonnet Pipeline Specs](https://docs.pachyderm.com/latest/how-tos/pipeline-operations/jsonnet-pipeline-specs/) to templatize common pipelines. 
- [SAME Project](./same/) - A notebook showing how to do Pachyderm pipeline development with the [SAME Project](https://sameproject.ml/).  

## Data Labeling
- [Label Studio Integration](./label-studio) - Incorporate data versioning into any labeling project with Label Studio and Pachyderm. 
- [Superb AI Integration](./superb-ai) - Version labeled image datasets created in Superb AI Suite using a cron pipeline.
- [Toloka Integration](https://github.com/Toloka/toloka-pachyderm) - Uses Pachyderm to create crowdsourced annotation jobs for news headlines in Toloka, aggregate the labeled data, and train a model.

## Data Warehouse
- [Churn Prediction with Snowflake](./snowflake) - Create a churn analysis model for a music streaming service with Pachyderm and Snowflake using the Data Warehouse integration. 

## Machine Learning
- [Boston Housing Prices (Intermediate)](./housing-prices-intermediate) - Extends the original Boston Housing Prices example to show a multi-pipeline DAG and data rollbacks. 
- [Breast Cancer Detection](./breast-cancer-detection) - A breast cancer detection system based on radiology scans scaled and visualized using Pachyderm.
- [AutoML](./autoML) - A Pachyderm pipeline that uses the [mljar-supervised](https://github.com/mljar/mljar-supervised) to train a machine learning model on a CSV file.
- [Market Sentiment](./market-sentiment) - Train and deploy a fully automated financial market sentiment BERT model. As data is manually labeled, the model will automatically retrain and deploy. 
- [Apache Spark - MLflow Integration](https://github.com/winderai/pachyderm-mlflow-spark) - End-to-end example demostrating the full ML training process of a fraud detection model with Spark, MLlib, MLflow, and Pachyderm.

## ML Experiment Tracking
- [Weights and Biases](./weights_and_biases) - Log pipelines running in Pachyderm to Weights and Biases.
- [ClearML Integration](https://github.com/JimmyWhitaker/pach_clearml) - Log Pachyderm experiments to ClearML's experiment montioring platform, using Pachyderm Secrets. 

## Model Deployment
- [Pachyderm - Seldon](https://github.com/winderai/pachyderm-seldon) - Community example showing monitoring and provenance for machine learning models with Pachyderm and Seldon.
- [Seldon (Market Sentiment)](./seldon) - Deploy the model created in the [Market Sentiment](./market-sentiment) example with [Seldon Deploy](https://www.seldon.io/tech/products/deploy/).
