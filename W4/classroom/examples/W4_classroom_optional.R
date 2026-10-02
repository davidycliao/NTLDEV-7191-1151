# W4 classroom activities. Select one numbered block at a time.
# Scheduled student route: C01, C04, C07, C10, C11, C14.
# Finish with examples/W4_campaign_simple.R; C16 is an alternative or self-study.
# Other blocks are instructor demonstrations or self-study; do not source all.
# Blocks follow the slides; IDs stay fixed, so C15 follows C12.
# C06 requires C03 (recap_dfm); C15 requires C12 (dev).
# Use R >= 4.1; install these packages once before class:
# install.packages(c("quanteda", "quanteda.textstats"))
# Optional C13 only: install.packages("irr")
# Optional C15 only: install.packages("ggplot2")
# C01 detects common classroom paths. If asked, choose classroom/workflow.R.
# Keep Data, Dictionaries and workflow.R together; extract the ZIP first.
# <- saves an object; $ selects a column; [rows, columns] selects table cells.
# head(x, 6) displays the first six rows; TRUE/FALSE describe a condition.
# source("workflow.R") runs the supplied preparation, not a package function.
# C02, C07 and C13 run independently; C16 needs only the classroom working directory.
# All core activities run locally after installation. No API key is required.
# Tiny constructed examples teach arithmetic; real speeches have no gold labels.
# These are course exercises, not replications of the assigned paper results.
# Source: slide/week4-presenter.qmd; regenerate with scripts/publish_classroom.py.
# O01 is standalone; O02 requires C01. Select one block at a time.
# O01 needs install.packages("udpipe") and a first-time model download.

# Predict POS tags first; inspect rather than silently correct predictions.
# O01: POS candidates (model download on first run)
# install.packages("udpipe")  # run once before class
library(udpipe)
dir.create("udpipe_models", showWarnings = FALSE)
info <- udpipe_download_model("english-ewt",
  model_dir = "udpipe_models", overwrite = FALSE)
model <- udpipe_load_model(info$file_model)
text <- "Housing costs are unaffordable."
annotation <- udpipe_annotate(model, x = text, parser = "none")
ann <- as.data.frame(annotation)
ann[, c("token", "lemma", "upos")]

# Add one expression; show a supporting passage and a possible error.
# O02: Your own dictionary (run C01 first)
my_dict <- dictionary(list(energy = c("energy", "gas bills")))
matched <- tokens_lookup(discovery_tokens, my_dict)
my_dfm <- dfm(matched)
my_counts <- as.numeric(my_dfm[, "energy"])
sum(my_counts > 0)
my_context <- kwic(discovery_tokens, "energy", window = 6)
head(my_context, 3)
