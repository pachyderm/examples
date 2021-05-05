import pandas as pd
import json


def load_finphrase(filename):
    """Clean FinancialPhrasebank data
    Input:
        - filename
    Output:
        - a dataframe for the loaded financial phase bank data
    """
    df = pd.read_csv(
        filename,
        engine="python",
        sep="\t",
        index_col=0,
        header=0,
        names=["index", "sentence", "label"],
    )
    print("Total number of record in the file: ", df.shape[0])
    df.drop_duplicates(inplace=True)
    print("Total number of record after dropping duplicates: ", df.shape[0])
    print("Missing label: ", df["label"].isnull().sum())
    df.reset_index(inplace=True, drop=True)
    # df = pd.get_dummies(df, columns=['label'])
    return df


def df_to_ls(df):
    """Clean FinancialPhrasebank data
    Input:
        - dataframe: (sentence, label)
    Output:
        - json lines file with a single record per row
    """
    ls_dataset = []
    for i, row in df.iterrows():
        ls_dataset.append(
            {
                "data": {"text": row["sentence"]},
                "predictions": [
                    {
                        "result": [
                            {
                                "value": {"choices": [row["label"].capitalize()]},
                                "from_name": "sentiment",
                                "to_name": "text",
                                "type": "choices",
                            }
                        ],
                        "score": 1.0,
                    }
                ],
            }
        )

    print("\n".join(map(json.dumps, ls_dataset)))
    return "\n".join(map(json.dumps, ls_dataset))
