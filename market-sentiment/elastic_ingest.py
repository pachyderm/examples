import os
import argparse
import json

from elasticsearch import Elasticsearch
from elasticsearch.client import CatClient
from elasticsearch import RequestsHttpConnection
from numpy import argmax

parser = argparse.ArgumentParser(
    description="Pull predictions from Seldon (via Elastic Search)"
)
parser.add_argument("--host", help="Host IP address")
parser.add_argument("--index", help="Seldon inference log index in Elastic Search")
parser.add_argument(
    "--output",
    help="Output directory to write the examples",
    default="./output",
)


def query_index(client, index):
    resp = client.search(index=index)
    return resp


def format_predictions(log_response):
    predictions = {}
    for r in log_response["hits"]["hits"]:
        if r["_type"] == "inferencerequest":
            id = r["_id"]
            jsonData = r["_source"]["response"]["payload"]["jsonData"]
            text = jsonData["text"]
            score_idx = argmax(jsonData["ndarray"])
            score = jsonData["ndarray"][score_idx]
            sentiment_class = jsonData["names"][score_idx]

            # Label Studio prediction format
            predictions[id] = {
                "data": {"text": text},
                "predictions": [
                    {
                        "result": [
                            {
                                "value": {"choices": [sentiment_class]},
                                "from_name": "sentiment",
                                "to_name": "text",
                                "type": "choices",
                            }
                        ],
                        "score": score,
                        "model_version": "dataset",
                    }
                ],
            }

    return predictions


def main():
    args = parser.parse_args()

    client = Elasticsearch(
        [args.host],
        http_auth=("admin", "admin"),
        scheme="https",
        port=9200,
        verify_certs=False,
    )

    query_results = query_index(client, args.index)
    predictions = format_predictions(query_results)

    # Save predictions to individual files
    for key, value in predictions.items():
        file_path = os.path.join(args.output, key + ".json")
        if not os.path.isfile(file_path):
            with open(file_path, "w") as f:
                json.dump(value, f)

if __name__ == "__main__":
    main()
