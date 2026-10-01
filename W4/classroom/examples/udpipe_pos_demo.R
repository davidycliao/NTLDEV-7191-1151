# Optional W4 POS demonstration; sourcing defines the function without running it.
# The first call downloads a model; subsequent annotation is local. This is not NER.
udpipe_pos_demo <- function(
    model_dir = tools::R_user_dir("ntldev7191", "cache"),
    texts = c(costs = "Housing costs are unaffordable.",
              institution = "The minister praised the NHS.")) {
  if (!requireNamespace("udpipe", quietly = TRUE)) {
    stop("Install the R package first: install.packages('udpipe')")
  }
  stopifnot(is.character(texts), length(texts) > 0L, !anyNA(texts))
  dir.create(model_dir, recursive = TRUE, showWarnings = FALSE)
  model_info <- udpipe::udpipe_download_model(
    language = "english-ewt", model_dir = model_dir, overwrite = FALSE,
    udpipe_model_repo = "jwijffels/udpipe.models.ud.2.5")
  if (!file.exists(model_info$file_model)) {
    stop("Model download failed. Check the connection and model directory.")
  }
  model <- udpipe::udpipe_load_model(model_info$file_model)
  ids <- names(texts)
  if (is.null(ids)) ids <- paste0("doc", seq_along(texts))
  annotation <- udpipe::udpipe_annotate(
    model, x = unname(texts), doc_id = ids, parser = "none")
  annotation_table <- as.data.frame(annotation)
  annotation_table
}
