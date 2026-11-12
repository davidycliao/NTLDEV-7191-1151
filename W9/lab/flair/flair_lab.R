# W9 optional Flair exercise, adapted from UCD QTA Week 11 (15 April 2024).
# Rscript W9/lab/flair/flair_lab.R --check
# Rscript W9/lab/flair/flair_lab.R --embed
# In RStudio: source("W9/lab/flair/flair_lab.R"); run_w9_flair("check")
#
# Set W9_FLAIR_PYTHON to an existing environment's Python, or prepare .venv
# beside this script. Set W9_FLAIR_GLOVE_PATH for a local GloVe gensim file.
# The check and embedding modes use installed dependencies and cached files.
# Official sources verified 2026-11-11:
# https://github.com/davidycliao/flaiR/tree/e812c6192714c9252d0feb83408b5459bbcccdfc
# https://rstudio.github.io/reticulate/reference/use_python.html
# https://flairnlp.github.io/docs/tutorial-embeddings/classic-word-embeddings

run_w9_flair <- local({
  # Capture this file's location while it is being sourced or run by Rscript.
  source_files <- Filter(
    Negate(is.null),
    lapply(sys.frames(), function(frame) frame$ofile)
  )
  script_argument <- grep("^--file=", commandArgs(), value = TRUE)
  script_file <- if (length(source_files)) {
    tail(source_files, 1)[[1]]
  } else {
    sub("^--file=", "", script_argument[[1]])
  }
  script_dir <- dirname(normalizePath(script_file, mustWork = TRUE))

  function(mode = c("check", "embed")) {
    mode <- match.arg(mode)
    if (!requireNamespace("reticulate", quietly = TRUE)) {
      stop("Install reticulate before running this exercise.")
    }

    # Select Python before any module import. This also works from another cwd.
    python <- Sys.getenv("W9_FLAIR_PYTHON", unset = "")
    if (!nzchar(python)) python <- Sys.getenv("RETICULATE_PYTHON", unset = "")
    if (!nzchar(python)) {
      python <- file.path(
        script_dir, ".venv",
        if (.Platform$OS.type == "windows") "Scripts/python.exe" else "bin/python"
      )
    }
    python <- path.expand(python)
    if (!file.exists(python)) {
      stop("Create the local .venv or set W9_FLAIR_PYTHON to its Python executable.")
    }
    # Preserve the executable's symlink so a virtual environment stays selected.
    Sys.setenv(RETICULATE_PYTHON = python)
    reticulate::use_python(python, required = TRUE)
    python_config <- reticulate::py_config()

    # Namespace calls avoid flaiR's .onAttach environment-setup routine.
    if (!requireNamespace("flaiR", quietly = TRUE)) {
      stop("Install flaiR before running this exercise.")
    }
    flair <- flaiR::import_flair()
    flair_data <- flaiR::flair_data()
    flair_embeddings <- flaiR::flair_embeddings()
    torch <- reticulate::import("torch")
    metadata <- reticulate::import("importlib.metadata")
    reticulate::py_set_attr(flair, "device", torch$device("cpu"))
    torch$set_num_threads(1L)
    flair$set_seed(2026L)
    Sentence <- flair_data$Sentence

    cat("R", as.character(getRversion()), "\n")
    cat("flaiR", as.character(utils::packageVersion("flaiR")), "\n")
    cat("reticulate", as.character(utils::packageVersion("reticulate")), "\n")
    cat("Python executable", python_config$python, "\n")
    cat("Python version", as.character(python_config$version), "\n")
    for (package in c("flair", "torch", "numpy", "gensim", "transformers")) {
      cat(package, metadata$version(package), "\n")
    }
    check_sentence <- Sentence("Social security supports households.")
    cat("Tokenization", paste(
      vapply(check_sentence$tokens, function(token) token$text, character(1)),
      collapse = " | "
    ), "\n")
    cat("Device", reticulate::py_str(flair$device), "\n")

    if (mode == "embed") {
      # The Python companion's --download-glove mode can preload this cache.
      glove_path <- Sys.getenv("W9_FLAIR_GLOVE_PATH", unset = "")
      if (!nzchar(glove_path)) {
        glove_path <- file.path(
          reticulate::py_str(flair$cache_root), "embeddings", "glove.gensim"
        )
      }
      glove_path <- path.expand(glove_path)
      if (!file.exists(glove_path)) {
        stop(
          "Cached GloVe was not found. Run the Python companion with ",
          "--download-glove first, or set W9_FLAIR_GLOVE_PATH."
        )
      }
      WordEmbeddings <- flair_embeddings$WordEmbeddings
      embedding <- WordEmbeddings(glove_path)
      cat("GloVe file", glove_path, "\n")
      cat("Embedding dimensions", embedding$embedding_length, "\n")

      # F01 Reproduce the original exercise with pretrained static word vectors.
      word_sentence <- Sentence(
        "King Queen man woman Paris London apple orange Taiwan Dublin Bamberg"
      )
      embedding$embed(word_sentence)
      word_matrix <- do.call(rbind, lapply(
        word_sentence$tokens,
        function(token) as.numeric(token$embedding$detach()$cpu()$numpy())
      ))
      rownames(word_matrix) <- vapply(
        word_sentence$tokens, function(token) token$text, character(1)
      )
      cat("\nFirst six coordinates of each word\n")
      print(round(word_matrix[, 1:6, drop = FALSE], 4))
      word_norms <- sqrt(rowSums(word_matrix ^ 2))
      stopifnot(all(is.finite(word_norms)), all(word_norms > 0))
      word_unit <- word_matrix / word_norms
      cat("\nCosine among the original exercise words\n")
      print(round(tcrossprod(word_unit), 3))

      # F02 Keep the original Lab's centering and dimension-wise scaling.
      pca <- stats::prcomp(word_matrix, center = TRUE, scale. = TRUE)
      pca_scores <- pca$x[, 1:3, drop = FALSE]
      retained <- 100 * sum(pca$sdev[1:2] ^ 2) / sum(pca$sdev ^ 2)
      cat("\nFirst three PCA coordinates\n")
      print(round(pca_scores, 4))
      cat(sprintf("Variance retained by PC1 and PC2: %.2f%%\n", retained))
      # To draw in RStudio, run these two lines after saving the returned result:
      # plot(result$pca_scores[, 1:2], type = "n", xlab = "PC1", ylab = "PC2")
      # text(result$pca_scores[, 1:2], labels = rownames(result$pca_scores))
      # PCA axis signs may flip across software. Use original vectors for cosine.

      # F03 The three contexts share exactly the same static security vector.
      security_texts <- c(
        "Social security supports households.",
        "The United Nations Security Council met.",
        "Energy security matters for jobs."
      )
      security_sentences <- lapply(security_texts, Sentence)
      security_vectors <- lapply(security_sentences, function(sentence) {
        embedding$embed(sentence)
        tokens <- sentence$tokens
        labels <- vapply(tokens, function(token) token$text, character(1))
        index <- which(tolower(labels) == "security")
        stopifnot(length(index) == 1L)
        as.numeric(tokens[[index]]$embedding$detach()$cpu()$numpy())
      })
      security_matrix <- do.call(rbind, security_vectors)
      rownames(security_matrix) <- c("social", "UN_Council", "energy")
      security_norms <- sqrt(rowSums(security_matrix ^ 2))
      security_cosine <- tcrossprod(security_matrix / security_norms)
      cat("\nOriginal security contexts\n")
      print(data.frame(context = rownames(security_matrix), text = security_texts),
            row.names = FALSE)
      cat("\nCosine of the three security tokens\n")
      print(round(security_cosine, 6))
      max_difference <- max(abs(sweep(
        security_matrix, 2, security_matrix[1, ], FUN = "-"
      )))
      cat("Maximum coordinate difference", max_difference, "\n")
      stopifnot(max_difference < 1e-7)
      # Discuss which distinctions the three original sentences express.
      # A contextual token model is an extension to compare after this exercise.
      return(invisible(list(
        word_vectors = word_matrix, pca_scores = pca_scores,
        pca_variance_percent = retained, security_vectors = security_matrix,
        security_cosine = security_cosine
      )))
    }
    cat("Import check passed. Run embed mode after preparing the GloVe cache.\n")
    invisible(python_config)
  }
})

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = TRUE)
  if (length(arguments) > 1L ||
      (length(arguments) == 1L && !arguments %in% c("--check", "--embed"))) {
    stop("Usage: Rscript flair_lab.R [--check|--embed]")
  }
  run_w9_flair(if (length(arguments)) sub("^--", "", arguments) else "check")
}
