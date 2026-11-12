"""W9 Flair: load a model, get vectors, compare security.

Run the three sections after flair_prepare.py, or execute this complete file.
The imported preparation checks the environment without loading a model.
"""
from flair_prepare import Sentence, WordEmbeddings, glove_path, np

# ==== Step 1: Load the model ====
embedding = WordEmbeddings(str(glove_path), force_cpu=True)
print(embedding.embedding_length)

# ==== Step 2: Get word vectors ====
word_list = ("King Queen man woman Paris London "
             "apple orange Taiwan Dublin Bamberg")
word_sentence = Sentence(word_list)
embedding.embed(word_sentence)
word_vectors = np.array([token.embedding.tolist() for token in word_sentence])
print(word_vectors.shape)

# ==== Step 3: Compare security ====
security_texts = ["Social security supports households.",
                 "The United Nations Security Council met.",
                 "Energy security matters for jobs."]
sentences = [Sentence(text) for text in security_texts]
embedding.embed(sentences)
security_vectors = np.array([
    next(token for token in sentence if token.text.lower() == "security")
    .embedding.tolist() for sentence in sentences])
print(security_vectors.shape)
unit = security_vectors / np.linalg.norm(
    security_vectors, axis=1, keepdims=True)
security_cosine = unit @ unit.T
print(np.round(security_cosine, 6))
