# Real political speech: Obama 2013 inaugural address. No C01 required.
# Source: https://quanteda.io/reference/data_corpus_inaugural.html
# install.packages(c("quanteda", "udpipe", "textrank", "igraph"))
# The model is saved in udpipe_models under your current working directory.
# O01: POS candidates (model download on first run)
# install.packages("udpipe")  # run once before class
library(udpipe)
dir.create("udpipe_models", showWarnings = FALSE)
info <- udpipe_download_model("english-ewt",
  model_dir = "udpipe_models", overwrite = FALSE)
model <- udpipe_load_model(info$file_model)
library(quanteda)
library(textrank)
speech <- corpus_subset(data_corpus_inaugural, Year == 2013)
text <- as.character(speech)
ann <- as.data.frame(udpipe_annotate(model, x = text,
                                  parser = "none"))
# Mark candidates, retaining punctuation and other tokens as separators.
keep <- ann$upos %in% c("NOUN", "ADJ")
# This implementation connects immediately adjacent eligible tokens.
# ngram_max controls output phrase length, not the co-occurrence window.
result <- textrank_keywords(ann$lemma, relevant = keep,
                           ngram_max = 2, sep = " ")
scores <- sort(result$pagerank$vector, decreasing = TRUE)
print(round(head(scores, 6), 4))

# Inspect observed adjacent pairs. cooc is the pair occurrence count.
pairs <- cooccurrence(ann$lemma, relevant = keep)
print(head(pairs, 3))
print(pairs[pairs$term1 == "new" | pairs$term2 == "new", ])

# TextRank (3/3): print the top five and draw their neighbours.
# Scores come from the full TextRank network; we show a smaller part here.
print(round(head(scores, 5), 4))
library(igraph)
top5 <- names(head(scores, 5))
links <- subset(pairs,
  term1 %in% top5 | term2 %in% top5)
g <- graph_from_data_frame(links, directed = FALSE)
set.seed(4)
plot(g, layout = layout_with_fr(g),
     vertex.size = 6, vertex.color = "#7cae96",
     vertex.label.color = "#314f4f",
     vertex.label.cex = 1.5,
     edge.width = E(g)$cooc)
# Each line is an observed adjacent noun/adjective pair.
# A thicker line means that pair occurs more often.
# Try head(scores, 10), rerun from top5 onwards, and compare the network.
# We do not recompute PageRank on this smaller graph.

# Inspect model predictions before accepting a candidate.
print(ann[ann$lemma == "endure", c("token", "lemma", "upos")])
# Phrase output: freq counts occurrences; it is NOT the PageRank score.
print(head(result$keywords))
# High centrality does not establish relevance or negative evaluation.
