# Label Studio with Pachyderm

<p align="center">
	<img src='images/ls_p_integration.jpg' width='800' title='Pachyderm'>
</p>

[Label Studio](https://labelstud.io/) supports many different types of data labeling tasks, while [Pachyderm](https://www.pachyderm.com/) allows you to incorporate data versioning and data-driven pipelines. Integrating both open source components is a useful way to manage the labeling component of the [data loop](https://jimmymwhitaker.medium.com/completing-the-machine-learning-loop-e03c784eaab4). This integration connects a Pachyderm versioned data backend with Label Studio to support versioning datasets and tracking the data lineage of pipelines built off the versioned datasets.

## How it works

Label Studio can utilize an S3 backend, reading data from an S3 bucket and writing labels to an output S3 location. Pachyderm has an S3 compliant gateway that allows reading data from its file system and writing data to its filesystem (organizing it with commits that can start pipelines).

We'll create a text labeling example by:

1. Start a Label Studio instance that uses Pachyderm as its backend
2. Push data to Pachyderm that automatically populates Label Studio
3. Label the data in Label Studio
4. Version our dataset in Pachyderm

Note: Label studio currently doesn't support arbitrary S3 storage (only AWS S3 and GCS), so I modified Label Studio's S3 storage backend to support generic object storage endpoints, which allows us to connect to the Pachyderm S3 gateway running locally. you can see the code [here](label_studio/storage/S3.py)

## Getting Started
This example uses a Pachyderm deployment for scaling and management. We can deploy a cluster on [Pacyderm Hub](hub.pachyderm.com) for free or deploy locally as described here: [Pachyderm Getting Started](https://docs.pachyderm.com/latest/getting_started/)

Once everything is up, we can check the setup by running: 
1. `kubectl get all` to ensure all the pods are up and ready. 
2. `pachctl version` which will show both the `pachctl` and `pachd` versions.

### Configuring .env file
The `.env` file needs to be configured for your Pachyderm S3 gateway. Pachyderm's S3 gateway is accessed through an `http` endpoint that is available on port `30600` on the Pachyderm cluster. This address is used to as the `ENDPOINT_URL` for the Label Studio backend in the `.env` file. 

It should look similar to the following. 

```bash
$ cat .env
ENDPOINT_URL=http://192.168.64.8:30600
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
```

#### Pachyderm Hub
If you are running your cluster on Pachyderm Hub, you can find out your `ENDPOINT_URL` by clicking the `Connect` button. You should see an address that looks something like: 

`grpcs://hub-xx-xxxYYxxYY.clusters.pachyderm.io:31400`

Just change the protocol to `http` and port to `30600`. This will now point at the S3 gateway. 

`https://hub-xx-xxxYYxxYY.clusters.pachyderm.io:30600`

The `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your `.env` file should be set to your Pachyderm `session_token` located in your Pachyderm config (typically in `~/.pachyderm/config.json`). More info on Pachyderm's [S3 gateway](https://docs.pachyderm.com/latest/deploy-manage/manage/s3gateway/configure-s3client/). 

If you get the following error, 

```
botocore.exceptions.ClientError: An error occurred (403) when calling the HeadBucket operation: Forbidden
```

this is typically due to an expired session token. Reconnect to the cluster and update your `.env` with the new token. 

#### Minikube configuration
If you are running Pachyderm locally on minikube, you can get the `ENDPOINT_URL` for the Pachyderm S3 gateway by running the command:

```
$ minikube ip
192.168.64.8
```

If you are running Pachyderm with authentication, then you can follow the same steps as the Hub setup to set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. If not running with authentication, you can pass any non-empty string to `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your `.env` file.

<!-- ## Creating a new project
A new project requires creating a new configuration (see some of the [examples](examples/)). Creating a new project with Label Studio can be done by from the command line. We'll use the Docker image that we created to do this, adding the `--init` flag which will create the project. 

```shell
docker run --env-file .env -v $(pwd)/examples/my_new_project:/my_new_project -p 8080:8080 --entrypoint=label-studio jimmywhitaker/label-studio:latest start /my_new_project/ --source s3 --source-path master.raw_data --target s3-completions --target-path master.labeled_data --input-format=image --template image_bbox --source-params "{\"use_blob_urls\": false, \"regex\": \".*\"}"

``` -->

## Running the Text Labeling Example

``` bash
# Pachyderm Setup
pachctl create repo raw_data
pachctl create repo labeled_data
pachctl create branch labeled_data@master
pachctl create branch raw_data@master

# Start a local instance of Label Studio (needs the .env for the Pach S3 gateway)
docker run --env-file .env -v $(pwd)/examples/my_text_project:/my_text_project -p 8080:8080 jimmywhitaker/label-studio:latest

# Navigate to http://localhost:8080/tasks

# Upload data
pachctl put file raw_data@master:/test-example.json -f raw_data/test-example.json --split json --target-file-datums 1

# Modify the data before it's labeled
pachctl put file raw_data@master:/test-example.json -f raw_data/test-example2.json --split json --target-file-datums 1 --overwrite

# Label data (2 examples) in the UI

# Version your dataset (v1)
pachctl list branch labeled_data
pachctl create branch labeled_data@v1 --head master
pachctl list branch labeled_data

# Label more data in the UI

# Version your dataset (v2)
pachctl list branch labeled_data
pachctl create branch labeled_data@v2 --head master

# Download dataset for v1 locally
pachctl get file -r labeled_data@v1:/ -o labeled_data/

```

### Next Steps

* The output does have a reference for what the input file location was (could potentially be used to track consistency between raw and labeled if raw changes).
* Make deployment super easy
  * Build a helm chart to deploy label studio to Kubernetes with necessary env 
  * Standardize label studio project creation - different examples of configs
* Ability to update `input raw data` - currently if it's labeled, then it's captured in the source and target json files. 
* Rectify the source and target files to have provenance for the labeling


### Known Issues and Gotchas 

* This project was originally created [here](https://github.com/JimmyWhitaker/label-studio-pach/) before being migrated. 
* One example per source file 
* Must be json files or figure out how to get S3 signed urls to frontend. 
* When file is updated after labeled, it's not re-loaded (not sure what should happen here - should it be removed from the labeled data repo when the raw data is removed?)
  * When raw data is changed after that example is labeled, the task doesn't update. It does update when 
  * It seems as though the target and the source states are tied somehow, so it won't automatically update
  * If a raw file is removed or changed, then labels associated with that file should be removed. Since it's a single file per example, a changed file should be the deleting of one and addition of another. For now, this would need to be an external process that 
* Label Studio automatically tries to start an image labeling config and if there is labeled data, this will throw errors until you load a compatible config for what's already labeled (i.e. you should not use the `--init` and `--force` flags after you've created the project).

