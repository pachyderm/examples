# Download MNIST dataset to directory
#
import argparse
import os
import torch

from torchvision import datasets, transforms


def main():
    # Training settings
    parser = argparse.ArgumentParser(description='Download MNIST Example')
    parser.add_argument('--data-location', type=str, 
                        default=os.path.join('.', 'data'),
                        help='For loading the dataset')

    args = parser.parse_args()

    torch.utils.data.DataLoader(
        datasets.MNIST(
            args.data_location,
            train=True,
            download=True,
            transform=transforms.Compose(
                [transforms.ToTensor(), transforms.Normalize((0.1307,), (0.3081,))]
            ),
        )
    )
    torch.utils.data.DataLoader(
        datasets.MNIST(
            args.data_location,
            train=False,
            download=True,
            transform=transforms.Compose(
                [transforms.ToTensor(), transforms.Normalize((0.1307,), (0.3081,))]
            ),
        )
    )

if __name__ == "__main__":
    main()
