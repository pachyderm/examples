import kserve
import spacy
from typing import Dict

class WineClassifier(kserve.Model):
    def __init__(self, name: str):
       super().__init__(name)
       self.name = name
       self.nlp = spacy.load("wine_model/model-best")
       self.load()

    def load(self):
        pass

    def predict(self, request: Dict) -> Dict:
        doc = self.nlp(request['description'])
        return doc.cats
        

if __name__ == "__main__":
    model = WineClassifier("custom-model")
    kserve.ModelServer().start([model])
