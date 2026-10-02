"""Optional W4 Python demo: detect named entities with Flair.
Install once in a terminal: python -m pip install flair
Run this file with Python, not in the R console.
The first run downloads a model. The sentence is a teaching example.
Reference: https://flairnlp.github.io/flair/master/tutorial/tutorial-basics/tagging-entities.html
"""
from flair.data import Sentence
from flair.models import SequenceTagger

tagger = SequenceTagger.load("ner-fast")
sentence = Sentence(
    "Barack Obama spoke at the United Nations in New York.")
tagger.predict(sentence)
for entity in sentence.get_spans("ner"):
    print(entity.text, entity.get_label("ner").value)
