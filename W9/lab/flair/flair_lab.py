#!/usr/bin/env python3
"""Static GloVe extraction and PCA adapted from the 2024 UCD QTA Week 11 Lab.

Source: Yen-Chieh Liao and Stefan Müller, 2024_qta_lab_week_11_solutions.qmd.
Flair API: https://flairnlp.github.io/docs/tutorial-embeddings/classic-word-embeddings
"""

import argparse
import csv
from importlib.metadata import PackageNotFoundError, version
from itertools import combinations
from pathlib import Path
import sys


WORD_LIST = "King Queen man woman Paris London apple orange Taiwan Dublin Bamberg"
CONTEXTS = [
    "Social security supports households.",
    "The United Nations Security Council met.",
    "Energy security matters for jobs.",
]


def cosine_matrix(vectors):
    """Return cosine similarities, leaving zero-vector comparisons undefined."""
    import numpy as np

    vectors = np.asarray(vectors, dtype=float)
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    unit = np.divide(vectors, norms, out=np.full_like(vectors, np.nan), where=norms > 0)
    return unit @ unit.T


def standardized_pca(vectors):
    """Match R prcomp(center=TRUE, scale.=TRUE) using sample standard deviations."""
    import numpy as np

    vectors = np.asarray(vectors, dtype=float)
    centered = vectors - vectors.mean(axis=0)
    scales = vectors.std(axis=0, ddof=1)
    scaled = np.divide(centered, scales, out=np.zeros_like(centered), where=scales > 0)
    left, singular_values, _ = np.linalg.svd(scaled, full_matrices=False)
    if np.sum(singular_values ** 2) == 0:
        raise ValueError("PCA needs variation among the selected word vectors.")
    scores = left[:, :3] * singular_values[:3]
    variance_shares = singular_values ** 2 / np.sum(singular_values ** 2)
    return scores, variance_shares[:3]


def print_versions():
    print(f"Python {sys.version.split()[0]} at {sys.executable}")
    for package in ("flair", "torch", "numpy", "matplotlib", "gensim"):
        try:
            print(f"{package} {version(package)}")
        except PackageNotFoundError:
            print(f"{package} is not installed")


def write_csv(path, header, rows):
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(header)
        writer.writerows(rows)


def save_outputs(output_dir, words, vectors, scores, shares, context_vectors, comparisons):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    output_dir.mkdir(parents=True, exist_ok=True)
    write_csv(output_dir / "word-vectors.csv", ["word"] + [f"dim{i+1}" for i in range(vectors.shape[1])],
              ([word] + row.tolist() for word, row in zip(words, vectors)))
    write_csv(output_dir / "word-pca.csv", ["word", "PC1", "PC2", "PC3"],
              ([word] + row.tolist() for word, row in zip(words, scores)))
    write_csv(output_dir / "word-cosine.csv", ["word"] + words,
              ([word] + row.tolist() for word, row in zip(words, cosine_matrix(vectors))))
    write_csv(output_dir / "security-vectors.csv", ["sentence"] + [f"dim{i+1}" for i in range(vectors.shape[1])],
              ([text] + row.tolist() for text, row in zip(CONTEXTS, context_vectors)))
    write_csv(output_dir / "security-comparison.csv", ["sentence_a", "sentence_b", "equal_vectors", "cosine"],
              comparisons)

    figure, axis = plt.subplots(figsize=(8, 6), constrained_layout=True)
    points = axis.scatter(scores[:, 0], scores[:, 1], c=scores[:, 2], cmap="coolwarm")
    for word, row in zip(words, scores):
        axis.annotate(word, row[:2], xytext=(4, 4), textcoords="offset points")
    axis.set_xlabel(f"PC1 ({shares[0]:.1%} of standardized variance)")
    axis.set_ylabel(f"PC2 ({shares[1]:.1%} of standardized variance)")
    axis.set_title("GloVe word vectors from the QTA Week 11 example")
    axis.set_aspect("equal", adjustable="datalim")
    figure.colorbar(points, ax=axis, label="PC3")
    figure.savefig(output_dir / "word-pca.png", dpi=160)
    plt.close(figure)
    print(f"Saved vectors, comparisons and PCA plot to {output_dir.resolve()}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="Check imports without loading a model (default).")
    mode.add_argument("--version", action="store_true", help="Print installed package versions only.")
    mode.add_argument("--download-glove", action="store_true", help="Preload GloVe into the Flair cache; network may be used.")
    mode.add_argument("--run", action="store_true", help="Run with a locally cached GloVe model.")
    parser.add_argument("--model-path", type=Path, help="Local GloVe gensim file, with its companion vectors file.")
    parser.add_argument("--output-dir", type=Path, help="Save CSV files and a PCA PNG in this folder.")
    args = parser.parse_args()
    print_versions()
    if args.version:
        return

    try:
        import flair
        import gensim
        import numpy as np
        import torch
        from flair.data import Sentence
        from flair.embeddings import WordEmbeddings
    except Exception as error:
        parser.exit(1, f"Import check failed: {type(error).__name__}: {error}\n"
                       "Use the Python environment where the lab requirements were installed.\n")

    flair.device = torch.device("cpu")
    torch.set_num_threads(1)
    print("Imports OK. Device: CPU.")
    if not args.run and not args.download_glove:
        print("Check complete. Load a cached model with --run after preloading with --download-glove.")
        return
    if args.download_glove:
        model = WordEmbeddings("glove", force_cpu=True)
        print(f"GloVe ready: {model.embedding_length} dimensions; cache {flair.cache_root}")
        return

    model_path = args.model_path or Path(flair.cache_root) / "embeddings" / "glove.gensim"
    model_path = model_path.expanduser().resolve()
    if not model_path.is_file():
        parser.error(f"Local model missing at {model_path}. Run --download-glove first, or supply --model-path.")
    model = WordEmbeddings(str(model_path), force_cpu=True)
    print(f"Local model: {model_path}; {model.embedding_length} dimensions")

    sentence = Sentence(WORD_LIST)
    model.embed(sentence)
    words = [token.text for token in sentence]
    vectors = np.vstack([token.embedding.detach().cpu().numpy() for token in sentence])
    zero_words = [word for word, row in zip(words, vectors) if not np.any(row)]
    print(f"Word matrix: {vectors.shape[0]} tokens x {vectors.shape[1]} dimensions")
    print(f"OOV/zero-vector tokens: {zero_words}")
    print("First 20 coordinates of the first word:", np.round(vectors[0, :20], 4))
    word_cosines = cosine_matrix(vectors)
    print("Full-vector word cosine matrix:")
    print(f"{'word':10s}" + "".join(f"{word:>10s}" for word in words))
    for word, row in zip(words, word_cosines):
        print(f"{word:10s}" + "".join(f"{value:10.4f}" for value in row))
    if zero_words:
        parser.error("The selected words include OOV/zero vectors. Choose covered words before PCA.")
    scores, shares = standardized_pca(vectors)
    print("PCA scores (PC1, PC2, PC3):")
    for word, row in zip(words, scores):
        print(f"{word:10s} {row[0]:9.4f} {row[1]:9.4f} {row[2]:9.4f}")
    print(f"PC1 and PC2 retain {shares[:2].sum():.2%} of the standardized variance.")

    context_sentences = [Sentence(text) for text in CONTEXTS]
    model.embed(context_sentences)
    target_tokens = [next(token for token in sent if token.text.casefold() == "security")
                     for sent in context_sentences]
    context_vectors = np.vstack([token.embedding.detach().cpu().numpy() for token in target_tokens])
    print("Security OOV/zero-vector flags:", [not np.any(row) for row in context_vectors])
    similarities = cosine_matrix(context_vectors)
    comparisons = []
    for first, second in combinations(range(len(CONTEXTS)), 2):
        cosine = float(similarities[first, second])
        equal = None
        if np.isfinite(cosine):
            equal = np.array_equal(context_vectors[first], context_vectors[second])
        comparisons.append([CONTEXTS[first], CONTEXTS[second], equal, cosine])
        print(f"Sentences {first+1} and {second+1}: equal vectors={equal}, cosine={cosine:.6f}")
    print("Static GloVe reuses a word vector across these contexts. Read the sentences before interpreting a neighbour.")
    if args.output_dir:
        save_outputs(args.output_dir.expanduser(), words, vectors, scores, shares, context_vectors, comparisons)


if __name__ == "__main__":
    main()
