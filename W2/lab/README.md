# W2 Take-home Lab

**Inspect and clean text → build a corpus → inspect tokens and phrases → count and compare features.** Ungraded self-study practice; no submission. The lab includes the original worked examples and 11 practice exercises.

## Start here

1. Extract the [lab ZIP](../downloads/week2-lab.zip).
2. Open **[Lab_Session_W2.R](Lab_Session_W2.R)** in RStudio or Positron and read [the HTML handout](Lab_Session_W2.html) alongside it.
3. Install the packages once using the commented `install.packages()` command in the setup block. Use R 4.1 or newer.
4. Run the package and data setup blocks. They locate the data or ask you to select `hc_sample_1945_2025.rds` inside `W2/lab/Data`.
5. Keep the same R session open and run sections 1–4 in order. Attempt the exercises before opening [the worked answers](answers/Lab_Session_W2_Answers.html).

Keep `Data/` in its supplied location. No earlier lab, Python, language model, or API is needed. You do not need to render the QMD. In class, we check setup; the full lab is self-study. Bring questions to instructor or TA hours.

## The four sections

| Section | What you do |
|---|---|
| 1. Text and metadata | Search for patterns, use regular expressions, and clean agenda labels. |
| 2. Corpus | Store text with metadata, select speeches, and inspect sentence units. |
| 3. Tokens and phrases | Tokenize, compound selected phrases, and use KWIC to inspect context. |
| 4. Feature counts | Build and trim DFMs, plot frequencies, compare parties, and inspect a feature over time. |

The 11 exercises reuse these steps. Exercise 5 follows 4; exercises 10–11 follow 9. Read the output after each block. A running script alone does not complete the unsolved exercises.

## Files

| Location | Purpose |
|---|---|
| `Lab_Session_W2.html` | Student handout |
| `Lab_Session_W2.R` | Student code and unsolved exercises |
| `answers/` | HTML and R worked answers |
| `source/` | Editable QMD files for instructors |
| `Data/` | The supplied 5,000-speech House of Commons sample, 1945–2025 |

Figures are embedded in the HTML files, so students do not need separate image folders. Earlier Markdown handouts and their figures are preserved in the local instructor archive outside the lab.

## Packages and code

```r
# Run once before starting.
install.packages(c("dplyr", "stringr", "ggplot2", "quanteda",
                   "quanteda.textstats", "quanteda.textplots"))
```

The handout explains assignment, selecting columns and the native `|>` pipe. Examples use ready-made functions from these packages. `knitr` and `rmarkdown` are needed only to rebuild the teaching materials, not to run the student R script.

W2 prepares and explores text. W4 reuses the corpus and functions to construct and evaluate dictionary measures.

## Sources and editing

Adapted for NTU's *Text as Data* course from Martijn Schoonvelde (2026), *QTA Lab 02: String Operations and Inspecting the House of Commons Corpus*, acknowledging earlier materials by Stefan Müller. The original analytical examples and 11 exercises are retained, with revised setup, navigation and output explanations.

For instructors: edit `source/`, run `Rscript W2/scripts/publish_lab.R` from the course root, then `python3 W2/scripts/render_lab.py` and `python3 W2/scripts/build_lab_bundle.py`. These local build tools keep student and answer outputs in their respective locations.
