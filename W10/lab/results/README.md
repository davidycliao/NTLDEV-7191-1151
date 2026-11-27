# Printed Lab outputs and sources

## Course-material source

The supplied [Flair notebook](../notebooks/2024_qta_lab_week_12_flair.ipynb) and [Transformers notebook](../notebooks/2024_qta_lab_week_12_transformer.ipynb) are *Quantitative Text Analysis Lab Session: Week 12*, by **Yen-Chieh Liao and Stefan Müller**, dated **22 April 2024**. Their cells, saved outputs and required dataset files are unchanged. The dataset metadata do not identify a corpus citation or license; this attribution identifies the course materials.

## Preparation checks · 27 November 2026

These checks did not load a pretrained encoder, fit a classifier or generate predictions:

- [environment.txt](environment.txt): installed packages and the device available to the preparation process. Check the trainer log for the device actually used in your own training run.
- [shared-data.txt](shared-data.txt): supplied split sizes, class counts and label IDs.
- [training-example.txt](training-example.txt): the full first training excerpt and its supplied reference label.
- [flair-preparation.txt](flair-preparation.txt): the excerpt as a labeled Flair Sentence and the training-only label dictionary.

The [optional lecture warmup](../Lab_Session_W10.html#lecture-warmup) also records checked tokenizer output for “My dog is cute. He likes playing.” It shows all 11 tokens, their positions and vocabulary IDs, using Transformers 4.54.0 and the `bert-base-uncased` tokenizer. It loads tokenizer files only.

Save the version output from your own active notebook kernel with your run.

## Stored model records · 2024

These reports were extracted from the original notebooks without retraining:

- [flair-2024-report.txt](flair-2024-report.txt): Flair notebook, zero-based cell 19, execution counter 11, output 14. The log is dated 19 April 2024 and reports CPU, although an earlier availability check reports MPS.
- [transformers-2024-report.txt](transformers-2024-report.txt): Transformers notebook, zero-based cell 25, execution counter 31, output 1. F1, precision and recall are macro averages. Its training-argument cell lists learning rate `0.3`; the revised guide uses `5e-5`.

The model reports describe the original runs, rather than the revised guide's code. The original Transformers file stores no per-class report or row-level test predictions; generate these in your own run. Its later prediction uses `qta_toy_model` with inconsistent saved-path records, so it is not attached to the earlier test report.

The two approaches use different encoders and training settings. Their scores do not isolate a software-library effect. A zero-based cell position is different from its saved execution counter.

## Executed NLI demonstration · 27 November 2026

[burnham-nli-demo.txt](burnham-nli-demo.txt) records new inference on three constructed teaching texts, using the existing `MoritzLaurer/DeBERTa-v3-large-mnli-fever-anli-ling-wanli` checkpoint at revision `b3546ea6b0346eb6f8d5d68b13c7dc6d0376b3d7`. The run used CPU float32, PyTorch 2.2.2, Transformers 4.54.0 and SentencePiece 0.1.99. No weights were updated.

The model, template and candidates follow [Burnham's official Trump-stance tutorial](https://github.com/MLBurnham/stance_detection_tutorials/blob/main/Zero-shot_stance_detection.ipynb); the three short inputs were written for this class. The [NLI notebook](../notebooks/Burnham_NLI_demo.ipynb) and [guide](../Lab_Session_W10.html#nli-demo) show the matching code. This is separate from the policy-classifier records above and the paper's COVID-19 replication.

With `multi_label=False`, the pipeline normalizes entailment logits across the candidate hypotheses. These are stance-candidate scores, not accuracy or the full three-relation NLI distribution. Text C's top score is only .5970; inspect the alternatives and validate any review rule on human-labeled target texts. Three constructed examples do not establish research performance.
