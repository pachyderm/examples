import argparse
import os
import sys
import json
from loguru import logger


parser = argparse.ArgumentParser(description="Label Studio to Coco conversion")
parser.add_argument("--input",
                    metavar="DIR",
                    help="input video or directory of videos",
                    default="./samples")
parser.add_argument("--output",
                    metavar="DIR",
                    default="./output",
                    help="output directory for extracted frames")


def load_ls_json(label_path):
    with open(label_path) as f:
        data = json.load(f)
    return data

def bbox_pct_to_pxl(x, y, width, height, original_height, original_width):
    pixel_x = x / 100.0 * original_width
    pixel_y = y / 100.0 * original_height
    pixel_width = width / 100.0 * original_width
    pixel_height = height / 100.0 * original_height
    return [int(pixel_x), int(pixel_y), int(pixel_x+pixel_width), int(pixel_y+pixel_height)]

def ls_to_coco(ls_data, convert_pfs_name=False):
    # image data
    if convert_pfs_name:
        file_name = ls_data['task']['data']['image'].partition('?d=')[-1]
    else: 
        file_name = ls_data['task']['data']['image']
    
    image_data = {'width': ls_data['result'][0]['original_width'],
                 'height': ls_data['result'][0]['original_height'],
                 'id': ls_data['id'],
                 'file_name': file_name} # assumed format from label studio '/data/pfs/?d=inference_images@master/dog1.jpeg'
    
    # categories data
    output_categories = set()
    for r in ls_data['result']:
        name = r['value']['rectanglelabels'][0]
        output_categories.add(name)
    
    categories = [] 
    indexed_categories = {}
    for i, name in enumerate(output_categories):
        categories.append({'id': i, 'name':name})
        indexed_categories[name] = i
    
    # annotations data
    annotations = []
    for i, r in enumerate(ls_data['result']):
        category = r['value']['rectanglelabels'][0]
        category_id = indexed_categories[category]
        
        bbox = bbox_pct_to_pxl(r['value']['x'], 
                               r['value']['y'],
                               r['value']['width'],
                               r['value']['height'],
                               r['original_width'],
                               r['original_height'])
        
        annotation = {
                      "id": i,
                      "image_id": image_data['id'],
                      "category_id": category_id,
                      "segmentation": [],
                      "bbox": bbox,
                      "ignore": 0,
                      "iscrowd": 0}
        annotations.append(annotation)
    
    
    coco_data = {'images':[image_data], 'categories': categories, 'annotations': annotations}
    return coco_data


@logger.catch(reraise=True)
def coco_merge(data_extend: dict, data_add: dict) -> str:
    """Merge COCO annotation files."""

    output: Dict[str, Any] = {
        k: data_extend[k] for k in data_extend if k not in ("images", "annotations")
    }

    output["images"], output["annotations"] = [], []

    for i, data in enumerate([data_extend, data_add]):

        logger.info(
            "Input {}: {} images, {} annotations".format(
                i + 1, len(data["images"]), len(data["annotations"])
            )
        )

        cat_id_map = {}
        for new_cat in data["categories"]:
            new_id = None
            for output_cat in output["categories"]:
                if new_cat["name"] == output_cat["name"]:
                    new_id = output_cat["id"]
                    break

            if new_id is not None:
                cat_id_map[new_cat["id"]] = new_id
            else:
                new_cat_id = max(c["id"] for c in output["categories"]) + 1
                cat_id_map[new_cat["id"]] = new_cat_id
                new_cat["id"] = new_cat_id
                output["categories"].append(new_cat)

        img_id_map = {}
        for image in data["images"]:
            n_imgs = len(output["images"])
            img_id_map[image["id"]] = n_imgs
            image["id"] = n_imgs

            output["images"].append(image)

        for annotation in data["annotations"]:
            n_anns = len(output["annotations"])
            annotation["id"] = n_anns
            annotation["image_id"] = img_id_map[annotation["image_id"]]
            annotation["category_id"] = cat_id_map[annotation["category_id"]]

            output["annotations"].append(annotation)

    logger.info(
        "Result: {} images, {} annotations".format(
            len(output["images"]), len(output["annotations"])
        )
    )

    return output


def main():
    args = parser.parse_args()

    # Create a list of input files
    label_paths = []
    if os.path.isfile(args.input):  # path is a file
        label_paths.append(args.input)
    elif os.path.isdir(args.input):  # path is a directory
        for f in os.listdir(args.input):
            label_paths.append(os.path.join(args.input, f))
            
    
    coco_dataset = None
    for input_path in label_paths:
        ls_data = load_ls_json(input_path)
        coco_data = ls_to_coco(ls_data, convert_pfs_name=True)
        if coco_dataset: 
            coco_dataset = coco_merge(coco_dataset, coco_data)
        else:
            coco_dataset = coco_data
    
    with open(os.path.join(args.output, 'ls_dataset.json'), "w") as f:
        json.dump(coco_dataset, f, indent=None)

        
            
if __name__ == "__main__":
    main()