import argparse
import flash
from flash.core.data.utils import download_data
from flash.image import ObjectDetectionData, ObjectDetector
from os import path, walk
from os.path import basename, splitext
from flash.core.data.io.input import DataKeys
import json
from pathlib import Path

parser = argparse.ArgumentParser(description="Train an object detecion model")
parser.add_argument("--model-path", type=str, help="")
parser.add_argument(
    "--data-dir", metavar="DIR", default="./output", help="output directory"
)
parser.add_argument(
    "--output-dir", metavar="DIR", default="./output", help="output directory"
)

def load_model(model_path):
    model = ObjectDetector.load_from_checkpoint(model_path)
    return model

def load_data(data_path):
    # walk data_path and make a list of images
    predict_files = []
    for dirpath, dirs, files in walk(data_path):
        for file in files:
            predict_files.append(path.join(dirpath, file))
            
    datamodule = ObjectDetectionData.from_files(
        predict_files=predict_files,
        transform_kwargs={"image_size": 512},
        batch_size=4,
    )
    return datamodule



# Convert predictions to Label Studio format
def pred_to_label_studio(predictions, labels, output_dir):
    # For each image
    for image in predictions[0]:
        p = Path(image[DataKeys.METADATA]['filepath'])
        dir_name = p.parts[-2]
        pred_task = {
                      "data": {
                        "image": '/data/pfs/?d=' + dir_name + '@master/' + p.name
                      },

                      "predictions": [{
                        "result": [],
                        "score": 0
                      }]
                    }
        # For each bounding box predicted
        for count, rect in enumerate(image[DataKeys.PREDS]['bboxes']):
            
            pixel_x = rect['xmin'] * 100.0 / image[DataKeys.METADATA]['size'][1]
            pixel_y = rect['ymin'] * 100.0 / image[DataKeys.METADATA]['size'][0]
            pixel_width = rect['width'] * 100.0 / image[DataKeys.METADATA]['size'][1]
            pixel_height = rect['height'] * 100.0 / image[DataKeys.METADATA]['size'][0]
            
            result = {
                "id": "result"+ str(count),
                "type": "rectanglelabels",        
                "from_name": "label", "to_name": "image",
                "original_width": image[DataKeys.METADATA]['size'][1], 
                "original_height": image[DataKeys.METADATA]['size'][0],
                "image_rotation": 0,
                "value": {
                  "rotation": 0,          
                  "x": float(pixel_x), "y": float(pixel_y),
                  "width": float(pixel_width), "height": float(pixel_height),
                  "rectanglelabels": [ labels[image[DataKeys.PREDS]['labels'][count]] ]
                }
              }
            pred_task['predictions'][0]['result'].append(result)
            
        # Write prediction file
        with open(path.join(output_dir, p.stem + '.json'), 'w') as f: 
            json.dump(pred_task, f)
    
def main():
    args = parser.parse_args()
    
    # 1. Load data
    datamodule = load_data(args.data_dir)
    
    # 2. Load model
    model = load_model(args.model_path)
    
    # 3. Predict objects with model
    trainer = flash.Trainer()
    predictions = trainer.predict(model, datamodule=datamodule)
    
    # 4. Convert and write output predictions
    pred_to_label_studio(predictions, model.labels, args.output_dir)


if __name__ == "__main__":
    main()