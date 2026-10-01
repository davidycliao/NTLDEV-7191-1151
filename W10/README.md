# W10 case: Text classification and regression

[Student HTML](slide/liao-tang-case.html) · [PDF](slide/liao-tang-case.pdf) · [Student QMD](slide/liao-tang-case.qmd) · [Source ZIP](downloads/liao-tang-case-source.zip)

This is a **9-slide, 20-25 minute case module**, not a complete W10 lecture. It can follow the introduction to transformer classification; W6 can preview its human-coding and validation questions. W4 retains its dictionary-method focus. The required reading lists are unchanged.

## Paper

Liao, Yen-Chieh, and Li Tang. 2026. *Electoral systems and geographically targeted oversight: Evidence from the Taiwan Legislative Yuan*. Electoral Studies 99: 103026. [DOI](https://doi.org/10.1016/j.electstud.2025.103026) · [University of Birmingham record](https://research.birmingham.ac.uk/en/publications/electoral-systems-and-geographically-targeted-oversight-evidence-/) · [Open-access PDF](https://pure-oai.bham.ac.uk/ws/files/289618310/LiaoYC2025Electoral.pdf) · [BibTeX](supplementary.bib).

The citation year is 2026; the DOI and early online publication date refer to 2025. Images reproduce the published title/affiliations (p. 1), Table 1 coefficient panel (p. 6), and Figure 3 plot (p. 7), CC BY 4.0. They are cropped excerpts with no alterations to values. Local page numbers refer to the 12-page journal PDF, not the repository PDF's extra cover page.

## Teaching sequence

| Slides | Focus |
|---|---|
| 1-2 | Political research question and the published article |
| 3 | Fine-tuning on human-coded legislative texts |
| 4 | Validation when moving from legislation to questions |
| 5 | Aggregating predictions into a legislator-year outcome |
| 6-7 | Regression specification and reading the published table |
| 8 | Interpreting predictions over time |
| 9 | Measurement validity versus research-design validity |

The main teaching point is the full workflow: define a research construct, train a classifier, validate in the target corpus, construct a research variable, and evaluate the political hypothesis. Notes distinguish source-domain and target-domain metrics, confidence cutoffs and confidence intervals, questions and legislator-years, municipality and legislator fixed effects, and conditional coefficients in an interaction model.

This module explains the published analysis. It does **not** rerun training or regressions, include research data, or supply a trained checkpoint. The article's data-availability statement says data are available on request. A reproducible exercise would additionally need the data, model checkpoint and preprocessing details, annotation/threshold rules, and regression code. An introductory class can inspect pre-run predictions and published results without requiring students to train a transformer.

## Editing and compiling

The local instructor master is `slide/liao-tang-case-presenter.qmd`, with detailed speaker notes. Student QMD and HTML omit those notes. From the course root:

```sh
python3 W10/scripts/build_case.py prepare
quarto render W10/slide/liao-tang-case-presenter.qmd
quarto render W10/slide/liao-tang-case.qmd
python3 W10/scripts/build_case.py pdf
python3 W10/scripts/build_case.py bundle
```

The local build reuses the existing W2 note-removal function and W4 ReportLab formatting helpers. Its PDF is a separately typeset, searchable handout, not a browser print export. The student ZIP contains the source and required styles/images for HTML rendering; it excludes full papers, presenter notes, and local production scripts.
