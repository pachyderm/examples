import argparse
import flash
from flash.core.data.utils import download_data
from flash.image import ObjectDetectionData, ObjectDetector
from os import path

parser = argparse.ArgumentParser(description="Train an object detecion model")
parser.add_argument("--train-dir", metavar="DIR", default="./output", help="input directory")
parser.add_argument(
    "--output-dir", metavar="DIR", default="./output", help="output directory"
)

def create_datamodule(train_dir):
    datamodule = ObjectDetectionData.from_coco(
        train_folder=path.join(train_dir, "coco128/images/train2017/"),
        train_ann_file=path.join(train_dir, "coco128/annotations/instances_train2017.json"),
        val_split=0.1,
        transform_kwargs={"image_size": 512},
        batch_size=4,
    )
    
    return datamodule

def train_model(datamodule): 
    model = ObjectDetector(head="efficientdet", backbone="d0", num_classes=datamodule.num_classes, image_size=512, labels=datamodule.labels)
    
    # Create the trainer and finetune the model
    trainer = flash.Trainer(max_epochs=1)
    trainer.finetune(model, datamodule=datamodule, strategy="freeze")
    
    return trainer

def save_model(model, model_path):
    model.save_checkpoint(model_path)
    
def main():
    args = parser.parse_args()
    
    # 1. Load data
    datamodule = create_datamodule(args.train_dir)
    
    # 2. Train model
    trainer = train_model(datamodule)
    
    # 3. Save the model!
    save_model(trainer, path.join(args.output_dir, "object_detection_model.pt"))


if __name__ == "__main__":
    main()