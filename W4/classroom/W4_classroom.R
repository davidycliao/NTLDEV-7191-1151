# W4 classroom activities. Select one numbered block at a time.
# Scheduled student route: C01, C04, C07, C10, C11, C14.
# Finish with examples/W4_campaign_simple.R; C16 is an alternative or self-study.
# Other blocks are instructor demonstrations or self-study; do not source all.
# Blocks follow the slides; IDs stay fixed, so C15 follows C12.
# C06 requires C03 (recap_dfm); C15 requires C12 (dev).
# Use R >= 4.1; install these packages once before class:
# install.packages(c("quanteda", "quanteda.textstats"))
# Optional C13 only: install.packages("irr")
# Optional C15 only: install.packages("ggplot2")
# C01 detects common classroom paths. If asked, choose classroom/workflow.R.
# Keep Data, Dictionaries and workflow.R together; extract the ZIP first.
# <- saves an object; $ selects a column; [rows, columns] selects table cells.
# head(x, 6) displays the first six rows; TRUE/FALSE describe a condition.
# source("workflow.R") runs the supplied preparation, not a package function.
# C02, C07 and C13 run independently; C16 needs only the classroom working directory.
# All core activities run locally after installation. No API key is required.
# Tiny constructed examples teach arithmetic; real speeches have no gold labels.
# These are course exercises, not replications of the assigned paper results.
# Source: slide/week4-presenter.qmd; regenerate with scripts/publish_classroom.py.

# Run setup once, then continue to C02 (Bag of words).
# C01: Setup
# First use: uncomment the next line to install.
# install.packages(c("quanteda", "quanteda.textstats"))
library(quanteda)
library(quanteda.textstats)
paths <- c("workflow.R", "W4/classroom/workflow.R",
           "classroom/workflow.R", "../classroom/workflow.R")
found <- paths[file.exists(paths)]
if (length(found) == 0) found <- file.choose()
setwd(dirname(normalizePath(found[1])))
source("workflow.R")

# Optional check: uncomment to see the number of speech contributions.
# Not required for today's examples; 50 are reserved for optional human validation.
# c(all = nrow(speeches), discovery = ndoc(discovery_tokens))

# Predict the prices count; compare selected features with full lengths.
# C02: Counts and document length
library(quanteda)
demo <- c(A = "Prices rise. Prices worry voters.",
          B = "Prices fall.")
demo_tokens <- tokens(demo, remove_punct = TRUE)
demo_dfm <- dfm(demo_tokens)
selected <- dfm_match(demo_dfm, c("prices", "rise", "fall"))
as.matrix(selected)
ntoken(demo_tokens)

# Compare occurrences with speeches; show 12 rows and identify procedural terms.
# C03: Frequency in real speeches (run C01 first)
recap_dfm <- dfm(discovery_tokens)
recap_dfm <- dfm_remove(recap_dfm, stopwords("en"))
# Keep words made of English letters only.
recap_dfm <- dfm_select(recap_dfm, "^[a-z]+$", valuetype = "regex")
freq <- textstat_frequency(recap_dfm)
head(freq, 6)

# Classify two matches in pairs; rerun with window = 12.
# C04: Context in real speeches (run C01 first)
live_contexts <- kwic(discovery_tokens, "security", window = 5)
context_table <- as.data.frame(live_contexts)
columns <- c("docname", "pre", "keyword", "post")
head(context_table[, columns], 2)

# Raise min_count to 50; use KWIC before choosing a dictionary phrase.
# C05: Phrases in real speeches (run C01 first)
coll <- textstat_collocations(discovery_tokens, size = 2, min_count = 20)
row_order <- order(coll$lambda, decreasing = TRUE)
coll <- coll[row_order, ]
head(coll, 6)
first_phrase <- phrase(coll$collocation[1])
phrase_context <- kwic(discovery_tokens, first_phrase, window = 5)
head(phrase_context, 2)

# Compare each party's top three words; positive keyness is not sentiment.
# C06: Relative word use (run C01 and C03 first)
party_dfm <- dfm_subset(recap_dfm,
  party %in% c("Conservative", "Labour"))
party_dfm <- dfm_group(party_dfm, groups = party)
party_dfm <- dfm_trim(party_dfm, min_termfreq = 1)
keys_con <- textstat_keyness(party_dfm, target = "Conservative")
keys_lab <- textstat_keyness(party_dfm, target = "Labour")
head(keys_con, 3)
head(keys_lab, 3)

# Add "cannot afford heating" to the dictionary and rerun lookup.
# C07: A complete phrase-lookup example
library(quanteda)
examples <- c("Energy bills are rising.",
              "This bill reforms parliament.",
              "Families cannot afford heating.")
example_tokens <- tokens(examples, remove_punct = FALSE)
cost_dict <- dictionary(list(costs = "energy bills"))
matched <- tokens_lookup(example_tokens, cost_dict)
cost_counts <- dfm(matched)
as.matrix(cost_counts)

# Predict unexpected bill* matches; explain what exact matching cannot fix.
# C08: Wildcards in real speeches (run C01 first)
wild <- kwic(discovery_tokens, "bill*", window = 0)
exact <- kwic(discovery_tokens, c("bill", "bills"),
              valuetype = "fixed", window = 0)
c(wildcard = nrow(wild), exact = nrow(exact))
word_counts <- table(wild$keyword)
word_counts <- sort(word_counts, decreasing = TRUE)
head(word_counts, 8)

# Compare the two rankings; change the minimum length to 100 and rerun.
# C09: Rankings on real speeches (run C01 first)
discovery_ids <- docnames(discovery_tokens)
rates <- subset(comparison, doc_id %in% discovery_ids)
rates <- subset(rates, tokens >= 50)
cols <- c("doc_id", "broad", "tokens", "broad_per100")
raw_order <- order(rates$broad, decreasing = TRUE)
rate_order <- order(rates$broad_per100, decreasing = TRUE)
head(rates[raw_order, cols], 3)
head(rates[rate_order, cols], 3)

# Inspect the texts first; explain zero versus NA in all three summaries.
# C10: Zero, balance and missing matches
check_texts
check_scores[, c("doc_id", "positive", "negative",
                 "net_per100", "coverage_per100", "balance")]

# Predict the effect of not; explain why retaining it is insufficient.
# C11: A deliberate sentiment failure (run C01 first)
negation_tokens <- check_tokens[c("good", "negated")]
as.list(negation_tokens)
negation_dfm <- dfm(negation_tokens)
negation_counts <- dfm_lookup(negation_dfm, toy_sentiment)
as.matrix(negation_counts)
without_stopwords <- tokens_remove(negation_tokens, stopwords("en"))
as.list(without_stopwords)

# Inspect the entries first; predict which version flags more speeches.
# C12: Dictionary revisions (run C01 first)
policy_entries[, c("version", "category", "pattern")]
dev <- subset(policy_scores,
  doc_id %in% docnames(discovery_tokens))
c(v1 = sum(dev$v1 > 0), v2 = sum(dev$v2 > 0))
energy_context <- kwic(discovery_tokens, "energy", window = 5)
head(energy_context, 3)

# Locate unchanged scores; explain what the scatterplot cannot validate.
# C15: Visualizing dictionary sensitivity (run C12 first)
# install.packages("ggplot2")  # run once
library(ggplot2)
ggplot(dev, aes(x = v1_per1000, y = v2_per1000)) +
  geom_point(size = 1, alpha = 0.4, colour = "#314f4f") +
  geom_abline(intercept = 0, slope = 1,
              colour = "firebrick", linetype = "dashed") +
  labs(x = "v1 matches per 1,000 tokens",
       y = "v2 matches per 1,000 tokens") +
  theme_minimal()

# Count matching human labels; explain why agreement and kappa differ.
# C13: Human agreement, not model accuracy
# install.packages("irr")  # run once
library(irr)
ratings <- data.frame(
  coder_A = c(1, 1, 1, 1, 1, 0, 0, 0, 0, 0),
  coder_B = c(1, 1, 1, 1, 0, 1, 0, 0, 0, 0))
table(ratings$coder_A, ratings$coder_B)
mean(ratings$coder_A == ratings$coder_B)
agreement <- kappa2(ratings, weight = "unweighted")
agreement$value

# Count TP, FP and FN, then divide. These denominators are nonzero in this example.
# C14: Checking validation arithmetic (run C01 first)
predicted <- validation$predicted
human <- validation$human
TP <- sum(predicted == 1 & human == 1)
FP <- sum(predicted == 1 & human == 0)
FN <- sum(predicted == 0 & human == 1)
precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
F1 <- 2 * TP / (2 * TP + FP + FN)
c(precision = precision, recall = recall, F1 = F1)

# Import our original list; compare category counts with all word tokens.
# C16: Custom dictionary (run C01; stay in W4/classroom)
library(quanteda)
own <- dictionary(file = "Dictionaries/teaching_affect.dic", format = "LIWC")
mini <- tokens(c("Good policy.", "A bad crisis."), remove_punct = TRUE)
matched <- tokens_lookup(mini, own, capkeys = FALSE)
hits <- dfm(matched)
counts <- as.matrix(hits)
counts
word_count <- ntoken(mini)
100 * counts / word_count
