import os
from typing import Any, Dict, Sequence, Tuple, Union, cast

import torch
from torch import nn
from determined.pytorch import DataLoader, PyTorchTrial
from torchvision import models, transforms

from data import CatDogDataset, download_pach_repo
TorchData = Union[Dict[str, torch.Tensor], Sequence[torch.Tensor], torch.Tensor]


class CatDogModel(PyTorchTrial):
    def __init__(self, context):
        self.context = context
        self.download_directory = f"/tmp/data-rank{self.context.distributed.get_rank()}"
        self.data_dir = self.download_data()
        self.model = self.context.wrap_model(self.build_model())
        self.optimizer = self.context.wrap_optimizer(self.build_optimizer())

    def build_model(self) -> nn.Module:
        model = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
        model.fc = nn.Linear(2048, 2)

        return model

    def build_optimizer(self) -> torch.optim.Optimizer:  # type: ignore
        optimizer = torch.optim.SGD(
            self.model.parameters(),
            lr=float(self.context.get_hparam("learning_rate")),
            momentum=0.9,
            weight_decay=float(self.context.get_hparam("weight_decay")),
            nesterov=self.context.get_hparam("nesterov")
        )

        return optimizer

    def train_batch(
        self, batch: TorchData, epoch_idx: int, batch_idx: int
    ) -> Dict[str, torch.Tensor]:
        batch = cast(Tuple[torch.Tensor, torch.Tensor], batch)
        data, labels = batch

        output = self.model(data)
        loss = torch.nn.functional.cross_entropy(output, labels)

        self.context.backward(loss)
        self.context.step_optimizer(self.optimizer)

        return {"loss": loss}

    def evaluate_batch(self, batch: TorchData) -> Dict[str, Any]:
        batch = cast(Tuple[torch.Tensor, torch.Tensor], batch)
        data, labels = batch

        output = self.model(data)
        validation_loss = torch.nn.functional.cross_entropy(output, labels).item()
        pred = output.argmax(dim=1, keepdim=True)
        accuracy = pred.eq(labels.view_as(pred)).sum().item() / len(data)

        return {"vloss": validation_loss, "accuracy": accuracy}

    def download_data(self) -> str:
        data_config = self.context.get_data_config()
        data_dir = os.path.join(self.download_directory, 'data')
        pachyderm_host = data_config['pachyderm']['host']
        pachyderm_port = data_config['pachyderm']['port']

        download_pach_repo(
            pachyderm_host,
            pachyderm_port,
            data_config["pachyderm"]["project"],
            data_config["pachyderm"]["repo"],
            data_config["pachyderm"]["branch"],
            data_dir,
        )
        return data_dir

    def build_train_dataset(self):
        transform = transforms.Compose([
            transforms.Resize(240),
            transforms.RandomCrop(224),
            transforms.RandomHorizontalFlip(),
            transforms.ToTensor(),
            transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
        ])
        ds = CatDogDataset(self.data_dir, train=True, transform=transform)

        return ds

    def build_test_dataset(self):
        transform =  transforms.Compose([
            transforms.Resize(240),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
        ])

        ds = CatDogDataset(self.data_dir, train=False, transform=transform)

        return ds

    def build_training_data_loader(self) -> Any:
        ds = self.build_train_dataset()
        return DataLoader(ds, batch_size=self.context.get_per_slot_batch_size())

    def build_validation_data_loader(self) -> Any:
        ds = self.build_test_dataset()
        return DataLoader(ds, batch_size=self.context.get_per_slot_batch_size())
