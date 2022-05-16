""" pytorch-lightning example with W&B logging,with optional Pachyderm support. 

Based on: 
https://github.com/wandb/examples/blob/master/examples/pytorch-lightning/mnist.py

"""

import os
import argparse

import torch
from torch.nn import functional as F
from torch.utils.data import DataLoader
from torchvision import transforms
from torchvision.datasets import MNIST

import pytorch_lightning as pl
from pytorch_lightning.loggers import WandbLogger


class MNISTModel(pl.LightningModule):
    def __init__(self, data_location):
        super().__init__()
        # not the best model...
        self.data_location = data_location
        self.l1 = torch.nn.Linear(28 * 28, 10)

    def prepare_data(self):
        # download MNIST data only once
        MNIST(
            root=self.data_location,
            train=True,
            download=True,
            transform=transforms.ToTensor(),
        )
        MNIST(
            root=self.data_location,
            train=False,
            download=True,
            transform=transforms.ToTensor(),
        )

    def forward(self, x):
        # called with self(x)
        return torch.relu(self.l1(x.view(x.size(0), -1)))

    def training_step(self, batch, batch_nb):
        # REQUIRED
        x, y = batch
        y_hat = self(x)
        loss = F.cross_entropy(y_hat, y)
        self.log("train_loss", loss, on_step=True, on_epoch=False)
        return loss

    def validation_step(self, batch, batch_nb):
        # OPTIONAL
        x, y = batch
        y_hat = self(x)
        loss = F.cross_entropy(y_hat, y)
        self.log("val_loss", loss, on_step=False, on_epoch=True)

    def test_step(self, batch, batch_nb):
        # OPTIONAL
        x, y = batch
        y_hat = self(x)
        loss = F.cross_entropy(y_hat, y)
        self.log("test_loss", loss, on_step=False, on_epoch=True)

    def configure_optimizers(self):
        # REQUIRED
        # can return multiple optimizers and learning_rate schedulers
        # (LBFGS it is automatically supported, no need for closure function)
        return torch.optim.Adam(self.parameters(), lr=0.02)

    def train_dataloader(self):
        # REQUIRED
        return DataLoader(
            MNIST(
                root=self.data_location,
                train=True,
                transform=transforms.Compose(
                    [
                        transforms.ToTensor(),
                        transforms.Normalize((0.1307,), (0.3081,)),
                    ]
                ),
            ),
            shuffle=True,
            batch_size=32,
        )

    def val_dataloader(self):
        # OPTIONAL
        return DataLoader(
            MNIST(
                root=self.data_location,
                train=True,
                transform=transforms.Compose(
                    [
                        transforms.ToTensor(),
                        transforms.Normalize((0.1307,), (0.3081,)),
                    ]
                ),
            ),
            shuffle=True,
            batch_size=32,
        )

    def test_dataloader(self):
        # OPTIONAL
        return DataLoader(
            MNIST(
                root=self.data_location,
                train=False,
                transform=transforms.Compose(
                    [
                        transforms.ToTensor(),
                        transforms.Normalize((0.1307,), (0.3081,)),
                    ]
                ),
            ),
            shuffle=True,
            batch_size=32,
        )


def main():
    pipeline_name = str(os.getenv("PPS_PIPELINE_NAME", "None"))
    print("Pachyderm pipeline: ", pipeline_name)

    # Training settings
    parser = argparse.ArgumentParser(
        description="PyTorch Lightning MNIST Example"
    )
    parser.add_argument(
        "--data-location",
        type=str,
        default="/pfs/mnist/",
        help="For loading the dataset",
    )
    parser.add_argument(
        "--wandb-project",
        type=str,
        default="example-mnist-wandb",
        help="For loading the dataset",
    )

    args = parser.parse_args()

    # Connecting W&B with the current process,
    # From here on everything is logged automatically
    wandb_logger = WandbLogger(
        project=args.wandb_project, name=str(os.getenv("PACH_JOB_ID", "None"))
    )
    mnist_model = MNISTModel(args.data_location)
    trainer = pl.Trainer(gpus=0, max_epochs=5, logger=wandb_logger)
    trainer.fit(mnist_model)
    trainer.test(mnist_model)


if __name__ == "__main__":
    main()
