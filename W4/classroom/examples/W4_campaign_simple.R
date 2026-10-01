# Independent classroom illustration, not a replication of Eichorst & Lin (2019).
# Install once if needed: install.packages("quanteda")
library(quanteda)
text <- c("We may improve public services.",
          "We guarantee better public services.")
dict <- dictionary(list(vague = "may", concrete = "guarantee"))
toks <- tokens(text, remove_punct = TRUE)
counts <- dfm(toks)
hits <- dfm_lookup(counts, dictionary = dict)
as.matrix(hits)

# Teaching score = 100 * (C - V) / L, in percentage points.
# C: concrete matches; V: vague matches; L: all word tokens.
# Adapted from the percentage-point difference in Eichorst & Lin (2019).
# The paper excludes stopwords from L and rescales to 0-1; this example does neither.
# Source: https://doi.org/10.1086/700002 (Manifesto concreteness; footnote 16).
m <- as.matrix(hits)
100 * (m[, "concrete"] - m[, "vague"]) / ntoken(toks)
