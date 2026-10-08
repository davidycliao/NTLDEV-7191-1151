# W4 Take-home Lab

**Read a dictionary → change a rule and rerun → inspect errors → check test results.** Allow 45–60 minutes for the four core tasks, with extra time for beginners. Ungraded practice; no submission.

## Start here

1. Extract the [lab ZIP](../downloads/week4-lab.zip).
2. Open **[Lab_Session_W4.R](Lab_Session_W4.R)** in RStudio and read [the handout](Lab_Session_W4.html) alongside it.
3. First use only: run `install.packages("quanteda")`. Use R 4.1 or newer.
4. Run the entire setup block once. It finds the lab folder or asks you to select `workflow.R` inside the extracted `W4/lab` folder.
5. Keep the same R session open and run sections 1–4 in order. Compare [the worked answers](answers/Lab_Session_W4_Answers.html) after trying each task.

Keep `workflow.R`, `Data/` and `Dictionaries/` in their supplied locations. Setup loads the data; you do not need to run W2 first or edit the preparation functions. No LIWC purchase, model download or API is required. You do not need to render the QMD.

## The four tasks

| Task | What you do |
|---|---|
| 1. Read a dictionary | Inspect a small LIWC-format list and see why `not good` still matches `good`. |
| 2. Modify an energy-policy rule | Replace an ambiguous word, rerun matching, and compare the old and revised results. |
| 3. Inspect development errors | Find irrelevant matches and missed relevant sentences. |
| 4. Check the fixed v2 | Calculate precision, recall and F1 on the teaching test examples. |

Your experimental dictionary is `energy_revised`. The supplied `energy_v2` stays unchanged so that the worked validation results remain reproducible. The handout includes the three human-labeling rules; no separate coding guide is needed.

The parliamentary sample contains 5,000 real speech contributions with no supplied human labels. The 24 validation sentences and their labels are course-designed examples. Their scores do not estimate performance on Parliament. The ten-word `.dic` is original teaching material, not the official LIWC lexicon.

## What can wait

- **Party comparison:** an optional section after the core tasks.
- **W6 preview:** read five development speeches and bring one difficult labeling decision (about 10 minutes). W5 is a holiday; W6 is October 16.
- **POS and TextRank:** use the separate [classroom materials](../classroom/README.md), not the take-home lab. Lecture scripts are kept outside this lab folder.
- **Full real-text validation:** deferred to W6.

## Files and sources

Start with the HTML handout and R script at the top of this folder:

| Location | Purpose |
|---|---|
| `Lab_Session_W4.html` | Student handout |
| `Lab_Session_W4.R` | Student code |
| `answers/` | Worked answers; open after trying the exercises |
| `source/` | Editable QMD files for instructors |
| `workflow.R` | Supplied preparation; run automatically by setup |
| `Data/`, `Dictionaries/` | Required inputs; keep these in place |

Classroom demonstrations and their model files live in `W4/classroom/`. Unused legacy materials are preserved outside the lab, in the local instructor archive. Students do not need to open them.

The examples use short steps and ready-made quanteda functions. Simple arithmetic explains score denominators and validation measures; students do not need to write functions or loops.

Selected activities draw on ESS materials by Martijn Schoonvelde (2026), acknowledging Stefan Muller. The corpus is reused from W2; small dictionaries and teaching sentences are course-designed. See the handout for readings and technical references.

For instructors: edit the QMD files in `source/`, regenerate the R companions with `Rscript W4/scripts/publish_lab.R` from the course root, run `python3 W4/scripts/render_lab.py`, then run `python3 W4/scripts/build_bundles.py`. The render script uses the lab working directory and places the HTML files in their student/answer locations.
