# W4 supplied preparation: run from W4/classroom with Data and Dictionaries beside it.
# Read from top to bottom. Each assignment saves one intermediate result.
# Functions group repeated steps; students call them rather than write them.
# Core functions: tokens() splits text, dfm() counts words,
# tokens_lookup() matches phrases, kwic() shows context.
# The final section checks coding files; it is optional after W6.
library(quanteda)
quanteda_options(threads = 1)
data_path <- "Data/hc_sample_1945_2025.rds"
stopifnot(file.exists(data_path))
speeches <- readRDS(data_path)
stopifnot(nrow(speeches) == 5000, !anyNA(speeches$text))
speeches$doc_id <- sprintf("speech_%04d", seq_len(nrow(speeches)))
corp <- corpus(speeches, docid_field = "doc_id", text_field = "text")
toks <- tokens(corp, remove_punct = TRUE)
toks <- tokens_tolower(toks)
lengths_original <- ntoken(toks)

# These illustrate retrieval rules, not a validated insecurity measure.
broad <- dictionary(list(bills = "bill*"))
narrow <- dictionary(list(bills = c("energy bills", "household bills")))
count_matches <- function(x, dict) {
  matched <- tokens_lookup(x, dictionary = dict)
  counts <- dfm(matched)
  count_table <- as.matrix(counts)
  totals <- rowSums(count_table)
  as.numeric(totals)
}
broad_n <- count_matches(toks, broad)
narrow_n <- count_matches(toks, narrow)
# NA means that the rate is undefined for an empty text.
per_100 <- function(count, word_count) {
  word_count[word_count == 0] <- NA
  rate <- 100 * count / word_count
  rate
}
comparison <- data.frame(
  doc_id = docnames(toks), date = speeches$date, speaker = speeches$speaker,
  tokens = lengths_original, broad = broad_n, narrow = narrow_n,
  broad_per100 = per_100(broad_n, lengths_original),
  narrow_per100 = per_100(narrow_n, lengths_original)
)
contexts <- kwic(toks, pattern = "bill*", window = 6)

# A deliberately small, disjoint, single-token lexicon for transparent arithmetic.
toy_sentiment <- dictionary(file = "Dictionaries/teaching_affect.dic", format = "LIWC")
score_sentiment <- function(x) {
  n <- ntoken(x)
  matched <- tokens_lookup(x, dictionary = toy_sentiment, capkeys = FALSE)
  count_dfm <- dfm(matched)
  counts <- as.matrix(count_dfm)
  p <- counts[, "positive"]
  m <- counts[, "negative"]
  total_matches <- p + m
  match_denominator <- total_matches
  match_denominator[match_denominator == 0] <- NA
  results <- data.frame(doc_id = docnames(x), tokens = n,
                        positive = p, negative = m)
  results$net_per100 <- per_100(p - m, n)
  results$coverage_per100 <- per_100(total_matches, n)
  results$balance <- (p - m) / match_denominator
  results$no_match <- total_matches == 0
  rownames(results) <- NULL
  results
}
sentiment <- score_sentiment(toks)
check_texts <- c(good = "The policy is good.",
                negated = "The policy is not good.",
                unmatched = "The minister spoke today.",
                balanced = "A good plan with a bad outcome.",
                empty = "")
check_tokens <- tokens(check_texts, remove_punct = TRUE)
check_tokens <- tokens_tolower(check_tokens)
check_scores <- score_sentiment(check_tokens)

# Synthetic labels for arithmetic practice, not coding of the real corpus.
validation <- data.frame(
  predicted = c(rep(TRUE, 8), rep(FALSE, 12)),
  human = c(rep(TRUE, 6), rep(FALSE, 2), rep(TRUE, 4), rep(FALSE, 8))
)

# Separate research construct: energy-policy attention, not positive sentiment.
policy_entries <- read.csv("Dictionaries/energy_policy.csv", stringsAsFactors = FALSE)
read_policy_dictionary <- function(path, version) {
  entries <- read.csv(path, stringsAsFactors = FALSE)
  stopifnot(all(c("version", "category", "pattern") %in% names(entries)))
  entries <- entries[entries$version == version, , drop = FALSE]
  stopifnot(nrow(entries) > 0, !anyNA(entries),
            all(nzchar(entries$category)), all(nzchar(entries$pattern)))
  # Group the patterns under their category names.
  category_words <- split(entries$pattern, entries$category)
  dictionary(category_words)
}
energy_v1 <- read_policy_dictionary("Dictionaries/energy_policy.csv", "v1")
energy_v2 <- read_policy_dictionary("Dictionaries/energy_policy.csv", "v2")

# Retain punctuation for matching so phrases do not bridge sentence punctuation.
# Count the denominator on a separate word-token stream; retain stopwords in both.
policy_tokens <- tokens(corp, remove_punct = FALSE)
policy_tokens <- tokens_tolower(policy_tokens)
policy_counts <- function(x, dict) {
  matched <- tokens_lookup(x, dictionary = dict, valuetype = "glob",
                           case_insensitive = TRUE, capkeys = FALSE)
  counted <- dfm(matched)
  counted <- dfm_match(counted, features = "energy")
  as.integer(counted[, "energy"])
}
policy_scores <- data.frame(
  doc_id = docnames(policy_tokens), party = speeches$party,
  tokens = lengths_original,
  v1 = policy_counts(policy_tokens, energy_v1),
  v2 = policy_counts(policy_tokens, energy_v2)
)
word_denominator <- policy_scores$tokens
word_denominator[word_denominator == 0] <- NA
policy_scores$v1_per1000 <- 1000 * policy_scores$v1 / word_denominator
policy_scores$v2_per1000 <- 1000 * policy_scores$v2 / word_denominator

# This is a ratio of group totals, not an unweighted mean of speech-level rates.
# Sum each numeric column separately within each party.
party_totals <- policy_scores[, c("v1", "v2", "tokens")]
party_groups <- data.frame(party = policy_scores$party)
party_rates <- aggregate(party_totals, by = party_groups, FUN = sum)
party_rates$v1_per1000 <- 1000 * party_rates$v1 / party_rates$tokens
party_rates$v2_per1000 <- 1000 * party_rates$v2 / party_rates$tokens
party_order <- order(party_rates$tokens, decreasing = TRUE)
party_rates <- party_rates[party_order, ]

validate_binary <- function(predicted, human) {
  if (!length(human) || length(predicted) != length(human) ||
      anyNA(predicted) || anyNA(human) ||
      !all(predicted %in% c(0, 1)) || !all(human %in% c(0, 1))) {
    stop("Supply equally sized, complete binary 0/1 labels and predictions.")
  }
  tp <- sum(predicted == 1 & human == 1)
  fp <- sum(predicted == 1 & human == 0)
  fn <- sum(predicted == 0 & human == 1)
  tn <- sum(predicted == 0 & human == 0)
  # Only divide when the denominator is nonzero.
  precision <- NA_real_
  recall <- NA_real_
  f1 <- NA_real_
  if (tp + fp > 0) precision <- tp / (tp + fp)
  if (tp + fn > 0) recall <- tp / (tp + fn)
  if (2 * tp + fp + fn > 0) f1 <- 2 * tp / (2 * tp + fp + fn)
  accuracy <- (tp + tn) / length(human)
  data.frame(n = length(human), tp, fp, fn, tn,
             precision, recall, f1, accuracy)
}

# Authored teaching sentences, not speeches or independently observed human labels.
synthetic <- read.csv("Data/synthetic_validation.csv", stringsAsFactors = FALSE)
synthetic_text <- synthetic$text
names(synthetic_text) <- synthetic$doc_id
synthetic_tokens <- tokens(synthetic_text, remove_punct = FALSE)
synthetic_tokens <- tokens_tolower(synthetic_tokens)
synthetic_counts_v1 <- policy_counts(synthetic_tokens, energy_v1)
synthetic_counts_v2 <- policy_counts(synthetic_tokens, energy_v2)
synthetic$v1 <- as.integer(synthetic_counts_v1 > 0)
synthetic$v2 <- as.integer(synthetic_counts_v2 > 0)

# Evaluate the same two rules on development and test examples separately.
synthetic_development <- subset(synthetic, split == "development")
synthetic_test <- subset(synthetic, split == "test")
dev_v1 <- validate_binary(synthetic_development$v1, synthetic_development$human)
dev_v2 <- validate_binary(synthetic_development$v2, synthetic_development$human)
test_v1 <- validate_binary(synthetic_test$v1, synthetic_test$human)
test_v2 <- validate_binary(synthetic_test$v2, synthetic_test$human)
synthetic_results <- rbind(dev_v1, dev_v2, test_v1, test_v2)
synthetic_results$split <- c("development", "development", "test", "test")
synthetic_results$version <- c("v1", "v2", "v1", "v2")

# Fixed random split, independent of either dictionary's predictions.
set.seed(719104)
coding_ids <- sample(seq_len(nrow(speeches)), size = 80, replace = FALSE)
coding_template <- data.frame(
  doc_id = speeches$doc_id[coding_ids],
  split = c(rep("development", 30), rep("test", 50)),
  text = speeches$text[coding_ids],
  human = NA_integer_, evidence = "", coder = "", stringsAsFactors = FALSE
)
development_ids <- coding_template$doc_id[coding_template$split == "development"]
test_ids <- coding_template$doc_id[coding_template$split == "test"]
discovery_tokens <- policy_tokens[!docnames(policy_tokens) %in% test_ids]

# Explicit opt-in: rendering never overwrites annotations or exports text.
export_coding_templates <- function(output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  paths <- file.path(output_dir, paste0(c("development", "test"), "_coding.csv"))
  if (any(file.exists(paths))) stop("Existing coding files will not be overwritten.")
  for (part in c("development", "test")) {
    write.csv(coding_template[coding_template$split == part, ],
              file.path(output_dir, paste0(part, "_coding.csv")),
              row.names = FALSE, na = "", fileEncoding = "UTF-8")
  }
  invisible(paths)
}

evaluate_coding <- function(path, dict, split = "test") {
  if (!split %in% c("development", "test")) stop("Unknown evaluation split.")
  coded <- read.csv(path, stringsAsFactors = FALSE)
  required <- c("doc_id", "split", "text", "human", "evidence", "coder")
  if (!all(required %in% names(coded))) stop("Coding file is missing required columns.")
  expected <- coding_template[coding_template$split == split, ]
  if (nrow(coded) != nrow(expected) || anyDuplicated(coded$doc_id) ||
      !setequal(coded$doc_id, expected$doc_id)) {
    stop("Keep every assigned document, including unmatched and uncertain cases.")
  }
  idx <- match(coded$doc_id, expected$doc_id)
  if (anyNA(coded[, required]) || !all(coded$split == split) ||
      !identical(coded$text, expected$text[idx]) ||
      any(!nzchar(trimws(coded$evidence))) || any(!nzchar(trimws(coded$coder)))) {
    stop("Complete labels, evidence and coder; preserve the assigned split and text.")
  }
  predicted <- policy_counts(policy_tokens[coded$doc_id], dict) > 0
  metrics <- validate_binary(predicted, coded$human)
  coded$predicted <- as.integer(predicted)
  list(metrics = metrics, errors = coded[coded$predicted != coded$human, ])
}
