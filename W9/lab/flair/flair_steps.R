# W9 Flair: run these three sections after sourcing flair_prepare.R.
# Keep the same R session. PCA remains in the separate after-class exercise.

# ==== Step 1: Load the model ====
embedding <- WordEmbeddings(glove_path)
print(embedding$embedding_length)

# ==== Step 2: Get word vectors ====
word_list <- paste("King Queen man woman Paris London",
  "apple orange Taiwan Dublin Bamberg")
word_sentence <- Sentence(word_list)
embedding$embed(word_sentence)
word_vectors <- do.call(rbind, lapply(word_sentence$tokens,
  function(token) as.numeric(token$embedding$tolist())))
print(dim(word_vectors))

# ==== Step 3: Compare security ====
security_texts <- c("Social security supports households.",
  "The United Nations Security Council met.",
  "Energy security matters for jobs.")
sentences <- lapply(security_texts, Sentence)
embedding$embed(sentences)
security_vectors <- do.call(rbind, lapply(sentences, function(sentence) {
  token <- Filter(function(t) tolower(t$text) == "security",
    sentence$tokens)[[1]]
  as.numeric(token$embedding$tolist())
}))
print(dim(security_vectors))
unit <- security_vectors / sqrt(rowSums(security_vectors ^ 2))
security_cosine <- tcrossprod(unit)
print(round(security_cosine, 6))
