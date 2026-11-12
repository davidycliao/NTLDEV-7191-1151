# W9 classroom practical: word embeddings and Flair.
# Open from the course repository root or W9; run complete blocks.
# In class (30 minutes): R00 + teacher output previews (5), R05/E04 (10), Flair/E06 (15).
# Student execution route: R00, R05, then the Flair mini-lab after E04.
# Teacher previews only: readability and count/TF-IDF retrieval; no live R01-R03 walkthrough.
# After class: full R01-R03/E01-E02, R04/E03, R06/E05, PCA and embedding regression.
# Keep this R session. After restarting, R05 PCA needs R00 and R05;
# R06 document comparisons additionally need R02 and R03.
# No network or model training is required. Supplied GloVe vectors are illustrative.
# Official documentation, checked 2026-11-07:
# https://quanteda.io/reference/textstat_readability.html
# https://quanteda.io/reference/dfm_tfidf.html
# https://quanteda.io/reference/textstat_simil.html
# https://quanteda.io/reference/textstat_keyness.html
# https://text2vec.org/glove.html

# ==== R00 Packages and files ====
required <- c("quanteda", "quanteda.textstats")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install before class: ", paste(missing, collapse = ", "))
suppressPackageStartupMessages({library(quanteda); library(quanteda.textstats)})
quanteda_options(threads = 1)
options(width = 100)
w9_root <- if (dir.exists("W9/classroom")) normalizePath("W9") else if (dir.exists("classroom/Data")) normalizePath(".") else stop("Run from the course repository root or W9.")
speeches <- readRDS(file.path(w9_root, "classroom/Data/w9_speeches.rds"))
speech_corpus <- corpus(speeches, text_field = "text", docid_field = "doc_id")
raw_tokens <- tokens(speech_corpus) # Preserve original contexts for R05 without running R02.
stopifnot(!anyDuplicated(speeches$doc_id), !anyNA(speeches$text), all(nzchar(speeches$text)))
print(c(speeches = ndoc(speech_corpus)))
print(table(speeches$party_family))
print(speeches[1:3, c("doc_id", "leader", "party_family", "date")], row.names = FALSE)
# One row is one complete speech. This is a nearly balanced teaching sample, not all speech volume.

# ==== R01 Readability from original text ====
# After class: full code and E01. In class, the teacher briefly previews saved output.
readability <- textstat_readability(speech_corpus, measure = "Flesch",
  remove_hyphens = TRUE, min_sentence_length = 1, max_sentence_length = 10000,
  intermediate = TRUE)
readability$words_per_sentence <- readability$W / readability$St
# Installed quanteda.textstats 0.97.2 has no named LIX measure. W7C is its
# intermediate count of words of at least seven characters (= more than six).
readability$LIX <- readability$words_per_sentence + 100 * readability$W7C / readability$W
# Cross-check the implementation's historical LIW label against the transparent formula.
lix_check <- textstat_readability(speech_corpus, measure = "LIW")
stopifnot(isTRUE(all.equal(readability$LIX, lix_check$LIW)))
readability$party <- speeches$party_family[match(readability$document, speeches$doc_id)]
print(head(readability[, c("document", "Flesch", "LIX", "W", "St", "words_per_sentence")], 4), row.names = FALSE)
readability_summary <- aggregate(cbind(Flesch, LIX, words_per_sentence) ~ party,
  readability, FUN = median)
print(readability_summary, row.names = FALSE)
# Flesch uses sentence length and estimated English syllables. Higher scores indicate
# easier reading under this formula; they do not measure reader comprehension directly.
# LIX = words/sentences + 100*(words with more than six characters)/words.
# Higher LIX indicates harder reading under this formula. LIX connects to the
# Bischof & Senninger (2018) assigned study; Flesch is a teaching comparison.
# E01: Read one high-LIX and one low-LIX speech, then compare their Flesch scores.
# Which language choices do the formulas capture? Name one important aspect of
# comprehension that they cannot observe. State the opposite score directions.

# ==== R02 One count vocabulary and TF-IDF weighting ====
# After class: full R02-R03 and E02. In class, the teacher previews the rank change only.
content_tokens <- tokens(speech_corpus, remove_punct = TRUE,
  remove_numbers = TRUE, remove_symbols = TRUE, remove_url = TRUE) |>
  tokens_tolower() |> tokens_keep("^[a-z]+$", valuetype = "regex") |>
  tokens_remove(stopwords("en"))
count_dfm <- dfm(content_tokens) |> dfm_trim(min_termfreq = 5, min_docfreq = 2)
tfidf_dfm <- dfm_tfidf(count_dfm, scheme_tf = "count", scheme_df = "inverse", base = 10)
# A zero count or zero TF-IDF norm makes cosine undefined. Keep the same eligible
# documents and identical vocabulary in both comparisons; report exclusions explicitly.
eligible <- ntoken(count_dfm) > 0 & Matrix::rowSums(tfidf_dfm ^ 2) > 0
excluded_ids <- docnames(count_dfm)[!eligible]
count_compare <- count_dfm[eligible, ]
tfidf_compare <- tfidf_dfm[eligible, ]
stopifnot(identical(dimnames(count_compare), dimnames(tfidf_compare)))
print(c(documents = ndoc(count_compare), features = nfeat(count_compare),
  excluded_zero_vectors = length(excluded_ids)))
print(topfeatures(count_compare, 8))
# TF-IDF here is count * log10(N/document_frequency). The document unit is a speech.

# ==== R03 Compare nearest speeches and read their words ====
# After class: run R02 first. The live word-embedding route skips this block.
count_similarity <- as.matrix(textstat_simil(count_compare, method = "cosine", margin = "documents"))
tfidf_similarity <- as.matrix(textstat_simil(tfidf_compare, method = "cosine", margin = "documents"))
# Never retrieve a speech as its own neighbour. Ties are resolved by document order.
diag(count_similarity) <- NA_real_
diag(tfidf_similarity) <- NA_real_
query_id <- "ess_hoc_00004"
if (!query_id %in% rownames(count_similarity)) query_id <- rownames(count_similarity)[1]
count_rank <- order(count_similarity[query_id, ], decreasing = TRUE, na.last = NA)
tfidf_rank <- order(tfidf_similarity[query_id, ], decreasing = TRUE, na.last = NA)
count_neighbours <- data.frame(doc_id = colnames(count_similarity)[head(count_rank, 5)],
  cosine = count_similarity[query_id, head(count_rank, 5)], row.names = NULL)
tfidf_neighbours <- data.frame(doc_id = colnames(tfidf_similarity)[head(tfidf_rank, 5)],
  cosine = tfidf_similarity[query_id, head(tfidf_rank, 5)], row.names = NULL)
cat("Query:", query_id, "\nCount neighbours:\n")
print(count_neighbours, row.names = FALSE)
cat("TF-IDF neighbours:\n")
print(tfidf_neighbours, row.names = FALSE)
read_ids <- unique(c(query_id, tfidf_neighbours$doc_id[1]))
print(speeches[match(read_ids, speeches$doc_id), c("doc_id", "leader", "date", "agenda")], row.names = FALSE)
for (id in read_ids) {
  cat("\n", id, "— opening excerpt, not the complete speech:\n",
    substr(speeches$text[match(id, speeches$doc_id)], 1, 850), "\n", sep = "")
}
# E02: Compare the two top-five lists. Read the complete nearest speech via
# speeches$text[match(tfidf_neighbours$doc_id[1], speeches$doc_id)]. What explains the
# similarity: topic, phrase reuse, parliamentary procedure, or policy stance? Give evidence.

# ==== R04 Keyness: Labour target, Conservative reference ====
# After class, optional. The classroom route continues with R05.
party_dfm <- dfm_group(count_dfm, groups = docvars(count_dfm, "party_family"))
stopifnot(setequal(docnames(party_dfm), c("Labour", "Conservative")))
keyness <- textstat_keyness(party_dfm, target = "Labour", measure = "chi2", correction = "yates")
print(head(keyness, 6), row.names = FALSE)
print(tail(keyness, 6), row.names = FALSE)
# Positive signed chi-square: relatively more frequent in Labour's pooled tokens.
# Negative: relatively more frequent in the Conservative reference. Long speeches
# contribute more tokens. This descriptive comparison does not adjust for period,
# leader, debate topic, government status or repeated language.
# E03: Choose a distinctive term, inspect its original KWIC, and propose one alternative
# explanation for the party difference. A p-value is not evidence of ideological meaning.

# ==== R05 Static word vectors and original contexts ====
# Step 1: Load the word vectors
embedding <- readRDS(file.path(w9_root, "classroom/Data/w9_glove.rds"))
word_vectors <- embedding$vectors
print(dim(word_vectors))

# Step 2: Find security neighbours
word_unit <- word_vectors / sqrt(rowSums(word_vectors ^ 2))
security_cosine <- drop(word_unit %*% word_unit["security", ])
security_cosine["security"] <- NA_real_
top <- head(sort(security_cosine, decreasing = TRUE), 8)
security_neighbours <- data.frame(word = names(top), cosine = unname(top))
print(security_neighbours, row.names = FALSE)

# Step 3: Read the original contexts
security_contexts <- kwic(raw_tokens, pattern = "security",
  valuetype = "fixed", window = 7)
print(head(as.data.frame(security_contexts), 3), row.names = FALSE)
# Every occurrence of security receives the SAME learned vector.
# E04: Name a neighbour, quote a supporting KWIC phrase, then name another security use.
# After E04, continue with the Flair mini-lab. A separate query and PCA are after class.

# ==== R06 Average known word vectors and report coverage ====
# After class, optional. Restore R00, R02, R03, R05 first if the R session was restarted.
# Match count columns to supplied vectors; unseen tokens contribute no vector.
# Repeated terms are weighted by their counts. This is a simple bag-of-vectors average.
embedding_counts <- dfm_match(dfm(content_tokens), features = rownames(word_vectors))
known_tokens <- as.numeric(ntoken(embedding_counts))
all_content_tokens <- as.numeric(ntoken(content_tokens))
embedding_coverage <- data.frame(doc_id = docnames(embedding_counts), known_tokens,
  content_tokens = all_content_tokens,
  coverage = ifelse(all_content_tokens > 0, known_tokens / all_content_tokens, NA_real_))
doc_vectors <- as.matrix(embedding_counts %*% word_vectors)
doc_vectors[known_tokens > 0, ] <- doc_vectors[known_tokens > 0, , drop = FALSE] / known_tokens[known_tokens > 0]
doc_norms <- sqrt(rowSums(doc_vectors ^ 2))
valid_embedding <- known_tokens > 0 & is.finite(doc_norms) & doc_norms > 0
doc_unit <- doc_vectors[valid_embedding, , drop = FALSE] / doc_norms[valid_embedding]
embedding_similarity <- tcrossprod(doc_unit)
diag(embedding_similarity) <- NA_real_
stopifnot(query_id %in% rownames(embedding_similarity))
embedding_rank <- order(embedding_similarity[query_id, ], decreasing = TRUE, na.last = NA)
embedding_neighbours <- data.frame(doc_id = colnames(embedding_similarity)[head(embedding_rank, 5)],
  cosine = embedding_similarity[query_id, head(embedding_rank, 5)], row.names = NULL)
embedding_neighbours$coverage <- embedding_coverage$coverage[match(embedding_neighbours$doc_id, embedding_coverage$doc_id)]
print(summary(embedding_coverage$coverage))
print(embedding_neighbours, row.names = FALSE)
cat("Excluded zero embedding documents:", sum(!valid_embedding), "\n")
# Word order and negation scope disappear in this average. These vectors are static,
# not contextual transformer embeddings or a conText/ALC estimate of contextual meaning.
# E05: Compare count, TF-IDF and embedding neighbours for the same query. Support one
# interpretation with original text and report coverage. Why is a high cosine score
# insufficient to claim agreement, influence or a causal effect?
