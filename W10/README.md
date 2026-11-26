# W10 · Transformers: Concepts and Applications

Text as Data · National Taiwan University · Fall 2026 (115-1)

## Materials

- [Slides](slide/week10.html) · [Slide PDF](slide/week10.pdf)
- [Reading guide](reading/README.md) · [Brief article applications](reading/applications.html)
- [Lab handout](lab/Lab_Session_W10.html) · [Student Lab package](downloads/week10-lab.zip)
- Original Lab notebooks: [Flair](lab/notebooks/2024_qta_lab_week_12_flair.ipynb) · [Hugging Face Transformers](lab/notebooks/2024_qta_lab_week_12_transformer.ipynb)

## Teaching sequence

1. **Transformer basics:** tokens, positions, self-attention, Q/K/V, encoder layers, attention masks, pretraining and task fine-tuning.
2. **Classification applications:** [Case 1 · Liao & Tang](slide/week10.html#/liao-tang-paper-intro), [Case 2 · Schöll et al.](slide/week10.html#/scholl-paper-intro), and [Case 3 · Bestvater & Monroe, *Sentiment is Not Stance*](slide/week10.html#/bestvater-paper-intro).
3. **NLI applications:** paired text and hypotheses, the three NLI relations, and the separate [Laurer (PA)](slide/week10.html#/laurer-paper-intro) and [Burnham (PSRM)](slide/week10.html#/burnham-paper-intro) applications.
4. **Lab:** after the [Lab divider](slide/week10.html#/lab-transition), use the two supplied 2024 notebooks with the shared Irish environmental-policy dataset.

Each article has one continuous three-page sequence: a short introduction with the original first page, followed by two pages on measurement, published evidence and substantive interpretation. Use **→ / ←** to follow the focus boxes. Slides and Lab instructions are in English.

## Notebook Lab

The [Lab handout](lab/Lab_Session_W10.html) integrates `2024_qta_lab_week_12_flair.ipynb` and `2024_qta_lab_week_12_transformer.ipynb` by Yen-Chieh Liao and Stefan Müller (22 April 2024). Start with necessary packages and shared data, then work through Flair, Transformers and the same-text comparison. In the slides, the detailed code walkthrough follows **Read class-specific performance**: code on the left, short explanations on the right.

The environmental-policy task is a practical example of classification. The paper corpora are separate research applications. Saved notebook outputs belong to the original run; record the settings and results of any new run separately.

Printed output pages follow the related Lab code: environment, data/labels, Flair training history, Flair class report and Transformers macro metrics. [Output records](lab/results/README.md) distinguish current preparation checks from saved 2024 model records; no model was retrained for these pages.

Download the [Lab ZIP](downloads/week10-lab.zip) and extract it before starting. It contains the guide, two notebooks, required dataset, data notes and referenced output records. Open `notebooks/` as your working directory and follow the [Lab instructions](lab/README.md).
