# Install once if needed: install.packages("quanteda")
# Complete independent example; no C01 or data files required.
library(quanteda)
dic <- dictionary(list(
  household_costs = c("inflation", "rent", "energy bills"),
  employment = c("unemployment", "job security")
))

texts <- c("Rent and energy bills are rising.",
           "We need job security.")
example_tokens <- tokens(texts, remove_punct = FALSE)
matched <- tokens_lookup(example_tokens, dic, capkeys = FALSE)
counts <- dfm(matched)
as.matrix(counts)
