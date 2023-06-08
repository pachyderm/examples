# Object Detection

This example illustrates a common Object Detection use case using [Pachyderm](https://www.pachyderm.com/), [Lightning Flash](https://lightning-flash.readthedocs.io/en/latest/), and [Label Studio](https://labelstud.io/). 

<p align="center">
	<img src='images/diagram.png' width='800' title='Pachyderm'>
</p>

This demo mimics the object detection [example from Lightning Flash](https://lightning-flash.readthedocs.io/en/stable/reference/object_detection.html#example). We extend the example to predict on new data that can be used to produce predictions for the [Pachyderm Label Studio integration](https://github.com/pachyderm/label-studio) to refine and improve your training data.

## Prerequisites
In order to fully complete this example you will need the [Pachyderm Label Studio integration](https://github.com/pachyderm/label-studio) running along with the [Enterprise Server](https://docs.pachyderm.com/2.3.x/enterprise/auth/enterprise-server/setup/). You can complete up to Step 5 with the Community Edition.

## Dataset
The dataset used for this example is the COCO 128 dataset, which is a subset of [COCOtrain2017](https://cocodataset.org/), containing 80 object classes. 

## Notebook
For the detailed walkthrough, view our [notebook version of this example](Object%20Detection%20Example.ipynb). 

We also have a simplified [Weights and Biases notebook](Pachyderm%20with%20WandB%20Object%20Detection.ipynb) for experimenting with the experiment tracking setup here

## TLDR; 
Just give me the code!

```bash
wget https://github.com/zhiqwang/yolov5-rt-stack/releases/download/v0.3.0/coco128.zip
unzip coco128.zip

# Push training dataset to Pachyderm
pachctl create repo coco128
pachctl put file -r coco128@master:/ -f coco128

# Deploy model training pipeline
pachctl create pipeline -f pachyderm/model.json

# Create repo to hold production data
pachctl create repo inference_images
pachctl put file -r inference_images@master:/dog1.jpeg -f images/dog1.jpeg

# Deploy prediction pipeline
pachctl create pipeline -f pachyderm/predictions.json

# Deploy bounding box visualization pipeline 
pachctl create pipeline -f pachyderm/bboxes.json

# Create labels repo for modified annotations
pachctl create repo labels

# Start and configure Label Studio
docker run -it --rm -p8080:8080 -v ~/.pachyderm/config.json:/root/.pachyderm/config.json --device=/dev/fuse --cap-add SYS_ADMIN --name label-studio --entrypoint=/usr/local/bin/label-studio jimmywhitaker/label-studio:pach2.2-ls1.4v3

# Source repos: inference_images, predictions
# Target repo: labels

# Create auth token for updating pipeline
pachctl auth get-robot-token ls_to_cococ

# Copy token into pachyderm_secret.json
# Create Pachyderm secret
pachctl create secret -f pachyderm_secret.json

# Create Label Studio annotation to Coco dataset pipeline
pachctl create pipeline -f /pachyderm/ls_to_coco.json

# Add more data (automatically runs pipelines)
pachctl put file -r inference_images@master:/car6.jpeg -f images/car6.jpeg

# Try datum batching to improve the prediction pipeline's efficiency
pachctl update pipeline -f pachyderm/predictions_datum_batching.json --reprocess
```
