# Printed Lab outputs and sources

## Course-material source

The supplied [Flair notebook](../notebooks/2024_qta_lab_week_12_flair.ipynb) and [Transformers notebook](../notebooks/2024_qta_lab_week_12_transformer.ipynb) are *Quantitative Text Analysis Lab Session: Week 12*, by **Yen-Chieh Liao and Stefan Müller**, dated **22 April 2024**. Their cells, saved outputs and required dataset files are unchanged. The dataset metadata do not identify a corpus citation or license; this attribution identifies the course materials.

## Preparation checks · 27 November 2026

These checks did not load a pretrained encoder, fit a classifier or generate predictions:

- [environment.txt](environment.txt): installed packages and the device available to the preparation process. Check the trainer log for the device actually used in your own training run.
- [shared-data.txt](shared-data.txt): supplied split sizes, class counts and label IDs.
- [training-example.txt](training-example.txt): the full first training excerpt and its supplied reference label.
- [flair-preparation.txt](flair-preparation.txt): the excerpt as a labeled Flair Sentence and the training-only label dictionary.

Save the version output from your own active notebook kernel with your run.

## Stored model records · 2024

These reports were extracted from the original notebooks without retraining:

- [flair-2024-report.txt](flair-2024-report.txt): Flair notebook, zero-based cell 19, execution counter 11, output 14. The log is dated 19 April 2024 and reports CPU, although an earlier availability check reports MPS.
- [transformers-2024-report.txt](transformers-2024-report.txt): Transformers notebook, zero-based cell 25, execution counter 31, output 1. F1, precision and recall are macro averages. Its training-argument cell lists learning rate `0.3`; the revised guide uses `5e-5`.

The model reports describe the original runs, rather than the revised guide's code. The original Transformers file stores no per-class report or row-level test predictions; generate these in your own run. Its later prediction uses `qta_toy_model` with inconsistent saved-path records, so it is not attached to the earlier test report.

The two approaches use different encoders and training settings. Their scores do not isolate a software-library effect. A zero-based cell position is different from its saved execution counter.
