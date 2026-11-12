#!/usr/bin/env Rscript
# 課程根目錄執行 Rscript W9/lab/embedding-regression/embedding_regression_lab.R
# source() 後執行 run_w9_embedding_regression("baseline") 或 ("flair100")。
# 不安裝套件、不下載模型；baseline 使用 conText 隨附的相配資料。

.w9_er_dir <- local({
  frames <- sys.frames()
  source_files <- vapply(frames, function(x) {
    if (is.null(x$ofile)) "" else as.character(x$ofile)
  }, character(1))
  candidate <- tail(source_files[nzchar(source_files)], 1)
  if (!length(candidate)) {
    flag <- grep("^--file=", commandArgs(), value = TRUE)
    if (length(flag)) candidate <- sub("^--file=", "", flag[1])
  }
  if (!length(candidate)) stop("請用 source() 或 Rscript 載入本檔。")
  dirname(normalizePath(candidate, mustWork = TRUE))
})

w9_er_require <- function() {
  required <- c("quanteda", "conText", "Matrix", "jsonlite")
  missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("尚缺套件：", paste(missing, collapse = ", "),
                            "。本單元不自動安裝套件。")
}

w9_er_inputs <- function() {
  w9_er_require()
  env <- new.env()
  utils::data("cr_sample_corpus", package = "conText", envir = env)
  utils::data("cr_glove_subset", package = "conText", envir = env)
  utils::data("cr_transform", package = "conText", envir = env)
  corpus <- env$cr_sample_corpus
  quanteda::docvars(corpus, "source_doc") <- quanteda::docnames(corpus)
  quanteda::docvars(corpus, "party") <- factor(
    quanteda::docvars(corpus, "party"), levels = c("D", "R"))
  quanteda::docvars(corpus, "gender") <- factor(
    quanteda::docvars(corpus, "gender"), levels = c("F", "M"))

  # 所有刪除步驟保留 padding，避免原本不相鄰的詞變成相鄰。
  toks <- quanteda::tokens(corpus, remove_punct = TRUE, remove_symbols = TRUE,
                          remove_numbers = TRUE, remove_separators = TRUE,
                          padding = TRUE)
  toks <- quanteda::tokens_tolower(toks)
  token_positions <- quanteda::ntoken(toks, remove_padding = FALSE)
  toks <- quanteda::tokens_select(toks, pattern = quanteda::stopwords("en"),
                                 selection = "remove", padding = TRUE)
  toks <- quanteda::tokens_select(toks, pattern = "*", min_nchar = 3,
                                 padding = TRUE)
  features <- quanteda::featnames(quanteda::dfm_trim(
    quanteda::dfm(toks), min_termfreq = 5))
  toks <- quanteda::tokens_select(toks, pattern = features,
                                 valuetype = "fixed", padding = TRUE)
  stopifnot(identical(token_positions, quanteda::ntoken(toks, remove_padding = FALSE)))
  raw_toks <- quanteda::tokens(corpus, remove_separators = TRUE)

  input_dir <- file.path(.w9_er_dir, "input")
  dir.create(input_dir, recursive = TRUE, showWarnings = FALSE)
  documents <- data.frame(source_doc = quanteda::docnames(corpus),
                          party = quanteda::docvars(corpus, "party"),
                          gender = quanteda::docvars(corpus, "gender"),
                          text = as.character(corpus), stringsAsFactors = FALSE)
  utils::write.csv(documents, file.path(input_dir, "source-documents.csv"),
                   row.names = FALSE, fileEncoding = "UTF-8")
  utils::write.csv(data.frame(word = rownames(env$cr_glove_subset)),
                   file.path(input_dir, "fixed-vocabulary.csv"), row.names = FALSE)
  list(corpus = corpus, toks = toks, raw_toks = raw_toks,
       embeddings = as.matrix(env$cr_glove_subset),
       transform = as.matrix(env$cr_transform), input_dir = input_dir)
}

w9_er_cosine <- function(x, y) {
  x <- as.matrix(x); y <- as.matrix(y)
  xnorm <- sqrt(rowSums(x ^ 2)); ynorm <- sqrt(rowSums(y ^ 2))
  if (any(xnorm == 0) || any(ynorm == 0)) stop("零向量不能計算 cosine。")
  tcrossprod(x / xnorm, y / ynorm)
}

w9_er_occurrence_key <- function(source) {
  sequence <- ave(seq_along(source), source, FUN = seq_along)
  paste(source, sequence, sep = "::")
}

run_w9_embedding_regression <- function(route = c("baseline", "flair100"),
                                        output_dir = NULL, top_n = 10L) {
  route <- match.arg(route)
  input <- w9_er_inputs()
  if (is.null(output_dir)) output_dir <- file.path(.w9_er_dir, "example-output", route)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  write_table <- function(x, filename) {
    utils::write.csv(x, file.path(output_dir, filename), row.names = FALSE,
                     fileEncoding = "UTF-8")
  }
  E <- input$embeddings
  A <- input$transform
  transform_source <- "conText::cr_transform; matched with cr_glove_subset"
  if (route == "flair100") {
    vector_file <- file.path(input$input_dir, "flair-glove100-vectors.csv")
    if (!file.exists(vector_file)) stop(
      "缺少離線 GloVe100 矩陣。先執行 baseline，再用 export_flair_glove.py ",
      "從已快取模型匯出；此步驟不下載模型。")
    imported <- utils::read.csv(vector_file, check.names = FALSE)
    E <- as.matrix(imported[, -1, drop = FALSE])
    rownames(E) <- imported$word
    storage.mode(E) <- "double"
    fixed_vocab <- rownames(input$embeddings)
    stopifnot(ncol(E) == 100L, !anyDuplicated(rownames(E)),
              all(rownames(E) %in% fixed_vocab), all(is.finite(E)),
              all(rowSums(E ^ 2) > 0))
    # 新維度／新模型必須重新估計 A；不能套用或截取原 300×300 轉換。
    matched <- quanteda::tokens_select(input$toks, rownames(E),
                                       valuetype = "fixed", padding = TRUE)
    cooccurrence <- quanteda::fcm(matched, context = "window", window = 6L,
                                 count = "frequency", tri = FALSE)
    A <- as.matrix(conText::compute_transform(cooccurrence, E, weighting = "log"))
    transform_source <- "reestimated with compute_transform; window=6; weighting=log"
  }
  stopifnot(nrow(A) == ncol(E), ncol(A) == ncol(E), all(is.finite(A)))

  # 目標是精確的 immigration；immigr* 只用來展示不同的樣本定義。
  contexts <- conText::tokens_context(input$toks, pattern = "immigration",
    window = 6L, valuetype = "fixed", rm_keyword = TRUE, verbose = FALSE)
  family <- conText::tokens_context(input$toks, pattern = "immigr*",
    window = 6L, valuetype = "glob", rm_keyword = TRUE, verbose = FALSE)
  family_counts <- as.data.frame(table(quanteda::docvars(family, "pattern")),
                                  stringsAsFactors = FALSE)
  names(family_counts) <- c("matched_word", "n_contexts")
  write_table(family_counts, "target-family-counts.csv")

  # 套件文本已清理；此 KWIC 回讀的是套件保存版本，不是未清理逐字稿。
  # 閱讀用較寬的 12 詞窗；估計仍只用本次 token 化後的 6 個位置。
  raw_kwic <- as.data.frame(quanteda::kwic(input$raw_toks, "immigration",
    valuetype = "fixed", case_insensitive = TRUE, window = 12L))
  context_sources <- as.character(quanteda::docvars(contexts, "source_doc"))
  raw_keys <- w9_er_occurrence_key(as.character(raw_kwic$docname))
  context_keys <- w9_er_occurrence_key(context_sources)
  match_rows <- match(context_keys, raw_keys)
  stopifnot(!anyNA(match_rows), length(match_rows) == nrow(raw_kwic))
  raw_kwic <- raw_kwic[match_rows, , drop = FALSE]
  context_ids <- sprintf("immigration_%04d", seq_len(quanteda::ndoc(contexts)))
  quanteda::docnames(contexts) <- context_ids
  context_dfm <- quanteda::dfm(contexts)
  context_table <- data.frame(
    context_id = context_ids, source_doc = context_sources,
    party = as.character(quanteda::docvars(contexts, "party")),
    gender = as.character(quanteda::docvars(contexts, "gender")),
    from = raw_kwic$from, to = raw_kwic$to,
    pre = raw_kwic$pre, keyword = raw_kwic$keyword, post = raw_kwic$post,
    model_context = vapply(as.list(contexts), function(x) {
      paste(x[nzchar(x)], collapse = " ")
    }, character(1)), stringsAsFactors = FALSE)

  context_dem <- conText::dem(context_dfm, pre_trained = E,
    transform = TRUE, transform_matrix = A, verbose = FALSE)
  aligned <- match(rownames(context_dem), context_table$context_id)
  stopifnot(!anyNA(aligned))
  kept <- context_table[aligned, , drop = FALSE]
  retained <- as.numeric(Matrix::rowSums(context_dfm[,
    setdiff(quanteda::featnames(context_dfm), ""), drop = FALSE]))
  matched_counts <- as.numeric(Matrix::rowSums(context_dfm[,
    intersect(quanteda::featnames(context_dfm), rownames(E)), drop = FALSE]))
  coverage <- data.frame(context_id = context_ids, retained_tokens = retained,
                         matched_tokens = matched_counts,
                         coverage = ifelse(retained > 0, matched_counts / retained, 0))
  context_table$used_in_dem <- context_table$context_id %in% rownames(context_dem)
  write_table(context_table, "contexts.csv")
  write_table(coverage, "context-coverage.csv")
  party_gender <- as.data.frame(table(kept$party, kept$gender))
  names(party_gender) <- c("party", "gender", "n_contexts")
  write_table(party_gender, "party-gender-counts.csv")

  set.seed(2026L)
  fit <- conText::conText(immigration ~ party + gender, data = input$toks,
    pre_trained = E, transform = TRUE, transform_matrix = A,
    jackknife = FALSE, permute = FALSE, window = 6L,
    valuetype = "fixed", case_insensitive = TRUE, verbose = FALSE)
  B <- as.matrix(fit)
  stopifnot(identical(rownames(B), c("(Intercept)", "party_R", "gender_M")))
  # conText3 的 normed.estimate.orig 是平方長度；這裡明確開根號。
  squared <- rowSums(B[c("party_R", "gender_M"), , drop = FALSE] ^ 2)
  norms <- data.frame(term = names(squared), l2_length = sqrt(squared),
                      squared_length = as.numeric(squared), dimension = ncol(E),
                      stringsAsFactors = FALSE)
  write_table(norms, "coefficient-norms.csv")
  write_table(data.frame(term = rownames(B), B, check.names = FALSE), "coefficients.csv")
  write_table(as.data.frame(fit@normed_coefficients), "package-squared-norm-summary.csv")

  # 模型預測組合，非未調整的黨別平均。比較 DF/RF 或 DM/RM 才固定性別。
  groups <- rbind(DF = B["(Intercept)", ],
                  DM = B["(Intercept)", ] + B["gender_M", ],
                  RF = B["(Intercept)", ] + B["party_R", ],
                  RM = B["(Intercept)", ] + B["party_R", ] + B["gender_M", ])
  candidate_words <- setdiff(intersect(fit@features, rownames(E)), "immigration")
  candidates <- E[candidate_words, , drop = FALSE]
  scores <- w9_er_cosine(groups, candidates)
  neighbors <- do.call(rbind, lapply(rownames(groups), function(group) {
    ranks <- order(scores[group, ], decreasing = TRUE)
    ranks <- head(ranks, min(top_n, length(ranks)))
    data.frame(group = group, party = substr(group, 1, 1),
      held_gender = substr(group, 2, 2), rank = seq_along(ranks),
      feature = colnames(scores)[ranks], cosine = as.numeric(scores[group, ranks]))
  }))
  write_table(neighbors, "group-neighbors.csv")
  selected_words <- intersect(c("reform", "enforcement"), rownames(E))
  selected_scores <- w9_er_cosine(groups, E[selected_words, , drop = FALSE])
  selected <- do.call(rbind, lapply(rownames(groups), function(group) {
    data.frame(group = group, feature = colnames(selected_scores),
               cosine = as.numeric(selected_scores[group, ]))
  }))
  write_table(selected, "group-keyword-cosines.csv")

  # 同一模型組合只到同黨、同性別的原文中找近鄰，範圍寫進輸出。
  context_scores <- w9_er_cosine(groups, as.matrix(context_dem))
  nearest <- do.call(rbind, lapply(rownames(groups), function(group) {
    eligible <- which(kept$party == substr(group, 1, 1) &
                      kept$gender == substr(group, 2, 2))
    ordered <- eligible[order(context_scores[group, eligible], decreasing = TRUE)]
    chosen <- head(ordered, 3L)
    data.frame(group = group, rank = seq_along(chosen),
      cosine = as.numeric(context_scores[group, chosen]),
      retrieval_scope = "same_party_and_gender", kept[chosen, ], row.names = NULL)
  }))
  write_table(nearest, "nearest-contexts.csv")
  write_table(data.frame(coordinate = seq_len(nrow(A)), A, check.names = FALSE),
               "transform-matrix.csv")
  checks <- list(
    finite_embeddings = all(is.finite(E)), finite_transform = all(is.finite(A)),
    finite_coefficients = all(is.finite(B)),
    kwic_context_alignment = !anyNA(match_rows),
    coefficient_names = identical(rownames(B), c("(Intercept)", "party_R", "gender_M")),
    additive_party_difference = isTRUE(all.equal(unname(groups["RF", ] - groups["DF", ]),
                                                 unname(B["party_R", ]), tolerance = 1e-10)),
    additive_gender_difference = isTRUE(all.equal(unname(groups["DM", ] - groups["DF", ]),
                                                  unname(B["gender_M", ]), tolerance = 1e-10)))
  stopifnot(all(unlist(checks)))
  metadata <- list(
    route = route, created_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    R = as.character(getRversion()),
    packages = setNames(lapply(c("conText", "quanteda", "Matrix", "jsonlite"),
      function(x) as.character(utils::packageVersion(x))),
      c("conText", "quanteda", "Matrix", "jsonlite")),
    corpus = "conText::cr_sample_corpus", source_documents = quanteda::ndoc(input$corpus),
    corpus_is_preprocessed = TRUE,
    reading_text = "package-preserved processed text, not the unprocessed Congressional Record",
    target = "immigration", target_valuetype = "fixed", target_contexts = nrow(context_table),
    family_pattern = "immigr*", family_contexts = quanteda::ndoc(family),
    model_window = 6L, reading_window = 12L, padding = TRUE,
    min_nchar = 3L, min_termfreq = 5L, rm_keyword = TRUE,
    pretrained_rows = nrow(E), dimension = ncol(E), transform_shape = dim(A),
    transform_rank = qr(A)$rank, transform_source = transform_source,
    dem_rows = nrow(context_dem), dropped_contexts = nrow(context_table) - nrow(context_dem),
    formula = "immigration ~ party + gender", references = list(party = "D", gender = "F"),
    neighbors = "model-predicted DF/DM/RF/RM; exact target excluded from candidate words",
    nearest_contexts_scope = "same party and gender as model prediction; selected examples, not prevalence",
    inference = "none; jackknife=FALSE, permute=FALSE; no confidence intervals or significance claims",
    norm_definition = "sqrt(sum(beta_j^2)); conText3 normed.estimate.orig is sum(beta_j^2)",
    source_documents_md5 = unname(tools::md5sum(file.path(input$input_dir, "source-documents.csv"))),
    fixed_vocabulary_md5 = unname(tools::md5sum(file.path(input$input_dir, "fixed-vocabulary.csv"))),
    tutorial = "https://davidycliao.github.io/flaiR/articles/tutorial.html#extending-contexts-embedding-regression",
    paper = "https://doi.org/10.1017/S0003055422001228", checks = checks)
  if (route == "flair100") metadata$export_metadata <- "../../input/flair-glove100-metadata.json"
  jsonlite::write_json(metadata, file.path(output_dir, "metadata.json"),
                       auto_unbox = TRUE, pretty = TRUE, null = "null")
  summary <- capture.output({
    cat("W9 embedding regression —", route, "\n")
    cat("Corpus:", metadata$source_documents, "documents\n")
    cat("Exact immigration:", nrow(context_table), "contexts; immigr*:",
        quanteda::ndoc(family), "contexts\n")
    cat("Embedding vocabulary:", nrow(E), "x", ncol(E), "; DEM:",
        nrow(context_dem), "x", ncol(context_dem), "; transform:",
        nrow(A), "x", ncol(A), "\n")
    print(party_gender, row.names = FALSE)
    cat("Adjusted difference-vector lengths (not percentages)\n")
    print(norms, row.names = FALSE, digits = 7)
    cat("Model-predicted neighbours, female gender held fixed\n")
    print(subset(neighbors, group %in% c("DF", "RF") & rank <= 5), row.names = FALSE, digits = 5)
    cat("No CI, jackknife or permutation inference. Do not claim significance.\n")
    cat("Checks:", all(unlist(checks)), "\n")
  })
  writeLines(summary, file.path(output_dir, "captured-output.txt"), useBytes = TRUE)
  writeLines(summary)
  invisible(list(model = fit, context_dem = context_dem, transform = A,
    coefficient_norms = norms, group_vectors = groups, neighbors = neighbors,
    contexts = context_table, nearest_contexts = nearest, coverage = coverage,
    metadata = metadata, output_dir = normalizePath(output_dir)))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 1L || (length(args) && !args %in% c("--baseline", "--flair100", "--all"))) {
    stop("用法：Rscript embedding_regression_lab.R [--baseline|--flair100|--all]")
  }
  mode <- if (length(args)) args else "--baseline"
  if (mode %in% c("--baseline", "--all")) run_w9_embedding_regression("baseline")
  if (mode %in% c("--flair100", "--all")) run_w9_embedding_regression("flair100")
}
