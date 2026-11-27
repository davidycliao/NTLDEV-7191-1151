# W10 Lab: Transformer classification and NLI

Classify Irish policy excerpts as environmental policy or other policy with Flair and Hugging Face Transformers.

Then compare this supervised workflow with a separate zero-shot NLI exercise: classify three constructed texts for stance toward Trump, using the model and hypothesis template from Burnham's official tutorial.

- [Integrated Lab guide](Lab_Session_W10.html)
- [Optional lecture warmup](Lab_Session_W10.html#lecture-warmup): read tokens, positions and vocabulary IDs before training.
- [Original Flair notebook](notebooks/2024_qta_lab_week_12_flair.ipynb)
- [Original Transformers notebook](notebooks/2024_qta_lab_week_12_transformer.ipynb)
- [NLI demonstration notebook](notebooks/Burnham_NLI_demo.ipynb)
- [Dataset and labels](notebooks/DATA.md)
- [Printed outputs and sources](results/README.md)

## Start here

1. Open the HTML guide. Check the packages, versions and available device before training.
2. Open `notebooks/` in your Python notebook environment. Keep `irish_environmental_policies/` beside the two supplied notebooks.
3. Create a working notebook in that folder and follow the guide's shared setup and data cells.
4. Follow Approach A (Flair) or Approach B (Transformers). Complete both before comparing their predictions on the same text.
5. Use validation during model selection and reserve test for the final evaluation. Read class-specific recall and F1 alongside accuracy.
6. Open `Burnham_NLI_demo.ipynb` for Section 6. It runs independently without training either policy classifier. Read the full hypotheses, inspect all candidate scores and explain each predicted stance using its text.

The guide contains the installation command and corrected training code. The two original notebooks retain their 2024 cells and saved outputs unchanged; adapt a working copy rather than overwriting them. Both use the supplied train, validation and test splits.

## Read the outputs

Preparation printouts were checked on **27 November 2026**. Supervised policy-model scores are **stored 2024 notebook records**; neither policy model was retrained to prepare them. The original Transformers file has no per-class test report or paired test predictions. Generate these outputs in your own run. Keep the separate NLI inference outputs apart from those historical policy-model scores.

The notebooks use different encoders and training settings, so their saved scores do not isolate a software-library effect. Save your own package versions, device, settings and results with your working notebook.

## NLI exercise

The added notebook adapts [Burnham's official zero-shot stance tutorial](https://github.com/MLBurnham/stance_detection_tutorials/blob/main/Zero-shot_stance_detection.ipynb) using three short classroom examples. It loads `MoritzLaurer/DeBERTa-v3-large-mnli-fever-anli-ling-wanli`, pairs each text with three complete stance hypotheses and ranks those hypotheses without target-task training. Check `sentencepiece` is installed; the first model-loading call may download the checkpoint.

The task is Trump stance, not the paper's full COVID-19 replication. The three reading keys illustrate the intended categories; they are not a research validation set. Candidate scores are not accuracy, and the “does not express an opinion” stance candidate is not NLI `neutral`. Follow the guide's distinction between supervised policy labels, NLI relations and final stance labels.

The NLI printout records actual CPU inference on **27 November 2026**, separately from the original supervised notebook scores. It uses the recorded checkpoint revision without target-task training. Text C's winning score is about `.597`, so inspect all candidate scores and the full text. [Executed NLI printout](results/burnham-nli-demo.txt).
