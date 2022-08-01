import argparse
import os
import sys
import json
from loguru import logger
import python_pachyderm
from time import sleep
from utils import coco_merge


parser = argparse.ArgumentParser(description="Label Studio to Coco conversion")
parser.add_argument("--input",
                    metavar="DIR",
                    help="input directory of annotation files from Label Studio")
parser.add_argument("--output",
                    default="./output",
                    help="output directory for extracted frames or pachyderm repo to egress to (ex. repo@branch:/path/to/dir/)")


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

def bbox_pct_to_pxl2(x, y, width, height, original_height, original_width):
    pixel_x = x / 100.0 * original_width
    pixel_y = y / 100.0 * original_height
    pixel_width = width / 100.0 * original_width
    pixel_height = height / 100.0 * original_height
    return [int(x), int(y), pixel_width, pixel_height]

def ls_to_coco(ls_data, convert_pfs_name=False):
    # image data
    if convert_pfs_name:
        file_name = ls_data['task']['data']['image'].partition('?d=')[-1]
    else: 
        file_name = ls_data['task']['data']['image']
        
    logger.info(
            "Converting: Label Studio file {}".format(
                file_name)
        )
    
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
        
        bbox = bbox_pct_to_pxl2(r['value']['x'], 
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
                      "area": r['value']['width']*r['value']['height'],
                      "ignore": 0,
                      "iscrowd": 0}
        annotations.append(annotation)
    
    
    coco_data = {'images':[image_data], 'categories': categories, 'annotations': annotations}
    return coco_data


def write_to_pachyderm(dataset, output_path):
    
    dest_repo = output_path.split('@', 1)[0]
    dest_branch = output_path.split('@', 1)[1].split('/',1)[0].replace(':', '')
    dest_path_base = '/'

    try:  # if directory specificed ('repo@branch:/path/')
        dest_path_base = os.path.join(dest_path_base, output_path.split('/',1)[1])
    except IndexError:  # if no directory specificed ('repo@branch')
        pass
    
    client = python_pachyderm.Client.new_in_cluster()
    with client.commit(dest_repo, dest_branch) as dest_commit:
        
        # Copy image files to destination
        for i in dataset['images']:
            src_filename = i['file_name']

            src_repo = src_filename.split('@', 1)[0]
            src_branch = src_filename.split('@', 1)[1].split('/',1)[0].replace(': ', '')
            src_path = os.path.join('/',src_filename.split('/',1)[1])

            dest_path = os.path.join(dest_path_base, 'images', os.path.basename(src_path))

            logger.info(
                "Copying: Source image {}, to {}".format(
                    src_repo + '@' + src_branch + ':' + src_path, dest_repo + '@' + dest_branch + ':' + dest_path)
            )

            
            with client.commit(src_repo, src_branch) as src_commit:
                client.copy_file(source_commit=src_commit, 
                                 source_path=src_path, 
                                 dest_commit= dest_commit, 
                                 dest_path=dest_path)
            sleep(0.2)
                
            # Update dataset
            i['file_name']=dest_path[1:] # Remove leading '/'

        dataset_output_path = os.path.join(dest_path_base, 'annotations/ls_dataset.json')
        logger.info(
                "Writing: Coco Dataset file to {}".format(
                    dest_repo + '@' + dest_branch + ':' + dataset_output_path)
            )
        # with client.commit(dest_repo, dest_branch) as c:
        client.put_file_bytes(dest_commit, dataset_output_path, json.dumps(dataset, indent=2).encode('utf-8'))
    

def write_output(dataset, output_path):
    """Write COCO dataset ouput.
    dataset: Dict of coco dataset values
    output_path: local path or pachyderm repo path to write ls_dataset.json
    
    """
    if os.path.isdir(output_path):
        with open(os.path.join(output_path, 'ls_dataset.json'), "w") as f:
            json.dump(dataset, f, indent=None)
    else: # coco128@master:/inference_images
        write_to_pachyderm(dataset, output_path)
        


def main():
    args = parser.parse_args()

    # Create a list of input files
    label_paths = []
    if os.path.isfile(args.input):  # path is a file
        label_paths.append(args.input)
    elif os.path.isdir(args.input):  # path is a directory
        for f in os.listdir(args.input):
            label_paths.append(os.path.join(args.input, f))
            
    # Convert LS files to coco dataset
    coco_dataset = None
    for input_path in label_paths:
        logger.info(
            "Reading: Label Studio file {}".format(
                input_path)
        )
        ls_data = load_ls_json(input_path)
        coco_data = ls_to_coco(ls_data, convert_pfs_name=True)
        if coco_dataset: 
            coco_dataset = coco_merge(coco_dataset, coco_data)
        else:
            coco_dataset = coco_data
    
    write_output(coco_dataset, args.output)
        
            
if __name__ == "__main__":
    main()