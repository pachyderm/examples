import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt
from IPython.display import display
from sklearn.utils import shuffle
from sklearn.metrics import (
    f1_score,
    accuracy_score,
    classification_report,
    confusion_matrix,
)
import math
import seaborn as sns


def bin_cut(df, col, bin_range):
    """Specify customized bin range for discretization.

    RETURN:
                    target_bin: dataframe of original target value and binned target value.

    """
    target_bin = pd.cut(
        df[col].astype("float"), bin_range, duplicates="drop"
    )  # drop off bins with the same index, incur less bin number

    print("Share of Each Bin:")
    bin_share = target_bin.groupby(target_bin).agg(
        {"size": lambda x: x.size, "share": lambda x: x.size / len(target_bin)}
    )
    display(bin_share)

    map_class = {}
    for i, key in enumerate(sorted(target_bin.unique())):
        map_class[key] = i
    print("Bin and Class Label Correspondence:")
    display(map_class)

    target_bin_2 = target_bin.replace(map_class)
    target_bin = pd.concat([target_bin, target_bin_2], axis=1)
    target_bin.columns = ["{}_bin".format(col), "{}_class".format(col)]

    print("\nPreview of return dataframe:")
    display(target_bin.head())

    return target_bin


def concat_str_col(df, *cols, return_col_name="Text", sep_punc=" /// "):
    """
    Concatenate multiple string columns,
    and return df with the concatenated column.

    :param df: dataframe
    :param cols: names of columns
    :param return_col_name: returned concatenated column name
    :param sep_punc: separate punctuation for each column
    :return:
                    df: dataframe including concatenated column
    """

    column = cols[0]
    df[return_col_name] = df[column].apply(lambda x: x.strip())

    for column in cols[1:]:
        df[return_col_name] = df[[return_col_name, column]].apply(
            lambda col: sep_punc.join(col.astype(str).str.strip()), axis=1
        )

    return df


# Plot frequency.
def plot_freq(df, col, top_classes=20):
    """
    :param df: dataframe
    :param col: list of label string
    :param top_classes: (integer) Plot top labels only.
    """
    sns.set_style("whitegrid")

    col = col
    data = df[~df[col].isnull().any(axis=1)]
    data = data.set_index(col)

    # Check out the frequency over each concept.
    freq = pd.DataFrame(
        {
            "freq": data.index.value_counts(normalize=True),
            "count": data.index.value_counts(normalize=False),
        },
        index=data.index.value_counts(normalize=True).index,
    )
    print("Frequency(Top {})...".format(top_classes))
    freq = freq[:top_classes]
    display(freq)

    # Plot bar chart.
    fig, ax = plt.subplots(1, 1, figsize=(15, 8))
    _ = freq.plot(y="freq", kind="bar", ax=ax, legend=False, colormap="Set2")
    _ = ax.set_ylabel("frequency", fontsize="x-large")
    _ = ax.set_xticklabels(freq.index.values, rotation=40, ha="right")
    _ = ax.set_title("Frequency over Each Class", fontsize="x-large")
    return fig


# Create sampling dataset.
def split(df, col, col_val, train_num, valid_num, test_num):
    """
    :param col: string
    :param col_val: string
    :return:
                    train: dataframe
                    valid: dataframe
                    test: dataframe
    """
    df = df[df[col] == col_val]
    df = shuffle(df, random_state=1)  # shuffle dataset
    train = df.iloc[:train_num, :]
    valid = df.iloc[train_num : train_num + valid_num, :]
    test = df.iloc[train_num + valid_num : train_num + valid_num + test_num, :]
    return train, valid, test


def df2list(text_df, label_df):
    ls_ = [
        (text_df.iloc[i], {"cats": label_df.iloc[i].to_dict()})
        for i in range(len(text_df))
    ]
    return ls_


# Evaluate the model.
def evaluate(nlp, texts, labels, label_names):
    """
    :param nlp: spacy nlp object
    :param texts: list of sentences
    :param labels: dictionary of labels
    :param label_names: list of label names
    """
    label_names = label_names
    true_labels = []
    pdt_labels = []
    docs = [nlp.tokenizer(text) for text in texts]
    textcat = nlp.get_pipe("textcat")
    for j, doc in enumerate(textcat.pipe(docs)):
        true_series = pd.Series(labels[j]["cats"])
        true_label = (
            true_series.idxmax()
        )  # idxmax() is the new version of argmax()
        true_labels.append(true_label)

        pdt_series = pd.Series(doc.cats)
        pdt_label = pdt_series.idxmax()
        pdt_labels.append(pdt_label)
    score_f1 = f1_score(
        true_labels, pdt_labels, average="weighted", zero_division=1
    )
    score_ac = accuracy_score(true_labels, pdt_labels)
    f1_scores = "f1 score: {:.3f}\taccuracy: {:.3f}".format(score_f1, score_ac)

    class_report = classification_report(
        true_labels,
        pdt_labels,
        target_names=label_names,
        zero_division=1,
        output_dict=True,
    )
    return f1_scores, class_report


def wide2long(df, map_ls):
    """
    Wide dtaframe to long series.

    :param df: dataframe
    :param map_ls: dictionary of (key,value) mapping
    :return:
                    series_: series
    """
    dic_ = df.apply(lambda row: row.to_dict(), axis=1)
    series_ = pd.Series(
        [map_ls[pd.Series(dic_[i]).argmax()] for i in range(len(dic_))]
    )
    return series_


def sk_evaluate(model, feature, label, label_names):
    pred = model.predict(feature)
    true = np.array(label)

    print("Score on dataset...\n")
    print("Confusion Matrix:\n", confusion_matrix(true, pred))
    print(
        "\nClassification Report:\n",
        classification_report(true, pred, target_names=label_names),
    )
    print("\naccuracy: {:.3f}".format(accuracy_score(true, pred)))
    print("f1 score: {:.3f}".format(f1_score(true, pred, average="weighted")))

    return pred, true


def split_size(df, train=0.5, valid=0.3):
    train_size = math.floor(len(df) * train)
    valid_size = math.floor(len(df) * valid)
    test_size = len(df) - train_size - valid_size
    return train_size, valid_size, test_size


def load_data(input_csv, target_col):
    data = pd.read_csv(input_csv, header=0)
    targets = data[target_col]
    features = data.drop(target_col, axis=1)
    return data, features, targets


def show_values(pc, fmt="%.2f", **kw):
    """
    Heatmap with text in each cell with matplotlib's pyplot
    Source: https://stackoverflow.com/a/25074150/395857
    By HYRY
    """
    from itertools import izip

    pc.update_scalarmappable()
    ax = pc.get_axes()
    # ax = pc.axes# FOR LATEST MATPLOTLIB
    # Use zip BELOW IN PYTHON 3
    for p, color, value in izip(
        pc.get_paths(), pc.get_facecolors(), pc.get_array()
    ):
        x, y = p.vertices[:-2, :].mean(0)
        if np.all(color[:3] > 0.5):
            color = (0.0, 0.0, 0.0)
        else:
            color = (1.0, 1.0, 1.0)
        ax.text(x, y, fmt % value, ha="center", va="center", color=color, **kw)


def cm2inch(*tupl):
    """
    Specify figure size in centimeter in matplotlib
    Source: https://stackoverflow.com/a/22787457/395857
    By gns-ank
    """
    inch = 2.54
    if type(tupl[0]) == tuple:
        return tuple(i / inch for i in tupl[0])
    else:
        return tuple(i / inch for i in tupl)


def heatmap(
    AUC,
    title,
    xlabel,
    ylabel,
    xticklabels,
    yticklabels,
    figure_width=40,
    figure_height=20,
    correct_orientation=False,
    cmap="RdBu",
):
    """
    Inspired by:
    - https://stackoverflow.com/a/16124677/395857
    - https://stackoverflow.com/a/25074150/395857
    """

    # Plot it out
    fig, ax = plt.subplots()
    # c = ax.pcolor(AUC, edgecolors='k', linestyle= 'dashed', linewidths=0.2, cmap='RdBu', vmin=0.0, vmax=1.0)
    c = ax.pcolor(
        AUC, edgecolors="k", linestyle="dashed", linewidths=0.2, cmap=cmap
    )

    # put the major ticks at the middle of each cell
    ax.set_yticks(np.arange(AUC.shape[0]) + 0.5, minor=False)
    ax.set_xticks(np.arange(AUC.shape[1]) + 0.5, minor=False)

    # set tick labels
    # ax.set_xticklabels(np.arange(1,AUC.shape[1]+1), minor=False)
    ax.set_xticklabels(xticklabels, minor=False)
    ax.set_yticklabels(yticklabels, minor=False)

    # set title and x/y labels
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)

    # Remove last blank column
    plt.xlim((0, AUC.shape[1]))

    # Turn off all the ticks
    ax = plt.gca()
    for t in ax.xaxis.get_major_ticks():
        t.tick1On = False
        t.tick2On = False
    for t in ax.yaxis.get_major_ticks():
        t.tick1On = False
        t.tick2On = False

    # Add color bar
    plt.colorbar(c)

    # Add text in each cell
    show_values(c)

    # Proper orientation (origin at the top left instead of bottom left)
    if correct_orientation:
        ax.invert_yaxis()
        ax.xaxis.tick_top()

    # resize
    fig = plt.gcf()
    # fig.set_size_inches(cm2inch(40, 20))
    # fig.set_size_inches(cm2inch(40*4, 20*4))
    fig.set_size_inches(cm2inch(figure_width, figure_height))


def plot_classification_report(
    classification_report, title="Classification report ", cmap="RdBu"
):
    """
    Plot scikit-learn classification report.
    Extension based on https://stackoverflow.com/a/31689645/395857
    """
    lines = classification_report.split("\n")

    classes = []
    plotMat = []
    support = []
    class_names = []
    for line in lines[2 : (len(lines) - 2)]:
        raw = line[33:]
        name = line[:33].strip()
        t = raw.strip().split()
        t.insert(0, name)
        if len(t) < 2:
            continue
        classes.append(t[0])
        v = [float(x) for x in t[1 : len(t) - 1]]
        support.append(int(t[-1]))
        class_names.append(t[0])
        plotMat.append(v)

    print("plotMat: {0}".format(plotMat))
    print("support: {0}".format(support))

    xlabel = "Metrics"
    ylabel = "Classes"
    xticklabels = ["Precision", "Recall", "F1-score"]
    yticklabels = [
        "{0} ({1})".format(class_names[idx], sup)
        for idx, sup in enumerate(support)
    ]
    print(yticklabels)
    print(np.array(plotMat, dtype=object))
    figure_width = 25
    figure_height = len(class_names) + 7
    correct_orientation = False
    sns.heatmap(
        np.array(plotMat, dtype=object),
        title,
        xlabel,
        ylabel,
        xticklabels,
        yticklabels,
        figure_width,
        figure_height,
        correct_orientation,
        cmap=cmap,
    )


def write_classification_report(report, output_dir):
    plt.figure(figsize=(6, 20))
    hmap = sns.heatmap(pd.DataFrame(report).iloc[:-1, :].T, annot=True)
    hmapgfig = hmap.get_figure()
    hmapgfig.savefig(
        os.path.join(output_dir, "test_plot_classif_report.png"),
        dpi=200,
        format="png",
        bbox_inches="tight",
    )
