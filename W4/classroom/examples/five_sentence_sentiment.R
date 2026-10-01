# W4 closing example: real dictionary matches, fictional timing scenario.
# Run from W4/classroom. No API or model download is used.
library(quanteda)

# Set the working directory to W4/classroom before running.
dictionary_path <- "Dictionaries/teaching_affect.dic"

sentences <- c(
  "This policy is good.",
  "This policy is bad.",
  "This policy is not good.",
  "Excellent, another tax increase.",
  "The committee met on Tuesday."
)
own_dictionary <- dictionary(file = dictionary_path, format = "LIWC")
sentence_tokens <- tokens(sentences, remove_punct = TRUE)
matched_tokens <- tokens_lookup(sentence_tokens, own_dictionary, capkeys = FALSE)
matched_dfm <- dfm(matched_tokens)
matched <- as.matrix(matched_dfm)
net <- matched[, "positive"] - matched[, "negative"]
total_matches <- rowSums(matched)
status <- rep("balanced", length(sentences))
status[net > 0] <- "positive"
status[net < 0] <- "negative"
status[total_matches == 0] <- "unmatched"
dictionary_result <- data.frame(
  id = seq_along(sentences), sentence = sentences,
  positive = matched[, "positive"], negative = matched[, "negative"],
  dictionary_status = status, row.names = NULL
)
print(dictionary_result, row.names = FALSE)


assumed_latency <- data.frame(
  method = c("Dictionary", "Transformer classifier", "Prompted LLM"),
  sentences_per_batch = 5L,
  assumed_seconds = c(0.02, 0.30, 3.00)
)
cat("\nFICTIONAL batch times, not measurements. No Transformer or LLM was run.\n")
print(assumed_latency, row.names = FALSE)
cat("\nCheck negation and possible irony; unmatched does not establish neutral sentiment.\n")
