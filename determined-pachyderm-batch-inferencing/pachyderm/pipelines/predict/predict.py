import csv
from datetime import datetime
import os
import socket
import time

import numpy as np
import matplotlib.pyplot as plt
from skimage import io
from PIL import Image
from determined import pytorch
from torchvision import transforms
import torch

MODELS_PATH = "/pfs/models"
PREDICT_PATH = "/pfs/predict"
OUTPUT_PATH = "/pfs/out"

def get_test_transforms():
    return transforms.Compose([
        transforms.Resize(240),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
    ])

def save_result_to_csv(img_name, model_name, prediction, probability, confidence_dog, confidence_cat, start_timestamp, end_timestamp):
    model_path = f"{OUTPUT_PATH}/{model_name}"
    save_path = f"{model_path}/data"
    file_path = f"{model_path}/images/{img_name}"
    csv_file_name = img_name.replace(".jpg", ".csv")
    hostname = socket.gethostname()

    if not os.path.exists(model_path):
        os.mkdir(model_path)

    if not os.path.exists(save_path):
        os.mkdir(save_path)

    with open(f"{save_path}/{csv_file_name}", 'w') as f:
        writer = csv.writer(f)
        writer.writerow([
            file_path,
            img_name,
            model_name,
            prediction,
            probability,
            confidence_dog,
            confidence_cat,
            start_timestamp,
            end_timestamp,
            hostname,
        ])

def save_result_to_image(img, img_name, model_name, prediction, probability):
    model_path = f"{OUTPUT_PATH}/{model_name}"
    save_path = f"{model_path}/images"

    if not os.path.exists(model_path):
        os.mkdir(model_path)

    if not os.path.exists(save_path):
        os.mkdir(save_path)

    plt.imshow(img)
    plt.title(f"{prediction} {probability}")
    plt.savefig(f"{save_path}/{img_name}")

def predict(model, model_name, img_path):
    start_time = time.time()
    start_timestamp = datetime.now().isoformat()
    img_name = os.path.basename(img_path)
    labels = ["dog", "cat"]
    transform = get_test_transforms()
    img = io.imread(img_path)
    test_img = Image.fromarray(img)
    test_img = transform(test_img)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    with torch.no_grad():
        model_result = model(test_img.unsqueeze(0).to(device))
        probabilities = torch.nn.functional.softmax(model_result[0], dim=0)
        result = model_result[0].cpu().numpy()
        prediction_index = np.argmax(result)
        probability = float(probabilities[prediction_index])
        prediction = labels[prediction_index]
        confidence_dog = float(result[0])
        confidence_cat = float(result[1])
        probability_formatted = "{:.4f}%".format(probability * 100)

    save_result_to_image(img, img_name, model_name, prediction, probability_formatted)

    end_time = time.time()
    end_timestamp = datetime.now().isoformat()

    save_result_to_csv(
        img_name,
        model_name,
        prediction,
        probability,
        confidence_dog,
        confidence_cat,
        start_timestamp,
        end_timestamp,
    )

    print(f"{'{:.4f}'.format(end_time - start_time)}s - PREDICT {img_path} -> {probability_formatted} {prediction}")

def load_model(model_path):
    start_time = time.time()

    if not os.path.exists(model_path):
        print(f"Could not find the model at {model_path}. Skipped inferencing.")
        exit(0)

    trial = pytorch.load_trial_from_checkpoint_path(model_path)
    model = trial.model
    model.eval()
    print(f"{'{:.4f}'.format(time.time() - start_time)}s - LOAD MODEL {model_path}")

    return model

def make_prediction(model_path, file_paths):
    start_time = time.time()
    model = load_model(model_path)
    model_name = os.path.basename(model_path)

    for file_path in file_paths:
        predict(model, model_name, file_path)

    print(f"{'{:.4f}'.format(time.time() - start_time)}s - PREDICT MODEL {model_path}")

def get_file_paths():
    file_paths = []

    for dirpath, dirs, files in os.walk(PREDICT_PATH):
        for file in files:
            if not file.endswith(".jpg"):
                continue
            file_paths.append(os.path.join(dirpath, file))

    return file_paths

def get_model_paths():
    model_paths = []

    for dirpath, dirs, files in os.walk(MODELS_PATH):
        for dir in dirs:
            model_paths.append(os.path.join(dirpath, dir))
        break # We are only interested in top level directories

    return model_paths

def make_predictions():
    start_time = time.time()
    file_paths = get_file_paths()
    model_paths = get_model_paths()

    for model_path in model_paths:
        make_prediction(model_path, file_paths)

    print(f"{'{:.4f}'.format(time.time() - start_time)}s - PREDICTIONS")

make_predictions()
