#!/usr/bin/env Rscript
# W9 after-class lab. Base R only; reads saved vectors, never loads a model.
# Run from the course root: Rscript W9/lab/after-class/after_class_lab.R
# Source this file to reuse the functions without running the example.

read_token_vectors <- function(path, token_column = NULL, id_column = NULL,
                               dimension_columns = NULL) {
  tab <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  if (!nrow(tab) || anyDuplicated(names(tab)))
    stop("CSV needs at least one row and unique column names.")
  if (is.null(token_column)) {
    candidates <- intersect(c("token", "word"), names(tab))
    if (!length(candidates)) stop("Specify token_column, or provide token/word.")
    token_column <- candidates[1L]
  }
  if (!token_column %in% names(tab)) stop("Token column was not found.")
  tokens <- as.character(tab[[token_column]])
  if (anyNA(tokens) || any(!nzchar(tokens))) stop("Tokens must be nonempty.")
  positions <- seq_len(nrow(tab))
  if ("position" %in% names(tab)) {
    positions <- suppressWarnings(as.numeric(tab$position))
    if (anyNA(positions) || any(!is.finite(positions)) ||
        any(positions < 1 | positions != floor(positions)) ||
        anyDuplicated(positions))
      stop("position must contain unique positive integers.")
  }
  if (is.null(id_column) && "id" %in% names(tab)) id_column <- "id"
  ids <- sprintf("row_%04d", seq_len(nrow(tab)))
  if (!is.null(id_column)) {
    if (!id_column %in% names(tab)) stop("ID column was not found.")
    ids <- as.character(tab[[id_column]])
    if (anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids))
      stop("IDs must be nonempty and unique; repeated tokens may have different IDs.")
  }
  if (is.null(dimension_columns)) {
    dimension_columns <- grep("^dim[0-9]+$", names(tab), value = TRUE)
    if (!length(dimension_columns)) {
      candidates <- setdiff(names(tab), c(token_column, id_column, "position", "id"))
      dimension_columns <- candidates[vapply(tab[candidates], is.numeric, logical(1))]
    }
  }
  if (!length(dimension_columns) || any(!dimension_columns %in% names(tab)) ||
      anyDuplicated(dimension_columns)) stop("Select existing, unique numeric dimensions.")
  if (!all(vapply(tab[dimension_columns], is.numeric, logical(1))))
    stop("Vector coordinates must be numeric.")
  vectors <- as.matrix(tab[dimension_columns])
  storage.mode(vectors) <- "double"
  if (any(!is.finite(vectors))) stop("Coordinates must be finite; resolve NA/Inf first.")
  rownames(vectors) <- ids
  rows <- data.frame(position = positions, token = tokens, id = ids,
                     stringsAsFactors = FALSE)
  list(rows = rows, vectors = vectors,
       input = normalizePath(path, winslash = "/", mustWork = TRUE),
       input_md5 = unname(tools::md5sum(path)), dimension_columns = dimension_columns)
}

full_cosine <- function(vectors) {
  norms <- sqrt(rowSums(vectors^2))
  known <- is.finite(norms) & norms > 0
  result <- matrix(NA_real_, nrow(vectors), nrow(vectors),
                   dimnames = list(rownames(vectors), rownames(vectors)))
  if (any(known)) {
    unit <- vectors[known, , drop = FALSE] / norms[known]
    result[known, known] <- pmax(-1, pmin(1, tcrossprod(unit)))
  }
  result
}

fit_token_pca <- function(data, center = TRUE, scale. = TRUE, max_components = 3L) {
  if (length(max_components) != 1L || !is.finite(max_components) || max_components < 1)
    stop("max_components must be a positive number.")
  norms <- sqrt(rowSums(data$vectors^2))
  usable <- which(norms > 0)
  rows <- data$rows[usable, , drop = FALSE]
  out <- list(status = "unavailable", rows = rows, scores = rows,
              center = center, scale = scale.,
              zero_vector_ids = data$rows$id[norms == 0],
              dropped_constant_dimensions = character(),
              rank = 0L, variance_share = numeric(), fit = NULL)
  if (length(usable) < 2L) {
    out$reason <- "PCA requires at least two nonzero token vectors."
    return(out)
  }
  x <- data$vectors[usable, , drop = FALSE]
  varying <- vapply(seq_len(ncol(x)), function(j) {
    diff(range(x[, j])) > 0
  }, logical(1))
  out$dropped_constant_dimensions <- colnames(x)[!varying]
  if (!any(varying)) {
    out$reason <- "All dimensions are constant across the usable tokens."
    return(out)
  }
  fit <- prcomp(x[, varying, drop = FALSE], center = center, scale. = scale.)
  tolerance <- max(dim(x)) * .Machine$double.eps * max(fit$sdev)
  rank <- sum(fit$sdev > tolerance)
  if (!rank) {
    out$reason <- "No varying principal component is available."
    return(out)
  }
  keep <- seq_len(min(as.integer(max_components), rank))
  out$status <- "ok"
  out$rank <- rank
  out$fit <- fit
  out$variance_share <- (fit$sdev^2 / sum(fit$sdev^2))[seq_len(rank)]
  names(out$variance_share) <- paste0("PC", seq_len(rank))
  out$scores <- cbind(rows, as.data.frame(fit$x[, keep, drop = FALSE]))
  rownames(out$scores) <- NULL
  out
}

# All similarities use original full-dimensional vectors, before PCA/scaling.
# Repeated labels are ambiguous: select unique IDs with match_by = "id" instead.
word_set_association <- function(data, targets = c("King", "Queen"),
                                 attribute_a = "man", attribute_b = "woman",
                                 match_by = "token") {
  if (!match_by %in% c("token", "id")) stop("match_by must be token or id.")
  sets <- list(targets = unique(targets), A = unique(attribute_a), B = unique(attribute_b))
  if (any(!lengths(sets))) stop("Every set needs at least one entry.")
  if (anyDuplicated(unlist(sets, use.names = FALSE)))
    stop("Use disjoint target and attribute sets for this exercise.")
  labels <- data$rows[[match_by]]
  norms <- sqrt(rowSums(data$vectors^2))
  coverage <- do.call(rbind, lapply(names(sets), function(group) {
    do.call(rbind, lapply(sets[[group]], function(term) {
      hits <- which(labels == term)
      status <- if (!length(hits)) "missing" else if (length(hits) > 1L)
        "ambiguous_repeated_token" else if (!norms[hits]) "zero_vector" else "covered"
      data.frame(set = group, requested = term, status = status,
                 stringsAsFactors = FALSE)
    }))
  }))
  out <- list(status = "incomplete_coverage", coverage = coverage,
              scores = NULL, first_minus_second = NA_real_)
  if (!all(coverage$status == "covered")) return(out)
  indices <- lapply(sets, function(terms) match(terms, labels))
  cosine <- full_cosine(data$vectors)
  mean_a <- rowMeans(cosine[indices$targets, indices$A, drop = FALSE])
  mean_b <- rowMeans(cosine[indices$targets, indices$B, drop = FALSE])
  out$status <- "ok"
  out$scores <- data.frame(data$rows[indices$targets, , drop = FALSE],
                           mean_cosine_A = mean_a, mean_cosine_B = mean_b,
                           association_difference = mean_a - mean_b,
                           row.names = NULL)
  if (nrow(out$scores) == 2L)
    out$first_minus_second <- out$scores$association_difference[1] -
      out$scores$association_difference[2]
  out
}

# Compare only models already exported to disk. Coordinates across models are
# not aligned; compare coverage/within-model cosine, not raw cross-model cosine.
compare_prepared_models <- function(csv_a, csv_b, requested_tokens,
                                    token_column = NULL) {
  if (!length(requested_tokens) || anyDuplicated(requested_tokens))
    stop("Supply a nonempty list of unique requested tokens.")
  models <- list(A = read_token_vectors(csv_a, token_column),
                 B = read_token_vectors(csv_b, token_column))
  coverage <- do.call(rbind, lapply(names(models), function(name) {
    data <- models[[name]]
    counts <- vapply(requested_tokens, function(w) sum(data$rows$token == w), integer(1))
    index <- match(requested_tokens, data$rows$token)
    norms <- sqrt(rowSums(data$vectors^2))
    ok <- counts == 1L & !is.na(index)
    ok[ok] <- norms[index[ok]] > 0
    data.frame(model = name, token = requested_tokens, covered = ok,
               status = ifelse(counts > 1L, "ambiguous", ifelse(ok, "covered", "missing_or_zero")))
  }))
  common <- requested_tokens[vapply(requested_tokens, function(w)
    all(coverage$covered[coverage$token == w]), logical(1))]
  output <- lapply(models, function(data) {
    if (!length(common)) return(list(cosine = NULL, pca = NULL))
    index <- match(common, data$rows$token)
    data$rows <- data$rows[index, , drop = FALSE]
    data$vectors <- data$vectors[index, , drop = FALSE]
    cosine <- full_cosine(data$vectors)
    dimnames(cosine) <- list(common, common)
    list(cosine = cosine, pca = fit_token_pca(data))
  })
  list(coverage = coverage, common_tokens = common, models = output)
}

plot_pca_3d <- function(pca) {
  if (!all(c("PC1", "PC2", "PC3") %in% names(pca$scores))) {
    message("3D needs three available principal components; keep the 1D/2D result.")
    return(invisible(NULL))
  }
  if (!requireNamespace("plotly", quietly = TRUE)) {
    message("Optional 3D skipped: plotly is not installed. No installation is required.")
    return(invisible(NULL))
  }
  plotly::plot_ly(pca$scores, x = ~PC1, y = ~PC2, z = ~PC3,
                 type = "scatter3d", mode = "markers+text", text = ~token,
                 hovertext = ~paste(id, token), hoverinfo = "text",
                 marker = list(size = 5))
}

write_pca_table <- function(scores, file) {
  pcs <- grep("^PC[0-9]+$", names(scores), value = TRUE)
  display <- scores
  display$token <- gsub("|", "\\|", display$token, fixed = TRUE)
  display$id <- gsub("|", "\\|", display$id, fixed = TRUE)
  for (pc in pcs) display[[pc]] <- sprintf("%.4f", display[[pc]])
  header <- paste0("| ", paste(names(display), collapse = " | "), " |")
  separator <- paste0("| ", paste(rep("---", ncol(display)), collapse = " | "), " |")
  body <- apply(display, 1L, function(row) paste0("| ", paste(row, collapse = " | "), " |"))
  writeLines(c(header, separator, body), file, useBytes = TRUE)
}

plot_pca_file <- function(pca, file, model_label) {
  scores <- pca$scores
  pcs <- grep("^PC[0-9]+$", names(scores), value = TRUE)
  png(file, width = 1440, height = 1020, res = 140)
  on.exit(dev.off(), add = TRUE)
  par(mar = c(5, 5, 5, 2) + 0.1)
  if (!length(pcs)) {
    plot.new()
    text(0.5, 0.55, "PCA unavailable", cex = 1.5)
    text(0.5, 0.45, pca$reason, cex = 0.9)
    return(invisible(scores))
  }
  x <- scores$PC1
  y <- if ("PC2" %in% pcs) scores$PC2 else rep(0, length(x))
  colours <- rep("#2768aa", length(x))
  if ("PC3" %in% pcs) {
    palette <- colorRampPalette(c("#2166ac", "#f7f7f7", "#b2182b"))(101)
    scaled <- (scores$PC3 - min(scores$PC3)) / diff(range(scores$PC3))
    colours <- palette[1L + round(scaled * 100)]
  }
  pad <- function(values) {
    span <- diff(range(values))
    if (!span) span <- 1
    range(values) + c(-0.18, 0.18) * span
  }
  share <- pca$variance_share
  plot(x, y, pch = 21, bg = colours, col = "#303030", cex = 1.6,
       xlim = pad(x), ylim = pad(y),
       xlab = sprintf("PC1 (%.2f%%)", 100 * share[1]),
       ylab = if (length(pcs) >= 2) sprintf("PC2 (%.2f%%)", 100 * share[2]) else
         "No second component (vertical positions are zero)",
       asp = 1,
       main = sprintf("%s: %d token rows", model_label, nrow(scores)),
       sub = sprintf("center = %s; scale = %s; plotted PCs retain %.2f%% of variance",
                     pca$center, pca$scale, 100 * sum(share[seq_len(min(2L, length(pcs)))])))
  abline(h = 0, v = 0, col = "#d9d9d9", lty = 3)
  points(x, y, pch = 21, bg = colours, col = "#303030", cex = 1.6)
  labels <- if (anyDuplicated(scores$token))
    paste0(scores$token, " [", scores$position, "]") else scores$token
  # Place these two close-pair labels beside their point in the canonical map.
  label_positions <- ifelse(scores$token %in% c("King", "woman"), 2L, 3L)
  text(x, y, labels = labels, pos = label_positions, offset = 0.8, cex = 0.9)
  if ("PC3" %in% pcs) {
    legend("topright", legend = sprintf("PC3: %.2f / %.2f / %.2f",
           min(scores$PC3), median(scores$PC3), max(scores$PC3)),
           bty = "n", text.col = "#555555", cex = 0.75)
    mtext("Point colour: blue = lower PC3, red = higher PC3", side = 3, line = 0.4,
          cex = 0.8, col = "#555555")
  }
  invisible(scores)
}

# Minimal JSON writer so the offline pipeline has no extra package requirement.
json_quote <- function(x) {
  x <- gsub("\\", "\\\\", x, fixed = TRUE)
  x <- gsub('"', '\\"', x, fixed = TRUE)
  for (code in 1:31)
    x <- gsub(intToUtf8(code), sprintf("\\u%04x", code), x, fixed = TRUE)
  paste0('"', x, '"')
}
to_json <- function(x) {
  if (is.null(x)) return("null")
  if (is.data.frame(x)) return(to_json(lapply(seq_len(nrow(x)), function(i)
    as.list(x[i, , drop = FALSE]))))
  if (is.list(x)) {
    items <- vapply(x, to_json, character(1))
    if (!is.null(names(x)) && length(x))
      return(paste0("{", paste(paste0(json_quote(names(x)), ":", items), collapse = ","), "}"))
    return(paste0("[", paste(items, collapse = ","), "]"))
  }
  if (length(x) != 1L) return(to_json(unname(as.list(x))))
  if (is.na(x)) return("null")
  if (is.character(x)) return(json_quote(x))
  if (is.logical(x)) return(if (x) "true" else "false")
  if (is.numeric(x)) return(if (is.finite(x)) format(x, digits = 17, scientific = TRUE) else "null")
  stop("Unsupported JSON type.")
}

run_after_class_lab <- function(input_csv, output_dir,
                                model_label = "Saved static vectors",
                                token_column = NULL, id_column = NULL,
                                dimension_columns = NULL) {
  data <- read_token_vectors(input_csv, token_column, id_column, dimension_columns)
  cosine <- full_cosine(data$vectors)
  pca <- fit_token_pca(data, center = TRUE, scale. = TRUE)
  association <- word_set_association(data)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  paths <- file.path(output_dir, c("word-pca.csv", "word-pca.png",
                                  "word-pca-table.md", "word-cosine.csv", "pca-check.json"))
  names(paths) <- c("table", "plot", "markdown", "cosine", "metadata")
  write.csv(pca$scores, paths[["table"]], row.names = FALSE)
  write_pca_table(pca$scores, paths[["markdown"]])
  plotted_scores <- plot_pca_file(pca, paths[["plot"]], model_label)
  write.csv(data.frame(id = rownames(cosine), cosine, check.names = FALSE),
            paths[["cosine"]], row.names = FALSE, na = "NA")
  exported <- read.csv(paths[["table"]], stringsAsFactors = FALSE, check.names = FALSE)
  pcs <- grep("^PC[0-9]+$", names(pca$scores), value = TRUE)
  max_error <- if (length(pcs) && nrow(exported))
    max(abs(as.matrix(exported[pcs]) - as.matrix(pca$scores[pcs]))) else 0
  same_plot <- identical(plotted_scores, pca$scores)
  if (!same_plot || max_error > 1e-10) stop("PCA export verification failed.")
  as_array <- function(x) unname(as.list(x))
  metadata <- list(schema_version = "1.0", model_label = model_label,
    input = list(path = data$input, md5 = data$input_md5,
                 rows = nrow(data$vectors), dimensions = ncol(data$vectors),
                 dimension_columns = as_array(data$dimension_columns), rows_metadata = data$rows),
    cosine = list(space = "original full-dimensional coordinates; no PCA or coordinate scaling",
                  zero_vector_comparisons = "NA"),
    pca = list(status = pca$status, center = pca$center, scale = pca$scale,
               zero_vector_ids = as_array(pca$zero_vector_ids),
               dropped_constant_dimensions = as_array(pca$dropped_constant_dimensions),
               rank = pca$rank, score_columns = as_array(pcs),
               variance_share = as.list(pca$variance_share),
               first_two_share = if (pca$rank) sum(head(pca$variance_share, 2)) else NULL,
               reason = if (is.null(pca$reason)) NULL else pca$reason),
    verification = list(table_plot_same_score_object = same_plot,
                         csv_roundtrip_max_absolute_error = max_error,
                         plotted_ids = as_array(plotted_scores$id),
                         plotted_coordinates = plotted_scores,
                         note = "PNG and CSV use one pca$scores object; markdown rounds it to four decimals."),
    association = list(description = "Teaching example only; no WEAT test or population inference",
                        attributes = list(A = "man", B = "woman"),
                        status = association$status, coverage = association$coverage,
                        scores = association$scores,
                        King_minus_Queen = association$first_minus_second),
    files = lapply(paths[1:4], function(path)
      list(name = basename(path), md5 = unname(tools::md5sum(path)))))
  writeLines(to_json(metadata), paths[["metadata"]], useBytes = TRUE)
  cat(sprintf("Input: %d token rows x %d dimensions\n", nrow(data$vectors), ncol(data$vectors)))
  cat("Original full-space cosine (IDs identify rows):\n")
  print(round(cosine, 4))
  cat("\nPCA scores (center=TRUE, scale.=TRUE):\n")
  print(pca$scores, row.names = FALSE)
  if (pca$status == "ok") {
    cat(sprintf("Available first %d plotted PCs variance: %.4f%%\n",
                min(2L, pca$rank), 100 * sum(head(pca$variance_share, 2))))
  } else cat("PCA unavailable:", pca$reason, "\n")
  cat("Zero-vector rows excluded from PCA:", length(pca$zero_vector_ids), "\n")
  cat("Constant dimensions excluded from PCA:", length(pca$dropped_constant_dimensions), "\n")
  cat("\nAssociation coverage:\n")
  print(association$coverage, row.names = FALSE)
  if (association$status == "ok") {
    print(association$scores, row.names = FALSE)
    cat("King minus Queen association difference:", association$first_minus_second, "\n")
  } else cat("Association interpretation skipped until every requested term is covered uniquely.\n")
  cat("\nVerified table/plot share one score object; files:", output_dir, "\n")
  invisible(list(data = data, cosine = cosine, pca = pca,
                 association = association, metadata = metadata, paths = paths))
}

main <- function() {
  full_args <- commandArgs(trailingOnly = FALSE)
  script_flag <- grep("^--file=", full_args, value = TRUE)
  if (!length(script_flag)) stop("Run with Rscript or source the functions.")
  script_dir <- dirname(normalizePath(sub("^--file=", "", script_flag[1]), mustWork = TRUE))
  opts <- list(input = file.path(script_dir, "../flair/example-output/word-vectors.csv"),
               `output-dir` = file.path(script_dir, "example-output"),
               `model-label` = NULL, `token-column` = NULL, `id-column` = NULL)
  args <- commandArgs(trailingOnly = TRUE)
  if ("--help" %in% args) {
    cat("Offline W9 vector lab; base R only. No model installation/download.\n",
        "Rscript after_class_lab.R [--input vectors.csv] [--output-dir output]\n",
        "  [--model-label LABEL] [--token-column word] [--id-column id]\n",
        "CSV: token/word, optional position/id, then dim1..dimN or numeric dimensions.\n",
        "Default: saved W9 GloVe 11 x 100 vectors; output: example-output.\n", sep = "")
    return(invisible(NULL))
  }
  custom_input <- FALSE
  while (length(args)) {
    key <- sub("^--", "", args[1])
    if (!startsWith(args[1], "--") || !key %in% names(opts) || length(args) < 2L)
      stop("Unknown/incomplete option. Use --help.")
    opts[key] <- list(args[2])
    if (key == "input") custom_input <- TRUE
    args <- args[-c(1, 2)]
  }
  if (is.null(opts[["model-label"]])) opts[["model-label"]] <- if (custom_input)
    "User-supplied vectors (verify model source)" else "Flair pretrained GloVe 100D"
  run_after_class_lab(opts$input, opts[["output-dir"]], opts[["model-label"]],
                      opts[["token-column"]], opts[["id-column"]])
}

if (sys.nframe() == 0L) main()
