import os
import shutil
import tarfile

import python_pachyderm
import torch
from PIL import Image

from skimage import io
from torchvision import transforms
from torch.utils.data import Dataset

class CatDogDataset(Dataset):
    """Face Landmarks dataset."""

    def __init__(self, root_dir, train, transform=None):
        """
        Args:
            csv_file (string): Path to the csv file with annotations.
            root_dir (string): Directory with all the images.
            transform (callable, optional): Optional transform to be applied
                on a sample.
        """
        if train:
            file_dir = 'train'
        else:
            file_dir = 'test'
        self.file_path = os.path.join(root_dir, file_dir)
        self.files = [f for f in os.listdir(self.file_path) if f.endswith('.jpg')]
        self.transform = transform

    def __len__(self):
        return len(self.files)

    def __getitem__(self, idx):
        if torch.is_tensor(idx):
            idx = idx.tolist()

        img_name = self.files[idx]
        image = io.imread(os.path.join(self.file_path, img_name))
        image = Image.fromarray(image)
        if self.transform:
            image = self.transform(image)
        label = 0 if img_name.startswith('dog') else 1
        sample = (image, label)
        return sample


def download_pach_repo(pachyderm_host, pachyderm_port, project, repo, branch, root):
    client = python_pachyderm.Client(host=pachyderm_host, port=pachyderm_port)
    commit = python_pachyderm.pfs.Commit(repo=repo, branch=branch, project=project)
    files = []
    fpaths = []

    if not os.path.exists(root):
        os.makedirs(root)
    for file in client.walk_file(commit, "/"):
        files.append(file)

    for i in range(len(files)):
        path = files[i].file.path
        fpath = os.path.join(root, path[1:])
        if files[i].file_type == 2:
            os.makedirs(fpath, exist_ok=True)
        else:
            fpaths.append((path, fpath))
    for path, fpath in fpaths:
        source_file = client.get_file(commit, path)

        with open(fpath, "wb") as dest_file:
            shutil.copyfileobj(source_file, dest_file)

        if fpath.endswith('.tar.gz'):
            tarfile.open(fpath).extractall(path=root)
