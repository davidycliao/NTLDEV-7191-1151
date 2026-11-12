# W9 teaching inputs

`w9_speeches.rds` is a byte-identical copy of `W8/analysis/ess_lab/sample_raw.rds`: 719 complete speeches, 359 Conservative and 360 Labour, dated 1979-05-15 to 2025-12-17. Original wording, punctuation, stable `doc_id`, source URLs and metadata are retained. The original course input is Schoonvelde's ESS QTA 2026 material; the upstream file in this repository is `W8/classroom/Data/ess_hoc_leader_sample.rds`.

W8 selected nonempty speeches with original `terms >= 80`, then sampled at most 30 speeches per party × election-period stratum with seed 20261028. One stratum has 29 speeches. This is a nearly balanced teaching sample, not a representative sample of parliamentary speaking volume. `source_terms` differs from the token counts produced by a new preprocessing recipe.

`w9_glove.rds` contains a plain numeric matrix and metadata, prepared by `W9/scripts/prepare_embeddings.R`. It has 1,653 word types × 30 dimensions. The illustrative fit uses five iterations, seed 20260706, one thread and a five-position window. Removed tokens retain padded positions, and a window never crosses a speech boundary; sentence boundaries are not enforced. It combines main and context vectors. Minimum term count is 10 and minimum document frequency is 2.

The saved model is supplied so that class time covers word neighbours, original contexts, document averages and coverage rather than fitting. It is trained on this small teaching sample and produces visibly noisy neighbours. It is not a validated semantic measure, a contextual transformer model, or a conText/ALC estimate. Training metadata and software versions are recorded in `W9/analysis/embedding_training.json`; inputs and checkpoint results are hashed in `W9/analysis/run_metadata.json`.

The classroom script uses original text for readability and a separate, explicitly stated representation for similarity. Do not apply readability formulas to the stopword-removed text.
