# W4: simple examples for students with basic R skills.
# Install once before class: install.packages("quanteda")
# Copy one complete BEGIN / END block into R at a time.
# Each block is independent; all texts and labels are constructed examples.

# BEGIN C02
library(quanteda)
texts <- c(A = "Prices rise. Prices worry voters.",
           B = "Prices fall.")
toks <- tokens(texts, remove_punct = TRUE)
counts <- dfm(toks)
as.matrix(counts)
ntoken(toks)
# tokens(): split text into words and remove punctuation.
# dfm(): count words in each document; lowercase by default.
# as.matrix(): display rows = documents, columns = words.
# ntoken(): count all tokens in each document (A = 5, B = 2).
# Try: change "Prices fall." to "Prices rise." and rerun the block.
# END C02

# BEGIN C07
library(quanteda)
texts <- c("Energy bills are rising.",
           "This bill reforms parliament.",
           "Families cannot afford heating.")
dict <- dictionary(list(cost = c("energy bills")))
toks <- tokens(texts, remove_punct = TRUE)
matched <- tokens_lookup(toks, dictionary = dict)
hits <- dfm(matched)
as.matrix(hits)
# tokens_lookup(): match dictionary phrases before making a DFM.
# Output: 1, 0, 0 matches for the three sentences.
# Try: add "cannot afford heating" inside c(...) in the dictionary.
# END C07

# BEGIN C11
library(quanteda)
texts <- c("The policy is good.", "The policy is not good.",
           "Good plan, bad outcome.", "The committee met.")
dict <- dictionary(list(positive = "good", negative = "bad"))
toks <- tokens(texts, remove_punct = TRUE)
counts <- dfm(toks)
hits <- dfm_lookup(counts, dictionary = dict)
as.matrix(hits)
# Each column counts matches in one category.
# "good" and "not good" both have one positive match.
# Try: change "not good" to "bad" and rerun. What changes?
# END C11

# BEGIN C14
# Constructed confusion-matrix counts; no package needed.
TP <- 6  # correctly detected positives
FP <- 2  # false alarms
FN <- 4  # missed positives
precision <- TP / (TP + FP)
recall <- TP / (TP + FN)
precision
recall
# Output: precision = 0.75; recall = 0.60.
# Try: correct one missed positive: TP <- 7 and FN <- 3.
# These fractions require nonzero denominators.
# END C14
