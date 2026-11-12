"""Prepare imports and the local GloVe path, without loading a model.

From this folder: .venv/bin/python -i flair_prepare.py
Then run the three sections in flair_steps.py in the same interpreter.
"""
import os
from pathlib import Path

import flair
import numpy as np
import torch
from flair.data import Sentence
from flair.embeddings import WordEmbeddings
from flair_lab import print_versions

flair.device = torch.device("cpu")
torch.set_num_threads(1)
flair.set_seed(2026)
glove_path = Path(os.environ.get("W9_FLAIR_GLOVE_PATH") or
                  Path(flair.cache_root) / "embeddings" / "glove.gensim")
glove_path = glove_path.expanduser().resolve()
if not glove_path.is_file():
    raise FileNotFoundError("Preload GloVe before class, or set W9_FLAIR_GLOVE_PATH.")
print_versions()
print("Imports OK. Device: CPU.")
print(f"Cached model file: {glove_path}")
print("Ready for Step 1: load the model.")
