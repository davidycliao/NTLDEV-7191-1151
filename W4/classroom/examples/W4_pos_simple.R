# Standalone POS example. No C01 or workflow.R required.
# The model is saved in udpipe_models under your current working directory.
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

# Optional: retain candidate nouns, adjectives and verbs.
candidates <- subset(ann, upos %in% c("NOUN", "ADJ", "VERB"))
candidates[, c("token", "lemma", "upos")]
