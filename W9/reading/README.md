# W9 readings and DOI links

本週以四個案例介紹詞嵌入在政治學中的用途，再以 Flair 與 conText 完成三十分鐘 Lab。以下區分本週指定閱讀、補充案例與 W10 選讀；原 2024 課件屬於本課自有材料。

[Student slides](../slide/week9.html) · [Lab](../lab/Lab_Session_W9.html) · [Supplement](../handout/Word_Embeddings_Supplement.html)

<a id="assigned-readings"></a>
## W9 assigned readings

- **Bischof, Daniel, and Roman Senninger. 2018.** “Simple Politics for the People? Complexity in Campaign Messages and Political Knowledge.” *European Journal of Political Research* 57(2): 473–495. [DOI](https://doi.org/10.1111/1475-6765.12235). Readability measurement and its relationship to political knowledge.
- **Rodriguez, Pedro L., and Arthur Spirling. 2022.** “Word Embeddings: What Works, What Doesn’t, and How to Tell the Difference for Applied Research.” *The Journal of Politics* 84(1): 101–115. [DOI](https://doi.org/10.1086/715162). Choosing and evaluating embeddings for a research task.
- **Rodriguez, Pedro L., Arthur Spirling, and Brandon M. Stewart. 2023.** “Embedding Regression: Models for Context-Specific Description and Inference.” *American Political Science Review* 117(4): 1255–1274. [DOI](https://doi.org/10.1017/S0003055422001228). **Case 4:** occurrence-level context vectors, conditional group comparisons, neighbours and passages.

<a id="cases"></a>
## Four main cases

| Case | Study | Research question |
|---|---|---|
| **1** | Rheault, Ludovic, and Christopher Cochrane. 2020. “Word Embeddings for the Analysis of Ideological Placement in Parliamentary Corpora.” *Political Analysis*. [DOI](https://doi.org/10.1017/pan.2019.26) | Can party-term vectors learned from speeches support a political scale? |
| **2** | Rodman, Emma. 2020. “A Timely Intervention: Tracking the Changing Meanings of Political Concepts with Word Vectors.” *Political Analysis*. [DOI](https://doi.org/10.1017/pan.2019.23) | How do associations around a political concept change over time? |
| **3** | Müller, Stefan, and Sven-Oliver Proksch. 2024. “Nostalgia in European Party Politics: A Text-Based Measurement Approach.” *British Journal of Political Science*. [DOI](https://doi.org/10.1017/S0007123423000571) | How do neighbours, human screening and validation become a nostalgia measure? **W10 optional reading used in W9.** |
| **4** | Rodriguez, Spirling, and Stewart. 2023. *Embedding Regression*. [DOI](https://doi.org/10.1017/S0003055422001228) | How does the use of immigration differ by party and gender? **W9 assigned reading.** |

For each study, identify what receives a vector, what is compared and which evidence supports the political interpretation.

<a id="embedding-regression"></a>
## Embedding regression

A single static word-type vector pools uses across its corpus. Embedding regression instead represents each occurrence through its surrounding words, using a matched à la carte transformation, and treats those context vectors as regression outcomes. Neighbour lists and retrieved passages help interpret the estimated differences.

- [Authors' method explainer](https://github.com/prodriguezsosa/EmbeddingRegression/blob/main/Explainer/explainer.md)
- [conText Quick Start](https://github.com/prodriguezsosa/conText/blob/master/vignettes/quickstart.md)
- [Replication data](https://doi.org/10.7910/DVN/NKETXF)
- [Classroom Lab](../lab/Lab_Session_W9.html#context-quick-start)

<a id="applications"></a>
## Four additional applications

These brief examples extend Case 4; they do not add four more main cases.

| Study | Comparison |
|---|---|
| Gonthier, Frédéric. 2025. “How Populists Rally Around the People: Evidence from the Yellow Vests Movement Using an Embedding Regression Model.” *Swiss Political Science Review*. [DOI](https://doi.org/10.1111/spsr.12649) | Ideological groups' uses of the French word *peuple*. |
| Karell, Daniel, and Jeffrey Sachs. 2023. “How Symbols Influence Social Media Discourse: An Embedding Regression Analysis of Trump’s Return to Twitter.” *Socius*. [DOI](https://doi.org/10.1177/23780231231212108) | Language about groups before and after a political signal. |
| Van Matre, Joseph Charles, Isabel L. Krakoff, and Allegra H. Fullerton. 2026. “A Natural Language Processing Approach to Identifying Partisan Framing of Climate Change Denialism, Fatalism, and Solutions in US Congressional Speeches.” *Policy Studies Journal*. [DOI](https://doi.org/10.1111/psj.70079) | Climate-change framing by party and congressional term. |
| Kim, Jae Yeon, and Aniket Kesari. 2021. “Misinformation and Hate Speech: The Case of Anti-Asian Hate Speech During the COVID-19 Pandemic.” *Journal of Online Trust and Safety*. [DOI](https://doi.org/10.54501/jots.v1i1.13) | Hate and counterhate uses of *Chinese virus* across groups and time. |

<a id="book-and-course-materials"></a>
## Book and course materials

- **Grimmer, Justin, Margaret E. Roberts, and Brandon M. Stewart. 2022.** *Text as Data: A New Framework for Machine Learning and the Social Sciences*, Chapter 8. [Princeton University Press](https://press.princeton.edu/books/paperback/9780691207551/text-as-data) · [Authorized preview](https://books.google.com.tw/books?id=dL40EAAAQBAJ&pg=PA78). The chapter introduces learned representations, aggregation and evaluation.
- **Schoonvelde, Martijn. 2026.** Essex Summer School, *Introduction to Quantitative Text Analysis*, Day 3, “Comparing representations.” The course's document/word diagrams, cosine example and security illustration support the W9 concepts. [ESS course](https://essexsummerschool.com/course/ess-2026-course-list/1k/) · [Author](https://github.com/hjmschoonvelde).
- **Our original 2024 Week 11 Lab.** [HTML with word-vector and PCA figures](../lab/reference/2024_qta_lab_week_11.html). The W9 Lab uses the same eleven-word GloVe example, adds security comparisons and then moves to conText.
- [W9 supplement](../handout/Word_Embeddings_Supplement.html) and [after-class exercises](../lab/After_Class_W9.html).

## Multilingual resources

**Wirsching, Elisa M., Pedro L. Rodriguez, Arthur Spirling, and Brandon M. Stewart. 2025.** “Multilanguage Word Embeddings for Social Scientists: Estimation, Inference, and Validation Resources for 157 Languages.” *Political Analysis* 33(2): 156–163. [DOI](https://doi.org/10.1017/pan.2024.17).

The W9 figure compares ALC reconstruction with pretrained vectors within languages. This check does not establish cross-language alignment. A non-English application can use a language-specific model without comparing coordinates across languages.

<a id="w10-options"></a>
## W10 optional readings used in W9

- **Müller and Proksch (2024)**, *Nostalgia in European Party Politics*. Case 3 above.
- **Widmann, Tobias, and Maximilian Wich. 2023.** “Creating and Comparing Dictionary, Word Embedding, and Transformer-Based Models to Measure Discrete Emotions in German Political Text.” *Political Analysis*. [DOI](https://doi.org/10.1017/pan.2022.15).
- **Reimers, Nils, and Iryna Gurevych. 2019.** “Sentence-BERT: Sentence Embeddings using Siamese BERT-Networks.” *EMNLP-IJCNLP*. [DOI](https://doi.org/10.18653/v1/D19-1410).

## Further W9 options

- Benoit, Kenneth, Kevin Munger, and Arthur Spirling. 2019. “Measuring and Explaining Political Sophistication through Textual Complexity.” *American Journal of Political Science*. [DOI](https://doi.org/10.1111/ajps.12423).
- Mikolov et al. 2013. “Efficient Estimation of Word Representations in Vector Space.” [DOI](https://doi.org/10.48550/arXiv.1301.3781).
- Pennington, Socher, and Manning. 2014. “GloVe: Global Vectors for Word Representation.” [DOI](https://doi.org/10.3115/v1/D14-1162).
- Bojanowski et al. 2017. “Enriching Word Vectors with Subword Information.” [DOI](https://doi.org/10.1162/tacl_a_00051).
