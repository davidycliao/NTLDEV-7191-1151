# W10 Lab: two notebooks, one classification task

Classify Irish policy excerpts as environmental policy or other policy with Flair and Hugging Face Transformers.

- [Integrated Lab guide](Lab_Session_W10.html)
- [Original Flair notebook](notebooks/2024_qta_lab_week_12_flair.ipynb)
- [Original Transformers notebook](notebooks/2024_qta_lab_week_12_transformer.ipynb)
- [Dataset and labels](notebooks/DATA.md)
- [Printed outputs and sources](results/README.md)

## Start here

1. Open the HTML guide. Check the packages, versions and available device before training.
2. Open `notebooks/` in your Python notebook environment. Keep `irish_environmental_policies/` beside the two supplied notebooks.
3. Create a working notebook in that folder and follow the guide's shared setup and data cells.
4. Follow Approach A (Flair) or Approach B (Transformers). Complete both before comparing their predictions on the same text.
5. Use validation during model selection and reserve test for the final evaluation. Read class-specific recall and F1 alongside accuracy.

The guide contains the installation command and corrected training code. The two original notebooks retain their 2024 cells and saved outputs unchanged; adapt a working copy rather than overwriting them. Both use the supplied train, validation and test splits.

## Read the outputs

Preparation printouts were checked on **27 November 2026**. Model scores are **stored 2024 notebook records**; no model was retrained to prepare these materials. The original Transformers file has no per-class test report or paired test predictions. Generate these outputs in your own run.

The notebooks use different encoders and training settings, so their saved scores do not isolate a software-library effect. Save your own package versions, device, settings and results with your working notebook.
