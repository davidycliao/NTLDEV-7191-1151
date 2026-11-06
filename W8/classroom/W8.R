# W8 topic-model lab: student edition.
# Open W8_lab.Rproj in RStudio. Keep one R session for all steps.
# Run ONE line or selected small block with Ctrl+Enter / Cmd+Enter.
# Read Console, Environment and Plots; check before continuing.
# Route labels: Before class / Run together / After class.
# Class route: R01a-c -> R02a-b -> R03a-b and E02 -> R05a-e and E05.
# Defer R03c-d and the optional R04 K check until after class.
# E02 and E05 are the in-class focus; finish the other exercises after class.
# Research question: which issues do leaders discuss, and how does attention vary by party?
# Build one DFM, fit LDA, check texts, then fit STM and estimate party comparisons.
# Primary steps fit the models in R; no Python or API is required.
# First-time packages: see R00 in the HTML handout.


# ==== R00a Load the R packages ====
# Route: Before class
# Purpose: Load the packages for this lab in one R session. Before first use, follow the
# installation instructions and run install.packages().
required <- c("quanteda", "quanteda.textstats", "seededlda", "stm",
  "dplyr", "tidyr", "ggplot2", "jsonlite")
missing <- required[!vapply(required, requireNamespace,
  quietly = TRUE, FUN.VALUE = logical(1))]
if (length(missing)) stop("Install these packages first: ",
  paste(missing, collapse = ", "))
invisible(lapply(required, function(p)
  suppressPackageStartupMessages(library(p, character.only = TRUE))))
options(width = 100, seededlda_threads = 1)
cat("Packages loaded:", paste(required, collapse = ", "), "\n")
# Interpretation: A successful run lists the package names on the final line. Install
# packages once, but load them again in every new session.

# ==== R00b Locate the speech input ====
# Route: Before class
# Purpose: Locate the supplied speech sample and set the plotting colours.
lab_file <- function(name) file.path("analysis", "ess_lab", name)
if (!file.exists(lab_file("sample_raw.rds"))) {
  stop("Open W8_lab.Rproj, then run R00b again.")
}
party_colors <- c(Conservative = "#003B73", Labour = "#B00020")
cat("W8 speech input found. Ready to build and fit both models.\n")
# Interpretation: lab_file() locates the speech input. We build the counts and fit both
# models in the following steps.
# Before you continue: The package list loads without an error.
# `lab_file("sample_raw.rds")` is found before you start R01.

# ==== R01a Read file ====
# Route: Run together
# Purpose: Read the ESS speech table and create a quanteda corpus.
topic_docs <- readRDS(lab_file("sample_raw.rds"))
topic_corpus <- corpus(
  topic_docs, text_field = "text", docid_field = "doc_id")
print(topic_docs[1:3,
  c("doc_id", "leader", "party_family", "date")])
print(c(speeches = ndoc(topic_corpus)))
# Interpretation: A corpus is a collection of texts. Here, one document is one complete
# speech. The words have not been split or counted yet.

# ==== R01b Split and clean the words ====
# Route: Run together
# Purpose: Keep an unprocessed view of one speech, then clean the full corpus for both
# analyses.
id <- "ess_hoc_00004"
raw_tokens <- tokens(topic_corpus[id], what = "word")
parliamentary_stopwords <- c("hon", "member", "right", "friend", "sir",
  "gentleman", "lady", "house", "commons", "speaker", "minister",
  "secretary", "asked", "question", "mr", "mrs", "ms", "â", "ã")
clean_tokens <- tokens(topic_corpus, remove_punct = TRUE,
  remove_symbols = TRUE, remove_numbers = TRUE, remove_url = TRUE,
  remove_separators = TRUE, split_hyphens = FALSE) |>
  tokens_tolower() |> tokens_remove(stopwords("en")) |>
  tokens_remove(parliamentary_stopwords)
print(raw_tokens[[id]][1:21])
print(clean_tokens[[id]][1:8])
# Interpretation: Tokenization splits speeches into word units. Cleaning removes
# punctuation, symbols, numbers, URLs, common English words and the listed parliamentary
# words. Each removal is a research choice.

# ==== R01c Turn cleaned words into a DFM ====
# Route: Run together
# Purpose: Combine common multiword expressions, count the words and trim one DFM for both
# LDA and STM.
collocations <- textstat_collocations(
  clean_tokens, min_count = 8, size = 2:3) |> arrange(desc(lambda))
model_tokens <- tokens_compound(clean_tokens,
  phrase(head(collocations$collocation, 30)))
topic_dfm <- dfm(model_tokens) |>
  dfm_trim(min_termfreq = 5, min_docfreq = 2) |>
  dfm_trim(max_docfreq = .75, docfreq_type = "prop")
topic_dfm <- topic_dfm[ntoken(topic_dfm) > 0, ]
topic_docs <- topic_docs[match(docnames(topic_dfm), topic_docs$doc_id), ]
topic_docs$retained_tokens <- as.numeric(ntoken(topic_dfm))
stopifnot(identical(topic_docs$doc_id, docnames(topic_dfm)))
print(c(speeches = ndoc(topic_dfm), features = nfeat(topic_dfm),
  tokens = sum(ntoken(topic_dfm))))
print(topfeatures(topic_dfm, 6))
# Interpretation: One DFM now contains 719 speeches, 2,831 features and 70,813 retained
# tokens. Rows are speeches, columns are words or compounded expressions, and cells are
# counts. Both models use these same counts.
# Before you continue: You have 719 speech documents. Confirm 2,831 features and 70,813
# retained tokens. Explain one compounding or trimming choice.

# ---- E01 From speeches to word counts ----
# Route: After class
# Confirm that one document is one complete speech. Compare the raw and cleaned words for
# ess_hoc_00004, then report the DFM's documents, features and retained tokens. Explain
# how compounding common expressions and trimming the vocabulary change the input to both
# models.
# TODO: write your R code here.
# TODO: write your interpretation here.

# ==== R02a Fit a six-topic LDA model ====
# Route: Run together
# Purpose: Fit LDA to the DFM, then inspect the topic words and document-topic matrix.
set.seed(20260710)
lda_6 <- textmodel_lda(topic_dfm, k = 6, alpha = .5, beta = .1,
  max_iter = 500, auto_iter = FALSE, batch_size = 1, verbose = FALSE)
print(terms(lda_6, 10))
print(dim(lda_6$theta))
# Interpretation: The model estimates topic-word probabilities and a topic mixture for
# every speech. terms() lists the highest-probability words; theta has one row per speech
# and six topic columns. The seed and finite iteration budget support reproduction, not
# automatic validity.

# ==== R02b Read complete topic mixtures ====
# Route: Run together
# Purpose: Inspect the complete topic mixture for a speech, then examine what the dominant
# topic retains as a summary.
print(round(head(lda_6$theta, 3), 3))
print(range(rowSums(lda_6$theta)))
dominant_topic <- max.col(lda_6$theta, ties.method = "first")
names(dominant_topic) <- topic_docs$doc_id
print(head(dominant_topic, 5))
print(table(dominant_topic))
# Interpretation: Each complete theta row sums to one before rounding. dominant_topic
# keeps only the number with the largest share and takes the first in a tie. This fixed
# rule is easy to reproduce but retains less information than the complete mixture.
# Before you continue: Use a `theta` row, not `dominant_topic`, when you want to show that
# one speech can discuss several topics. Write two provisional topic labels to test
# against the original speeches in R03.

# ==== R03a Retrieve concentrated and mixed speeches ====
# Route: Run together
# Purpose: Use doc_id to retrieve a high-T1 speech and the speech with the most diffuse
# mixture.
theta <- lda_6$theta
high_i <- which.max(theta[, 1])
mixed_i <- which.min(apply(theta, 1, max))
print(topic_docs[c(high_i, mixed_i),
  c("doc_id", "leader", "party_family", "date")])
print(round(theta[c(high_i, mixed_i), ], 4))
print(rowSums(theta[c(high_i, mixed_i), , drop = FALSE]))
# Interpretation: These two examples were selected from model results for interpretation;
# they are not a random validation sample. The complete proportions reveal secondary
# issues.

# ==== R03b Read the original speech ====
# Route: Run together
# Purpose: Return to the complete text and check whether the word list and proportions
# support your proposed label.
cat("Document:", topic_docs$doc_id[high_i], "\n")
cat(topic_docs$text[high_i], "\n")
cat("Mixed document:", topic_docs$doc_id[mixed_i], "\n")
cat(topic_docs$text[mixed_i], "\n")
# Interpretation: The R Console displays the complete speech. After finding topic-relevant
# passages, also check whether other passages change the interpretation of the whole
# speech.

# ---- E02 Words and provisional labels ----
# Route: In-class focus
# Display the top ten words for the six-topic LDA. Propose two provisional labels. Support
# one with a document ID and an exact quotation, and describe a text that could challenge
# the label.
# TODO: write your R code here.
# TODO: write your interpretation here.
# In class: after E02, go directly to R05a. R03c–R03d and R04 are after-class work. R05
# fits STM and the conditional comparison from the DFM built in R01.

# ==== R03c Calculate party means ====
# Route: After class
# Purpose: Reshape each speech's topic proportions to long form and calculate equal-weight
# party means.
lda_theta <- as.data.frame(theta)
colnames(lda_theta) <- paste0("topic_", seq_len(ncol(theta)))
lda_theta$doc_id <- topic_docs$doc_id
lda_theta$party_family <- topic_docs$party_family
lda_theta_long <- lda_theta |> pivot_longer(starts_with("topic_"),
  names_to = "topic", values_to = "proportion")
party_topic_means <- lda_theta_long |> group_by(party_family, topic) |>
  summarise(mean_proportion = mean(proportion), .groups = "drop")
print(as.data.frame(party_topic_means), row.names = FALSE)
# Interpretation: The denominator of each mean is the number of sampled speeches for that
# party. Every speech receives equal weight.

# ==== R03d Plot the party means in R ====
# Route: After class
# Purpose: Plot the values from the previous step and read the topic numbers alongside
# your provisional labels.
p_lda_party <- ggplot(party_topic_means,
  aes(topic, mean_proportion, fill = party_family)) +
  geom_col(position = "dodge") + coord_flip() +
  scale_fill_manual(values = party_colors) +
  labs(x = NULL, y = "Mean proportion per speech", fill = NULL) +
  theme_minimal(base_size = 16)
print(p_lda_party)
# Interpretation: The RStudio Plots pane shows the mean proportions by party. The plot and
# table use the same party_topic_means object.
# Before you continue: Support one provisional label with an exact quotation. Report the
# two LDA Topic 1 party means and state whether they give equal weight to speeches or to
# words.

# ---- E03 Mixtures and party means ----
# Route: After class
# After class, retrieve Reading texts A and B by doc_id. Print all six topic proportions
# and their sums. Compare this information with keeping only the largest topic. Then use
# party_topic_means and its plot to compare LDA Topic 1 between parties. Report the two
# mean shares, state how speeches are weighted, and explain why the plot does not
# establish a causal party effect.
# TODO: write your R code here.
# TODO: write your interpretation here.

# ==== R04a Read alternative topic resolutions ====
# Route: After class
# Purpose: Read the LDA K=3, 6, and 9 and STM K=5 and 6 models fitted to the same
# documents and vocabulary. First examine how the LDA word groups split or merge.
k_candidates <- c(3, 6, 9)
lda_models <- lapply(k_candidates, function(k_value)
  readRDS(lab_file(paste0("lda", k_value, ".rds"))))
names(lda_models) <- paste0("K", k_candidates)
stm_models <- lapply(c(5, 6), function(k_value)
  readRDS(lab_file(paste0("stm", k_value, ".rds"))))
print(lapply(lda_models, terms, 5))
# Interpretation: Each model has its own topic numbers; matching numbers do not identify
# the same issue. All five use the same DFM. The three LDA fits share priors and iteration
# budgets; STM uses party and period as prevalence covariates.

# ==== R04b Calculate training perplexity ====
# Route: After class
# Purpose: Apply one token-weighted word-probability calculation to the saved LDA and STM
# fits and the same training DFM.
training_perplexity <- function(model, data) {
  is_stm <- inherits(model, "STM")
  vocab <- if (is_stm) model$vocab else colnames(model$phi)
  phi <- if (is_stm) exp(model$beta$logbeta[[1]]) else model$phi
  counts <- as.matrix(data[, vocab])
  probabilities <- pmax(model$theta %*% phi, 1e-12)
  exp(-sum(counts * log(probabilities)) / sum(counts))
}
perplexity_results <- data.frame(Model = c("LDA", "LDA", "LDA", "STM", "STM"),
  k = c(3, 6, 9, 5, 6), perplexity = vapply(c(lda_models, stm_models),
    training_perplexity, numeric(1), data = topic_dfm))
print(perplexity_results, row.names = FALSE)
# Interpretation: Lower means better reconstruction of these training word counts using
# fitted theta and phi. Both were estimated from these words: this is resubstitution, not
# held-out prediction. STM stores log word probabilities, so exp() converts them and vocab
# aligns the DFM columns. Neither STM has a content covariate. Within each fit, one topic-
# word matrix is shared across documents; the two fits have different matrices.

# ==== R04c Plot training fit in R ====
# Route: After class
# Purpose: Plot the five training diagnostics in separate LDA and STM panels while keeping
# their common evaluation definition visible.
p_perplexity <- ggplot(perplexity_results, aes(k, perplexity)) +
  geom_line() + geom_point(color = "#B00020", size = 3) +
  facet_wrap(~ Model) + scale_x_continuous(breaks = c(3, 5, 6, 9)) +
  labs(x = "Number of topics (K)", y = "Training perplexity",
    subtitle = "Same training words; token-weighted plug-in score") +
  theme_minimal(base_size = 16)
print(p_perplexity)
# Interpretation: Each point corresponds to one row of perplexity_results. The panels use
# the same scale. Lower training perplexity alone cannot identify the best K or establish
# that LDA or STM is superior; the model structures and fitting procedures differ.
# Before you continue: All five scores reuse the same training word counts. A lower value
# cannot by itself identify the best K or a superior model family. Name one check using
# topic words or original speeches.

# ---- E04 K and diagnostic evidence ----
# Route: After class
# After class, run R04a–R04c and read the five LDA and STM training diagnostics. Within
# LDA, compare K=3, 6 and 9 using words and at least one shared document. Why does lower
# training perplexity not establish the best K or a superior model family for your
# political question? Propose a resolution and explain what additional evidence is needed.
# TODO: write your R code here.
# TODO: write your interpretation here.

# ==== R05a Fit STM with party and period ====
# Route: Run together
# Purpose: Add aligned document metadata and fit STM to the same DFM before comparing
# parties.
metadata <- data.frame(
  doc_id = topic_docs$doc_id,
  party_family = topic_docs$party_family,
  period = topic_docs$period)
design <- model.matrix(~ party_family + period, metadata)
stopifnot(qr(design)$rank == ncol(design))
stm_input <- convert(topic_dfm, to = "stm")
stm_6 <- stm(stm_input$documents, vocab = stm_input$vocab, K = 6,
  prevalence = ~ party_family + period, data = metadata,
  seed = 20260710, init.type = "Spectral", max.em.its = 100,
  emtol = 1e-4, verbose = FALSE)
print(labelTopics(stm_6, topics = 4, n = 5))
# Interpretation: This STM has K=6 and uses party_family and categorical period as
# prevalence covariates, with no content covariate. STM topic 4 is not the same as LDA
# topic 4.

# ==== R05b Calculate raw STM party differences ====
# Route: Run together
# Purpose: Calculate unadjusted means within the same STM so differences between models
# are not mistaken for adjustment effects.
stm_theta <- as.data.frame(stm_6$theta)
colnames(stm_theta) <- paste0("topic_", seq_len(ncol(stm_theta)))
stm_theta$party_family <- topic_docs$party_family
stm_party_means <- stm_theta |> pivot_longer(starts_with("topic_"),
  names_to = "topic", values_to = "proportion") |>
  group_by(party_family, topic) |>
  summarise(mean = mean(proportion), .groups = "drop")
stm_raw_differences <- stm_party_means |>
  pivot_wider(id_cols = topic, names_from = party_family, values_from = mean) |>
  mutate(difference = Labour - Conservative)
print(stm_raw_differences[stm_raw_differences$topic == "topic_4", ])
# Interpretation: The difference is defined as Labour minus Conservative. The raw means
# and later adjusted comparison use the same STM.

# ==== R05c Estimate the conditional comparison ====
# Route: Run together
# Purpose: Estimate the party-and-period association and simulate its comparison
# intervals.
set.seed(20260710)
stm_party_effects <- estimateEffect(1:6 ~ party_family + period,
  stmobj = stm_6, metadata = metadata,
  uncertainty = "Global", nsims = 50)
set.seed(20260710)
adjusted_result <- plot(stm_party_effects,
  covariate = "party_family", method = "difference",
  cov.value1 = "Labour", cov.value2 = "Conservative",
  topics = 1:6, nsims = 1000, omit.plot = TRUE,
  labeltype = "numbers")
print(adjusted_result$means[4])
print(adjusted_result$cis[[4]])
# Interpretation: estimateEffect uses the fitted STM with the same party and categorical-
# period variables. Global uncertainty uses 50 simulations; the contrast uses 1,000
# simulations after resetting the seed. omit.plot returns the numbers for the next table
# and plot.

# ==== R05d Create a comparison table ====
# Route: Run together
# Purpose: Assemble the conditional differences for all six topics in a data frame, then
# inspect topic 4.
adjusted_differences <- data.frame(topic = paste0("topic_", 1:6),
  difference = unlist(adjusted_result$means),
  lower = vapply(adjusted_result$cis, `[`, numeric(1), 1),
  upper = vapply(adjusted_result$cis, `[`, numeric(1), 2))
print(adjusted_differences[adjusted_differences$topic == "topic_4", ],
  row.names = FALSE)
# Interpretation: lower and upper are endpoints of an approximate model-simulation
# interval. They do not identify a causal effect of party affiliation.

# ==== R05e Plot the STM associations in R ====
# Route: Run together
# Purpose: Plot adjusted_differences as points and intervals while preserving the
# direction of the difference.
p_stm_adjusted <- ggplot(adjusted_differences, aes(difference, topic)) +
  geom_vline(xintercept = 0, linetype = 2) + geom_point() +
  geom_errorbar(aes(xmin = lower, xmax = upper),
    orientation = "y", width = .15) +
  labs(x = "Labour minus Conservative: conditional association", y = NULL) +
  theme_minimal(base_size = 16)
print(p_stm_adjusted)
# Interpretation: The vertical line marks zero difference, and the horizontal lines show
# the simulation intervals. The concepts represented by each topic still require
# interpretation from words and texts.
# Before you continue: State the direction of the comparison: Labour minus Conservative.
# Explain why the interval describes uncertainty within the fitted model, not a causal
# party effect.

# ---- E05 STM associations ----
# Route: In-class focus
# For STM topic 4, inspect probability and FREX words, raw party means and the adjusted
# Labour-minus-Conservative comparison. Report the direction and size of the adjusted
# difference in percentage points. State the covariates and the meaning of the interval.
# Write one conclusion the evidence supports and one causal claim it does not establish.
# TODO: write your R code here.
# TODO: write your interpretation here.
