# W9 Lab: conText Quick Start, after the 2024 Flair exercise and plots.
# Source: https://github.com/prodriguezsosa/conText/blob/master/
#         vignettes/quickstart.md
# Run C00-C05 in order in one R session. Installation is before class.
# Target: exact immigration; the guide also illustrates immigr*.

# ==== C00: Prepare the three guide objects ====
library(conText)
library(quanteda)
quanteda_options(threads = 1)
data(list = c("cr_sample_corpus", "cr_glove_subset",
  "cr_transform"))
docvars(cr_sample_corpus, "party") <- factor(
  docvars(cr_sample_corpus, "party"), levels = c("D", "R"))
docvars(cr_sample_corpus, "gender") <- factor(
  docvars(cr_sample_corpus, "gender"), levels = c("F", "M"))
toks <- tokens(cr_sample_corpus, remove_punct = TRUE,
  remove_symbols = TRUE, remove_numbers = TRUE,
  remove_separators = TRUE, padding = TRUE)
toks <- tokens_tolower(toks)
toks_nostop <- tokens_select(toks, pattern = stopwords("en"),
  selection = "remove", min_nchar = 3, padding = TRUE)
feats <- featnames(dfm_trim(dfm(toks_nostop),
  min_termfreq = 5))
toks_nostop_feats <- tokens_select(toks_nostop, feats,
  padding = TRUE)
print(c(documents = ndoc(cr_sample_corpus)))
print(rbind(E = dim(cr_glove_subset), A = dim(cr_transform)))
# Empty pads retain the positions of removed tokens.

# ==== C01: Keep each immigration context and its metadata ====
immig_toks <- tokens_context(toks_nostop_feats,
  pattern = "immigration", window = 6L, valuetype = "fixed",
  rm_keyword = TRUE)
print(c(contexts = ndoc(immig_toks)))
print(table(docvars(immig_toks, "party")))
print(head(docvars(immig_toks), 3))
# One row is one use of immigration, not one speech.

# ==== C02: Build ALC vectors and average within party ====
immig_dfm <- dfm(immig_toks)
immig_dem <- dem(immig_dfm, pre_trained = cr_glove_subset,
  transform = TRUE, transform_matrix = cr_transform,
  verbose = FALSE)
immig_wv_party <- dem_group(immig_dem,
  groups = immig_dem@docvars$party)
print(rbind(DFM = dim(immig_dfm), DEM = dim(immig_dem),
  party_vectors = dim(immig_wv_party)))
# DEM: one context per row. Party vectors: one party per row.

# ==== C03: Read neighbours and compare reform with enforce ====
immig_nns <- nns(immig_wv_party,
  pre_trained = cr_glove_subset, N = 3,
  candidates = immig_wv_party@features, as_list = FALSE)
immig_cosines <- cos_sim(immig_wv_party,
  pre_trained = cr_glove_subset,
  features = c("reform", "enforce"), as_list = FALSE)
print(immig_nns)
print(immig_cosines)
# These party averages are exploratory, before regression adjustment.

# ==== C04: Read the nearest context to each party vector ====
immig_ncs <- ncs(immig_wv_party, contexts_dem = immig_dem,
  contexts = immig_toks, N = 1, as_list = FALSE)
print(immig_ncs[, c("target", "rank", "value")])
cat(paste(immig_ncs$target, immig_ncs$context, sep = ": "),
  sep = "\n")
# D/R label the queried party vector, not the source speaker.
# These are processed context words, not complete original speeches.

# ==== C05: Compare party while adjusting for gender ====
set.seed(2021L)
fit <- conText(immigration ~ party + gender,
  data = toks_nostop_feats, pre_trained = cr_glove_subset,
  transform = TRUE, transform_matrix = cr_transform,
  jackknife = FALSE, permute = TRUE,
  num_permutations = 100, window = 6L,
  valuetype = "fixed", verbose = FALSE)
print(dim(fit))
print(rownames(fit))
print(fit@normed_coefficients)
# Input is the original processed tokens with metadata, not the DEM.
# Current conText reports squared norms and a bias correction.
# A displayed p.value of 0 means 0 exceedances in 100 permutations.
# These numbers are not the 2023 article's L2 coefficient lengths.
