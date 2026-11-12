# Prepare the R/Python connection only. No embedding model is loaded here.
# Source this file in a clean R session before running flair_steps.R by section.

flair_source_files <- Filter(Negate(is.null),
  lapply(sys.frames(), function(frame) frame$ofile))
flair_script_argument <- grep("^--file=", commandArgs(), value = TRUE)
flair_prepare_file <- if (length(flair_source_files)) {
  tail(flair_source_files, 1)[[1]]
} else if (length(flair_script_argument)) {
  sub("^--file=", "", flair_script_argument[[1]])
} else {
  stop("Source flair_prepare.R from its saved file.")
}
flair_dir <- dirname(normalizePath(flair_prepare_file, mustWork = TRUE))
source(file.path(flair_dir, "flair_lab.R"))
run_w9_flair("check")

Sentence <- flaiR::flair_data()$Sentence
WordEmbeddings <- flaiR::flair_embeddings()$WordEmbeddings
flair <- flaiR::import_flair()
glove_path <- Sys.getenv("W9_FLAIR_GLOVE_PATH", unset = "")
if (!nzchar(glove_path)) {
  glove_path <- file.path(reticulate::py_str(flair$cache_root),
    "embeddings", "glove.gensim")
}
glove_path <- path.expand(glove_path)
if (!file.exists(glove_path)) {
  stop("Preload GloVe before class, or set W9_FLAIR_GLOVE_PATH.")
}
cat("Cached model file:", glove_path, "\n")
cat("Ready for Step 1: load the model.\n")
