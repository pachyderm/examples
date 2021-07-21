import json
import os.path as path
import os
import cv2
import numpy as np
import imghdr
import argparse

import spb.sdk

parser = argparse.ArgumentParser(description="Convert Label Studio Completions to Financial Phrase Bank dataset")
parser.add_argument("--project_name",
                    help="name of the Superb.ai project",
                    default="Sample project")
parser.add_argument("--output",
                    help="output directory for dataset files",
                    default="/pfs/out/")


COLORS = [
    (229, 115, 115),
    (240, 98, 146),
    (186, 104, 200),
    (149, 117, 205),
    (121, 134, 203),
    (100, 181, 246),
    (79, 195, 247),
    (77, 208, 225),
    (77, 182, 172),
    (129, 199, 132),
    (174, 213, 129),
    (220, 231, 117),
    (255, 241, 118),
    (255, 213, 79),
    (255, 183, 77),
    (255, 138, 101),
    (161, 136, 127)
]

# Iterate all data
def get_spb_data(client, page_size=10):
    num_data = client.get_num_data()
    print(f'# of images: {num_data}')
    num_page = (num_data + page_size - 1) // page_size
    for page_idx in range(num_page):
        for data_handler in client.get_data_page(page_idx=page_idx, page_size=page_size):
            yield data_handler

def write_data(spb_client, class_to_color, output_dir):

    os.makedirs(output_dir, exist_ok=True)

    # Read and render each file
    for data_handler in get_spb_data(spb_client):
        dataset = data_handler.get_dataset_name()
        data_key = data_handler.get_key()
        imghdr = data_key.split('.')[-1]
        rendered_key = data_key.split('.')[0] + '_rendered.' + imghdr

        image_url = data_handler.get_image_url()
        label = {
            'objects': data_handler.get_object_labels(),
            'categories': data_handler.get_category_labels()
        }
        image = data_handler.get_image()

        # Same image without labels 
        img_str = cv2.imencode(f'.{imghdr}', image[:,:,::-1])[1].tobytes()
        with open(path.join(output_dir, data_key), 'wb') as f: 
            f.write(img_str)

        for obj in label['objects']:
            class_name = obj['class']
            if 'box' in obj['shape']:
                box = obj['shape']['box']
                pt1 = (int(box['x']), int(box['y']))
                pt2 = (int(box['x'] + box['width']), int(box['y'] + box['height']))
                cv2.rectangle(image, pt1, pt2, class_to_color[class_name], 3)
                cv2.putText(image, class_name, (pt1[0], pt1[1] - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.7, class_to_color[class_name], 2)
            elif 'polygon' in obj['shape']:
                polygon_list = obj['shape']['polygon']
                polygon = np.array([[int(pt['x']), int(pt['y'])] for pt in polygon_list], np.int32)
                minx, miny = min([p[0] for p in polygon]), min([p[1] for p in polygon])
                cv2.polylines(image, [polygon], True, class_to_color[class_name], thickness=3)
                cv2.putText(image, class_name, (minx, miny - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.7, class_to_color[class_name], 2)
        img_str = cv2.imencode(f'.{imghdr}', image[:,:,::-1])[1].tobytes()

        # Write labels and rendered image to output directory
        with open(path.join(output_dir, data_key+".json"),'w') as f:
            json.dump(label, f)

        with open(path.join(output_dir, rendered_key), 'wb') as f: 
            f.write(img_str)


def main():
    args = parser.parse_args()

    spb_client = spb.sdk.Client(project_name=args.project_name)

    # Print project information
    print('Project Name: {}'.format(spb_client.get_project_name()))
    print('Total number of examples: {}'.format(spb_client.get_num_data()))

    # Assign colors to classes
    class_objects = spb_client._project.label_interface['objects']
    class_to_color = {}
    for idx, class_object in enumerate(class_objects):
        color_idx = idx % 17
        class_to_color[class_object['name']] = COLORS[color_idx]

    write_data(spb_client, class_to_color, args.output)


if __name__ == "__main__":
    main()