import torch
from torchvision import transforms
from torchvision.io import read_image
from torchvision.utils import draw_bounding_boxes

import json
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description="Draw bounding boxes for model predictions.")
parser.add_argument(
    "--predictions", metavar="DIR", default="./predictions", help="Predictions directory"
)
parser.add_argument(
    "--images", metavar="DIR", default="./images", help="Images directory"
)
parser.add_argument(
    "--output", metavar="DIR", default="./output", help="Output directory"
)

def _generate_color_palette(num_objects: int):
    palette = torch.tensor([2 ** 25 - 1, 2 ** 15 - 1, 2 ** 21 - 1])
    return [tuple((i * palette) % 255) for i in range(num_objects)]

def bbox_pct_to_pxl(x, y, width, height, original_height, original_width):
    pixel_x = x / 100.0 * original_width
    pixel_y = y / 100.0 * original_height
    pixel_width = width / 100.0 * original_width
    pixel_height = height / 100.0 * original_height
    return [pixel_x, pixel_y, pixel_x+pixel_width, pixel_y+pixel_height]

def read_bboxes(prediction, img_size):
    bboxes = []
    labels = []
    original_height = img_size[1]
    original_width = img_size[2]
    for p in prediction['predictions'][0]['result']:
        x = p['value']['x']
        y = p['value']['y']
        width = p['value']['width']
        height = p['value']['height']
        bbox = bbox_pct_to_pxl(x, y, width, height, original_height, original_width)
        bboxes.append(bbox)
        labels.append(p['value']['rectanglelabels'][0])
    return bboxes, labels


def main():
    args = parser.parse_args()
    
    predictions_dir = args.predictions
    image_dir = args.images
    output_dir= args.output

    files = [Path(item) for item in Path(predictions_dir).iterdir() if item.is_file()]
    images = [Path(item) for item in Path(image_dir).iterdir() if item.is_file()]

    for file in files:
        data = json.loads(file.read_bytes())
        for img_path in images: 
            if data['data']['image'].endswith('/'+img_path.name):
                img = read_image(str(img_path))
        
                bboxes, labels = read_bboxes(data, img.size())
                colors = _generate_color_palette(len(labels))
                bbox = torch.tensor(bboxes, dtype=torch.int)
        
                img = draw_bounding_boxes(img, bbox, width=2, colors=colors, labels=labels, font_size=10)
                img = transforms.ToPILImage()(img)
                img.save(str(Path(output_dir) / img_path.name))
                

if __name__ == "__main__":
    main()