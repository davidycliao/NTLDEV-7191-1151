# W9 Lab · Flair and conText

[Lab HTML](Lab_Session_W9.html) · [Lab ZIP](../downloads/week9-lab.zip) · [Student Lab slides](../slide/week9.html#/work-with-719-parliamentary-speeches) · [Complete conText R script](../classroom/W9-conText.R)

We read a short core call, switch to **Output on the same slide**, and explain the result. Multiple output highlights advance with the right arrow. The handout includes saved outputs and full runnable code in folded sections, so we can follow the interpretation or run the example in a prepared environment.

The guide on slides **77–79** runs **17:31–17:35**, followed by the **17:35–17:40 break**. This guide is separate from the thirty-minute practical Lab.

| Time | Slides | Work |
|---|---|---|
| **17:40–17:55** | **81–85** | Flair: load GloVe, get eleven word vectors, compare security, read the same-run 2D/3D PCA figures. |
| **17:55–18:10** | **86–91** | conText: inputs, immigration contexts, ALC vectors, neighbours, passages and embedding regression. |

## Before class

Prepare Python, packages and the model cache using [F00](Lab_Session_W9.html#f00-prepare-python-and-the-model). We use a clean R session for Flair and a separate R session for conText. If R cannot connect to Python, use the Python route or follow the saved results.

- [R preparation](flair/flair_prepare.R) · [R three-step script](flair/flair_steps.R)
- [Python preparation](flair/flair_prepare.py) · [Python three-step script](flair/flair_steps.py) · [Requirements](flair/requirements.txt)

## First fifteen minutes · Flair

The exercise adapts [our original 2024 Week 11 Lab](reference/2024_qta_lab_week_11.html).

1. **Slide 81:** check the environment and cached model path.
2. **Slide 82:** load the pretrained 100-dimensional GloVe model.
3. **Slide 83:** obtain an **11 × 100** matrix for the word list.
4. **Slide 84:** compare three security occurrences in a **3 × 100** matrix. Static lookup gives the same vector, so the pairwise cosines are 1.
5. **Slide 85:** read the 2D/3D PCA figures. PC1 and PC2 retain **38.24%** of standardized variance; projection distances and full-space cosine are different comparisons.

**E06:** explain both matrix sizes and why security receives identical vectors in different sentences. The PCA question asks what the projection leaves out. Full PCA recalculation remains after class.

## Second fifteen minutes · conText

We use the [official Quick Start](https://github.com/prodriguezsosa/conText/blob/master/vignettes/quickstart.md) and [W9-conText.R](../classroom/W9-conText.R).

1. **86 · C00:** 400 US congressional texts, 500 × 300 word vectors and a matched 300 × 300 transformation.
2. **87 · C01:** extract 924 immigration contexts with source metadata; one occurrence is one row.
3. **88 · C02:** create 924 × 300 ALC vectors, then two descriptive party means.
4. **89 · C03:** interpret the nearest words to each party mean.
5. **90 · C04:** read nearby processed contexts. The candidate pool contains both parties.
6. **91 · C05:** estimate `immigration ~ party + gender` and interpret the party comparison holding gender fixed.

**E04:** explain one ALC observation, connect a neighbour to a context, and interpret the conditional party coefficient. The package demonstration's debiased squared norms differ from the original article's L2 lengths. Neighbours and passages help explain a comparison; one selected passage does not estimate how frequent a use is.

At **18:10**, continue to [research design on slide 92](../slide/week9.html#/design-an-embedding-study-in-one-paragraph). Four main cases and the full 110-minute class are retained.

## After class

[Supplement](../handout/Word_Embeddings_Supplement.html) · [A01–A04](After_Class_W9.html) · [Advanced A05](Embedding_Regression_W9.html)

The [earlier handout](Lab_Session_W9_earlier.html) and [R00–R06 script](../classroom/W9.R) retain optional readability, count/TF–IDF, keyness, local 30-dimensional GloVe and coverage exercises. These use a different corpus and model from the current conText example.
