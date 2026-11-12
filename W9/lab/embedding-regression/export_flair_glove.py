#!/usr/bin/env python3
"""Export one fixed static GloVe vocabulary through Flair, without downloading.

Run the R baseline first. Only WordEmbeddings is used; a contextual language
model cannot turn an arbitrary concatenated vocabulary into a static table.
"""

import argparse
import csv
import hashlib
import importlib.metadata
import json
from pathlib import Path
import sys


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path,
                        default=Path.home() / ".flair/embeddings/glove.gensim")
    parser.add_argument("--input-dir", type=Path,
                        default=Path(__file__).resolve().parent / "input")
    args = parser.parse_args()
    model_path = args.model.expanduser().resolve()
    companion = Path(str(model_path) + ".vectors.npy")
    vocabulary = args.input_dir / "fixed-vocabulary.csv"
    if not model_path.is_file() or not companion.is_file():
        parser.error("Cached GloVe and its .vectors.npy file are required. No download is attempted.")
    if not vocabulary.is_file():
        parser.error("Run embedding_regression_lab.R --baseline to export the fixed vocabulary first.")

    import flair
    import numpy as np
    import torch
    from flair.data import Sentence
    from flair.embeddings import WordEmbeddings

    flair.device = torch.device("cpu")
    model = WordEmbeddings(str(model_path), force_cpu=True)
    if model.embedding_length != 100:
        parser.error("This route requires cached 100-dimensional static GloVe.")
    with vocabulary.open(newline="", encoding="utf-8") as stream:
        words = [row["word"] for row in csv.DictReader(stream)]
    if len(words) != len(set(words)):
        parser.error("Duplicate vocabulary rows.")
    vectors = []
    oov = []
    for word in words:
        # One exact token per Sentence. No contextual model or artificial context.
        sentence = Sentence([word], use_tokenizer=False)
        model.embed(sentence)
        if len(sentence) != 1 or sentence[0].text != word:
            raise ValueError(f"Token alignment failed for {word!r}")
        vector = sentence[0].embedding.detach().cpu().numpy().copy()
        if not np.isfinite(vector).all():
            raise ValueError(f"Non-finite embedding for {word!r}")
        if np.linalg.norm(vector) == 0:
            oov.append(word)
        else:
            vectors.append((word, vector))
        sentence.clear_embeddings()
    target = args.input_dir / "flair-glove100-vectors.csv"
    with target.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["word"] + [f"dim{i}" for i in range(1, 101)])
        for word, vector in vectors:
            writer.writerow([word] + [format(float(x), ".17g") for x in vector])
    metadata = {
        "python": sys.version.split()[0],
        "packages": {name: importlib.metadata.version(name)
                     for name in ("flair", "torch", "numpy", "gensim")},
        "class": "flair.embeddings.WordEmbeddings", "representation": "static GloVe",
        "dimension": 100, "requested_words": len(words), "exported_words": len(vectors),
        "oov_words": oov, "tokenization": "one exact token per Sentence; use_tokenizer=False",
        "cache_name": model_path.name, "model_sha256": sha256(model_path),
        "vectors_file_sha256": sha256(companion), "fixed_vocabulary_sha256": sha256(vocabulary),
        "export_sha256": sha256(target), "network": "no download; local cache only",
        "transform": "not exported by Python; R must recompute a matching 100x100 transform",
    }
    with (args.input_dir / "flair-glove100-metadata.json").open("w", encoding="utf-8") as stream:
        json.dump(metadata, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    print(f"Exported {len(vectors)} of {len(words)} words x 100 dimensions to {target}")
    print(f"OOV words: {oov}")
    print("Next: Rscript embedding_regression_lab.R --flair100")


if __name__ == "__main__":
    main()
