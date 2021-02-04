import argparse
import os
from os import path
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
from utils import load_data


parser = argparse.ArgumentParser(description="Structured data regression")
parser.add_argument("--input",
                    type=str,
                    help="csv file with all examples")
parser.add_argument("--target-col",
                    type=str,
                    default="MEDV",
                    help="column with target values")
parser.add_argument("--output",
                    metavar="DIR",
                    default='./output',
                    help="output directory")

def create_pairplot(data):
    plt.clf()
    # Calculate and show pairplot
    sns.pairplot(data, height=2.5)
    plt.tight_layout()

def create_corr_matrix(data):
    plt.clf()
    # Calculate and show correlation matrix
    sns.set()
    corr = data.corr()
    
    # Generate a mask for the upper triangle
    mask = np.triu(np.ones_like(corr, dtype=np.bool))

    # Generate a custom diverging colormap
    cmap = sns.diverging_palette(220, 10, as_cmap=True)

    # Draw the heatmap with the mask and correct aspect ratio
    sns_plot = sns.heatmap(corr, mask=mask, cmap=cmap, vmax=.3, center=0,
                square=True, linewidths=.5, annot=True, cbar_kws={"shrink": .5})


def main():
    args = parser.parse_args()
    if os.path.isfile(args.input):
        input_files = [args.input]
    else:  # Directory
        for dirpath, dirs, files in os.walk(args.input):  
            input_files = [ os.path.join(dirpath, filename) for filename in files if filename.endswith('.csv') ]
    print("Datasets: {}".format(input_files))
    os.makedirs(args.output, exist_ok=True)

    for filename in input_files:
        file_basename = os.path.basename(os.path.splitext(filename)[0])
        # Data loading 
        data, _, _ = load_data(filename, args.target_col)

        # Data Analysis
        create_pairplot(data)
        plt.savefig(path.join(args.output, file_basename + '_pairplot.png'))
        create_corr_matrix(data)
        plt.savefig(path.join(args.output, file_basename + '_corr_matrix.png'))

if __name__ == "__main__":
    main()