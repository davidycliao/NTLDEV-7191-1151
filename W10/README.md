# W10 · Transformers: Concepts and Applications

Text as Data · National Taiwan University · Fall 2026 (115-1)

## Materials

- [Slides](slide/week10.html) · [Slide PDF](slide/week10.pdf)
- [Reading guide](reading/README.md) · [Brief article applications](reading/applications.html)
- [Lab handout](lab/Lab_Session_W10.html) · [Editable Lab QMD](lab/Lab_Session_W10.qmd) · [Student Lab package](downloads/week10-lab.zip)
- Original Lab notebooks: [Flair](lab/notebooks/2024_qta_lab_week_12_flair.ipynb) · [Hugging Face Transformers](lab/notebooks/2024_qta_lab_week_12_transformer.ipynb)

## Teaching sequence

1. **Transformer basics:** tokens, positions, self-attention, Q/K/V, encoder layers, pretraining and task fine-tuning.
2. **Classification applications:** [Case 1 · Liao & Tang](slide/week10.html#/liao-tang-paper-intro), [Case 2 · Schöll et al.](slide/week10.html#/scholl-paper-intro), and [Case 3 · Bestvater & Monroe, *Sentiment is Not Stance*](slide/week10.html#/bestvater-paper-intro).
3. **NLI applications:** paired text and hypotheses, the three NLI relations, and the separate [Laurer (PA)](slide/week10.html#/laurer-paper-intro) and [Burnham (PSRM)](slide/week10.html#/burnham-paper-intro) applications.
4. **Lab:** after the [Lab divider](slide/week10.html#/lab-transition), use the two supplied 2024 notebooks with the shared Irish environmental-policy dataset. Then compare that supervised workflow with the [NLI stance demonstration](lab/Lab_Session_W10.html#nli-demo).

Each article has one continuous three-page sequence: a short introduction with the original first page, followed by two pages on measurement, published evidence and substantive interpretation. Use **→ / ←** to follow the focus boxes. Slides and Lab instructions are in English.

For the dog example, [read the attention connections](slide/week10.html#/attention-connections) alongside the [Lab warmup](lab/Lab_Session_W10.html#lecture-warmup).

## Notebook Lab

The [Lab handout](lab/Lab_Session_W10.html) integrates `2024_qta_lab_week_12_flair.ipynb` and `2024_qta_lab_week_12_transformer.ipynb` by Yen-Chieh Liao and Stefan Müller (22 April 2024). Start with necessary packages and shared data. An optional warmup uses “My dog is cute. He likes playing.” to connect tokens, positions and pretraining to the lecture. Then work through Flair, Transformers and the same-text comparison. In the slides, the detailed code walkthrough follows **Read class-specific performance**: code on the left, short explanations on the right.

The environmental-policy task demonstrates supervised classification. A separate NLI exercise adapts Burnham's official Trump-stance tutorial: pair three constructed texts with complete hypotheses, reuse an existing NLI model, and inspect the ranked candidate scores. Both methods use Transformers; their inputs and target-task training differ. Neither exercise uses the paper corpora.

Printed output pages follow the related Lab code. [Output records](lab/results/README.md) distinguish preparation checks, saved 2024 supervised-model results, and the new NLI inference recorded on 27 November 2026. No model was retrained to prepare these outputs. The three NLI teaching examples are not an accuracy benchmark or the paper's COVID-19 replication.

Download the [Lab ZIP](downloads/week10-lab.zip) and extract it before starting. It contains the guide, two original notebooks, the NLI demonstration notebook, required dataset, data notes and referenced outputs. Open `notebooks/` as your working directory and follow the [Lab instructions](lab/README.md).
