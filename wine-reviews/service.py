import gradio as gr
import spacy
import os

model_dir = os.environ.get("MODEL_DIR", "wine_model/model-best")
flagged_dir = os.environ.get("FLAGGED_DIR", "flagged")

nlp = spacy.load(model_dir)


def remove_sort_dict(dictionary, x):
    new_dict = {k: v for k, v in dictionary.items() if v >= x}
    sorted_dict = dict(
        sorted(new_dict.items(), key=lambda item: item[1], reverse=True)
    )
    return sorted_dict


def wine(description):
    doc = nlp(description)
    results = remove_sort_dict(doc.cats, 0.05)
    return results


description = "This App will take a description of a wine and do our best guess at the type of wine it is."
demo = gr.Interface(
    fn=wine,
    inputs=gr.Textbox(lines=2, placeholder="Wine Description Here..."),
    outputs="label",
    flagging_dir=flagged_dir,
    title="Wine Varietal Identifier",
    description=description,
)

demo.launch(server_name="0.0.0.0", server_port=8000)
