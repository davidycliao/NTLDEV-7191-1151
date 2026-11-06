# W8 Lab: two complete topic-model analyses

Use the same sample of **719 complete speeches** for both analyses. Open [W8_lab.Rproj](../W8_lab.Rproj) in RStudio, then [classroom/W8.R](../classroom/W8.R). Start one fresh R session and run the steps in order.

| Analysis | What you do | Evidence to report |
|---|---|---|
| **LDA** | Read texts, clean words, build the DFM, estimate topics, read words and complete mixtures | A provisional label, an original quotation and a possible challenge |
| **STM** | Add party and period, estimate topics, compare raw and adjusted party differences, plot intervals | Direction and size in percentage points, uncertainty and a supported conclusion |

Install **quanteda, quanteda.textstats, seededlda, stm, dplyr, tidyr, ggplot2 and jsonlite** before class. The seededlda package provides the ordinary LDA estimator in this lab. No keyword-guidance exercise is included.

The R script builds one count matrix and fits both LDA and STM. The supplied alternative fits support the optional K diagnostic.

## Route

- **Before class:** R00 packages and project folders.
- **Together:** R01 → R02 → R03a–R03b and E02 → R05a–R05e and E05.
- **After class:** E01, E03 and R03c–R04c/E04 on party summaries and K diagnostics.

The full lab has **19 steps and five exercises**. The guided classroom route remains **37 minutes**: 17 for preparing texts, LDA and E02; 15 for STM and E05; 5 for interpretation. Every slide uses one Code/Output tabset. Next shows the output on that same slide. The Research design link after R05e leads to the closing activity.

Read the [student handout](Lab_Session_W8.html) and run [W8.R](../classroom/W8.R). The [student Lab ZIP](../downloads/week8-lab.zip) includes the complete folder structure, input speeches, analysis script, optional diagnostic fits and HTML handout. The instructor answer edition is distributed separately.

The prepared sample preserves whole original speeches and source IDs. It is approximately balanced by party and period; it does not represent all parliamentary speaking time. Labels require original-text checks. Party comparisons describe associations, and training perplexity does not establish conceptual validity or an optimal K.

Rendering the editable QMD under `lab/source` displays captured outputs without refitting. The R script itself performs the analysis.
