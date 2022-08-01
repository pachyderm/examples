import argparse
import flash
from flash.core.data.utils import download_data
from flash.image import ObjectDetectionData, ObjectDetector
from os import path
import os
import json
import tempfile

import pytorch_lightning as pl
from pytorch_lightning.loggers import WandbLogger

from utils import coco_merge

parser = argparse.ArgumentParser(description="Train an object detecion model")
parser.add_argument("--train-dir", metavar="DIR", default="./output", help="input directory")
parser.add_argument(
    "--output-dir", metavar="DIR", default="./output", help="output directory"
)
parser.add_argument(
        "--wandb-project",
        type=str,
        help="For loading the dataset",
    )

def merge_datasets(train_dir):
    with open(path.join(train_dir, "coco128/annotations/instances_train2017.json")) as f:
        dataset = json.load(f)
        for i in dataset['images']: 
            i['file_name'] = os.path.join('coco128/images/train2017/', i['file_name'])

    if os.path.exists(path.join(train_dir, 'inference_images/annotations/ls_dataset.json')):
        with open(path.join(train_dir, 'inference_images/annotations/ls_dataset.json')) as f:
            infer_dataset = json.load(f)
            dataset = coco_merge(dataset, infer_dataset)
            
    annotations_file = tempfile.NamedTemporaryFile()
    
    # Open the file for writing.
    with open(annotations_file.name, 'w') as f:
        f.write(json.dumps(dataset))
    return annotations_file
    

def create_datamodule(train_dir):
    
    ann_file = merge_datasets(train_dir)
    
    datamodule = ObjectDetectionData.from_coco(
        train_folder=train_dir,
        train_ann_file=ann_file.name,
        val_split=0.1,
        transform_kwargs={"image_size": 512},
        batch_size=4,
    )
    
    return datamodule

def train_model(datamodule, logger=None): 
    model = ObjectDetector(head="efficientdet", backbone="d0", num_classes=datamodule.num_classes, image_size=512, labels=datamodule.labels)

    # Create the trainer and finetune the model
    trainer = flash.Trainer(max_epochs=5, logger=logger)

    trainer.finetune(model, datamodule=datamodule, strategy="freeze")
    
    return trainer

def save_model(model, model_path):
    model.save_checkpoint(model_path)
    
def main():
    args = parser.parse_args()
    
    logger = None
    if args.wandb_project:
        logger = WandbLogger(
            project=args.wandb_project, name=str(os.getenv("PACH_JOB_ID", "Local"))
        )
    
    # 1. Load data
    datamodule = create_datamodule(args.train_dir)
    
    # 2. Train model
    trainer = train_model(datamodule, logger=logger)
    
    # 3. Save the model!
    save_model(trainer, path.join(args.output_dir, "object_detection_model.pt"))


if __name__ == "__main__":
    main()