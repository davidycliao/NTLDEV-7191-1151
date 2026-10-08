#' ---
#' title: "W4 Lab: Worked Answers"
#' subtitle: "LIWC-format dictionaries, custom policy rules, and a W6 preview"
#' format:
#'   html:
#'     embed-resources: true
#'     toc: true
#' execute:
#'   warning: false
#'   message: false
#' ---
#' 
#' These answers use the supplied files. The `.dic` is original teaching material, not an official LIWC lexicon. Synthetic labels support arithmetic practice, **not empirical accuracy claims**. There are no supplied gold labels for real parliamentary texts. [Return to the student handout](../Lab_Session_W4.html).
#' 
## -----------------------------------------------------------------------------
# install.packages("quanteda")  # run once before class
library(quanteda)
# Find the lab folder; if asked, select workflow.R inside W4/lab.
paths <- c("W4/lab/workflow.R", "lab/workflow.R",
           "../lab/workflow.R", "../workflow.R", "workflow.R")
found <- paths[file.exists(paths)]
if (length(found) == 0) found <- file.choose()
setwd(dirname(normalizePath(found[1])))
source("workflow.R")  # load the data and prepared examples

#' 
#' Run the setup block once, then follow sections 1–4 in order. If a file picker opens, choose `workflow.R` inside the extracted lab. The party comparison is optional.
#' 
#' ## 1. LIWC format and sentiment
#' 
## -----------------------------------------------------------------------------
toy_sentiment
texts <- c("The policy is good.", "The policy is not good.")
example_tokens <- tokens(texts, remove_punct = TRUE)
example_dfm <- dfm(example_tokens)
example_hits <- dfm_lookup(example_dfm, toy_sentiment)
counts <- convert(example_hits, to = "data.frame")
counts
word_count <- ntoken(example_tokens)
positive <- counts$positive
negative <- counts$negative
100 * (positive - negative) / word_count
# The setup above created these five named examples.
check_texts
check_tokens <- tokens(check_texts, remove_punct = TRUE)
check_dfm <- dfm(check_tokens)
check_hits <- dfm_lookup(check_dfm, toy_sentiment)
convert(check_hits, to = "data.frame")

# Prepared by workflow.R using the three formulas explained in class.
check_scores

# TRUE counts as 1; the mean is the fraction without a match.
mean(sentiment$no_match)

#' 
#' Category 1 is `positive`; category 2 is `negative`. The dictionary matches words without interpreting who or what is being evaluated. The prepared `check_scores` table uses the original dictionary; changing a dictionary requires rerunning the scoring code.
#' 
#' `Good` scores 25 net matches per 100 tokens; `not good` scores 20. The positive match remains because the rule does not interpret negation. The denominator changes, not the category. Unmatched text has zero coverage; balanced text has nonzero coverage but zero net tone; empty text has a zero denominator and missing rates. The corpus unmatched fraction is not the neutral-speech fraction.
#' 
#' We do not reproduce official LIWC dictionaries or the LIWC-22 Tone summary measure. A legacy-format import does not make quanteda scoring identical to LIWC. See [LIWC Analysis](https://liwc.app/help/liwc) and [quanteda import documentation](https://quanteda.io/reference/dictionary.html).
#' 
#' ## 2. Build an energy-policy dictionary
#' 
## -----------------------------------------------------------------------------
policy_entries <- read.csv("Dictionaries/energy_policy.csv")
v1_entries <- subset(policy_entries, version == "v1")
energy_v1 <- dictionary(list(energy = v1_entries$pattern))
v2_entries <- subset(policy_entries, version == "v2")
energy_v2 <- dictionary(list(energy = v2_entries$pattern))
contexts <- kwic(discovery_tokens, pattern = c("power", "gas", "bill*"),
                 valuetype = "glob", window = 8)
head(contexts, 8)
example_context <- kwic(discovery_tokens, pattern = "bill*", window = 8)
# The supplied corpus contains matches to bill*.
first_id <- example_context$docname[1]
original <- subset(speeches, doc_id == first_id)
original$text


#' 
#' `Power` may denote authority; `bill*` can retrieve legislation or other prefixes; `gas` can concern crowd control. Narrower rules can still miss implicit energy references and match figurative energy. Read the passage before deciding. A proposed v3 needs a development-set justification, not an assumption that more entries improve measurement.
#' 
#' ### Change one rule, then rerun
#' 
#' V1 includes `power`, which can mean political authority. Replace it with `wind farm*`, then compare the old and revised dictionaries on two teaching sentences:
#' 
## -----------------------------------------------------------------------------
energy_revised <- dictionary(list(
  energy = c("energy", "wind farm*", "electric*", "gas", "bill*")
))
revision_texts <- c(
  wind = "The government should approve new wind farms.",
  authority = "Parliament must retain the power to question ministers."
)
revision_tokens <- tokens(revision_texts, remove_punct = FALSE)

before_tokens <- tokens_lookup(revision_tokens, energy_v1, capkeys = FALSE)
before_counts <- convert(dfm(before_tokens), to = "data.frame")
after_tokens <- tokens_lookup(revision_tokens, energy_revised, capkeys = FALSE)
after_counts <- convert(dfm(after_tokens), to = "data.frame")

data.frame(sentence = before_counts$doc_id,
           before = before_counts$energy,
           after = after_counts$energy)

#' 
#' **Read the result:** `wind` changes from 0 to 1; `authority` changes from 1 to 0. We added a useful match and removed an irrelevant one. This does not show that the revised dictionary works well on all speeches.
#' 
#' **Try:** in your own `energy_revised`, add or remove one entry, or replace a broad word with a phrase. Rerun the matching code after each change. Use `kwic(discovery_tokens, phrase("wind farm*"))` as a template to inspect your term in real context; read the original speech before deciding. Write down the term you changed, a supporting passage and one possible mistake. This exercise changes the word list; it does not implement context-dependent exclusion rules.
#' 
#' For the remaining worked examples, use the supplied **`energy_v2`**. Your experimental dictionary is saved separately as `energy_revised`, so everyone can reproduce the same validation results.
#' 
#' ## 3. Development errors
#' 
## -----------------------------------------------------------------------------
# Read the labelled teaching examples and generate predictions explicitly.
synthetic <- read.csv("Data/synthetic_validation.csv")
example_corpus <- corpus(synthetic, text_field = "text", docid_field = "doc_id")
example_tokens <- tokens(example_corpus, remove_punct = FALSE)

# Apply v1, then v2. Each matched phrase counts once.
v1_matches <- tokens_lookup(example_tokens, energy_v1, capkeys = FALSE)
v1_dfm <- dfm(v1_matches)
v1_binary <- dfm_weight(v1_dfm, scheme = "boolean")
v1_predictions <- convert(v1_binary, to = "data.frame")
synthetic$v1 <- v1_predictions$energy

v2_matches <- tokens_lookup(example_tokens, energy_v2, capkeys = FALSE)
v2_dfm <- dfm(v2_matches)
v2_binary <- dfm_weight(v2_dfm, scheme = "boolean")
v2_predictions <- convert(v2_binary, to = "data.frame")
synthetic$v2 <- v2_predictions$energy

dev <- subset(synthetic, split == "development")
errors <- subset(dev, v1 != human)
errors[, c("doc_id", "text", "human", "v1", "v2")]

#' 
#' Development examples motivate removing standalone `power`, `gas` and `bill*`, and adding renewable/solar/wind/fossil-fuel expressions. V2 still mistakes personal energy for energy-policy attention. A context rule might help but needs development and separate evaluation. These sentences were authored to expose the distinctions; this is not an independent empirical study.
#' 
#' ## 4. Synthetic test results
#' 
## -----------------------------------------------------------------------------
test <- subset(synthetic, split == "test")
# 0 = not relevant; 1 = relevant. Keep both categories in the table.
predicted <- factor(test$v2, levels = c(0, 1))
human <- factor(test$human, levels = c(0, 1))
table(predicted, human)
errors <- subset(test, v2 != human)
errors[, c("doc_id", "text", "human", "v2")]

#' 
#' Calculate the counts and fractions explicitly:
#' 
## -----------------------------------------------------------------------------
predicted <- test$v2
human <- test$human
TP <- sum(predicted == 1 & human == 1)
FP <- sum(predicted == 1 & human == 0)
FN <- sum(predicted == 0 & human == 1)
TN <- sum(predicted == 0 & human == 0)
precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
F1 <- 2 * TP / (2 * TP + FP + FN)
c(TP = TP, FP = FP, FN = FN, TN = TN)
c(precision = precision, recall = recall, F1 = F1)

#' 
#' These denominators are nonzero. In other data, report an undefined rate as `NA` when its denominator is zero.
#' 
#' For v2: **TP = 4, FP = 1, FN = 2, TN = 5**. Precision = **0.80**, recall = **0.667**, F1 = **0.727**. V1 has the same four true positives but four false positives. V2 still matches figurative energy and misses coal-mine closure and heating tariffs. These are teaching results, not estimates for Parliament.
#' 
#' Inspecting matches alone cannot reveal false negatives or estimate recall. Accuracy can reward always-negative predictions for a rare category. F1 omits true negatives; report counts, sampling, uncertainty and error costs too. Precision is undefined without predicted positives; recall is undefined without reference positives.
#' 
#' Do not add `coal` or `heating` after viewing test errors and call the updated score untouched-test performance. A new version needs a new test. Coder agreement is not proof of construct validity either.
#' 
#' ## W6 preview: labels before models
#' 
#' W5 (October 9) is a holiday. W6 (October 16), **Human Coding and Document Classification**, covers annotation quality, inter-coder reliability, training/test sets and performance; its lab introduces Naive Bayes, SVM and cross-validation.
#' 
#' The five-text warm-up asks for defensible decisions, not answer-key labels. Identify a passage, apply the inclusion/exclusion rules, and explain uncertainty. Discuss difficult cases and refine the development codebook in W6. No model training or extra submission is required now.
#' 
#' Five cases are not enough for training or reliable evaluation. Do not convert dictionary predictions into supposed human ground truth. Labels discussed while choosing a model become development material; final testing requires separate cases. Fitting a model does not establish the validity of its categories.
#' 
#' ## Real-text validation in W6
#' 
#' Use the [three labeling rules in the handout](../Lab_Session_W4.html#energy-label-rules) for the five-text preview. The full export, independent coding and evaluation procedure is deferred to W6. No separate coding-guide file is needed for W4.
#' 
#' The real speeches have no supplied human labels. The synthetic scores above do not estimate performance on Parliament, and an energy-attention F1 does not validate emotion scores.
#' 
#' ## Optional: compare parties
#' 
## -----------------------------------------------------------------------------
# quanteda adds counts within each party.
party_matches <- tokens_lookup(policy_tokens, energy_v2, capkeys = FALSE)
party_dfm <- dfm(party_matches)
party_dfm <- dfm_group(party_dfm, groups = party)

# Group original word counts separately to preserve the denominator.
party_words <- dfm(toks)
party_words <- dfm_group(party_words, groups = party)

party_summary <- convert(party_dfm, to = "data.frame")
party_summary$tokens <- ntoken(party_words)
party_summary$per1000 <- 1000 * party_summary$energy / party_summary$tokens
head(party_summary, 6)


#' 
#' `dfm_group()` adds document counts within each party. `ntoken()` supplies the grouped original word totals; `convert()` produces the displayed table. Within each party, divide total matches by total original word counts. Raw counts depend on speaking volume. Normalized pooled sample rates still do not establish policy support, stable party differences or a causal effect; dates and topics differ.
#' 
#' ## R session information
#' 
## -----------------------------------------------------------------------------
sessionInfo()

