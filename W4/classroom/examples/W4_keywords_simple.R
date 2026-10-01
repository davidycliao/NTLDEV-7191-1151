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


# Install once if needed: install.packages("textrank")
library(textrank)
keep <- ann$upos %in% c("NOUN", "ADJ")
result <- textrank_keywords(ann$lemma, relevant = keep,
                           ngram_max = 2, sep = " ")
result$keywords
# keyword = selected word or phrase; ngram = number of words; freq = occurrences.
# These frequencies are not the PageRank scores. Inspect scores separately:
result$pagerank$vector

# OPTIONAL: grammatical relations require dependency parsing.
# Omit parser = "none" to use the model's dependency parser.
parsed <- udpipe_annotate(model, x = text)
relations <- as.data.frame(parsed)
relations[, c("token_id", "token", "head_token_id", "dep_rel")]
# Each token points to its head; dep_rel describes the predicted relation.
# Interpret IDs within each document and sentence. Head 0 marks the root.
# These are model predictions, not validated keyword or sentiment labels.
