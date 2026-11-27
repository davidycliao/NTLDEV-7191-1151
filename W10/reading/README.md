# W10 readings · Classification and NLI applications

Read the [brief application guide](applications.html) alongside the slides. Each paper has a continuous three-page sequence: an original first-page excerpt with a short introduction, followed by two pages of application evidence and substantive analysis.

## Classification: three cases

| Case | Main application | Read with the slides |
|---|---|---|
| **1 · Liao & Tang (2026)** | Geographically targeted oversight | [Case 1](../slide/week10.html#/liao-tang-paper-intro) · [Article](https://doi.org/10.1016/j.electstud.2025.103026) |
| **2 · Schöll, Gallego & Le Mens (2024)** | Feedback and attention to gender issues | [Case 2](../slide/week10.html#/scholl-paper-intro) · [Article](https://doi.org/10.1111/ajps.12772) |
| **3 · Bestvater & Monroe (2023)** | Women's March: VADER, fine-tuned BERT and human stance | [Case 3](../slide/week10.html#/bestvater-paper-intro) · [Article](https://doi.org/10.1017/pan.2022.10) |

For each case, identify the text unit, the human label, the classifier's output and the research measure built from the labels. Case 3 compares VADER dictionary sentiment, BERT fine-tuned on human stance labels, and the human reference for the Women's March. The NLI applications follow separately.

## NLI: two separate applications

- **Laurer et al. (2024), Political Analysis:** category statements, NLI training and target-task fine-tuning. [Slides](../slide/week10.html#/laurer-paper-intro) · [Article](https://doi.org/10.1017/pan.2023.20).
- **Burnham (2025), Political Science Research and Methods:** matched hypotheses and stance detection in COVID-19 tweets. [Slides](../slide/week10.html#/burnham-paper-intro) · [Article](https://doi.org/10.1017/psrm.2024.35).

Keep the text–hypothesis relation separate from the final research label. Record whether target-task labels update the model and how the label rule is validated.

## Lab materials

After the [Lab divider](../slide/week10.html#/lab-transition), use the [English Lab handout](../lab/Lab_Session_W10.html) and the two supplied notebooks:

- [2024_qta_lab_week_12_flair.ipynb](../lab/notebooks/2024_qta_lab_week_12_flair.ipynb)
- [2024_qta_lab_week_12_transformer.ipynb](../lab/notebooks/2024_qta_lab_week_12_transformer.ipynb)

The single English handout starts with packages and shared data, then integrates both Irish environmental-policy classification approaches. Detailed Lab slides follow **Read class-specific performance**, with code on the left and explanations on the right. A final [NLI exercise](../lab/Lab_Session_W10.html#nli-demo) adapts Burnham's official Trump-stance tutorial using three constructed texts. It reuses an existing model without target-task fitting. These teaching data are separate from the article corpora and the paper's COVID-19 replication.
