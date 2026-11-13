# W9 · Word Embeddings and Political Language

本週從 security 的語境例子介紹詞嵌入，再讀四個政治學案例：政黨位置、概念變遷、懷舊量測及 embedding regression。全套 **112 張**，主講第 **1–94 張**、補充第 **95–112 張**；課程 **110 分鐘**，其中 Lab **30 分鐘**。

## Student materials

- [Slides HTML](https://raw.githack.com/davidycliao/NTLDEV-7191-1151/main/W9/slide/week9.html) · [Slides PDF](slide/week9.pdf) · [Student source ZIP](downloads/week9-student-source.zip)
- [Lab HTML](https://raw.githack.com/davidycliao/NTLDEV-7191-1151/main/W9/lab/Lab_Session_W9.html) · [Lab ZIP](downloads/week9-lab.zip) · [Lab instructions](lab/README.md)
- [conText classroom R script](classroom/W9-conText.R) · [Flair R steps](lab/flair/flair_steps.R) · [Flair Python steps](lab/flair/flair_steps.py)
- [Readings and DOI links](reading/README.md)
- [Supplement](handout/Word_Embeddings_Supplement.html) · [After-class A01–A04](lab/After_Class_W9.html) · [Advanced embedding regression A05](lab/Embedding_Regression_W9.html)

HTML 保留課堂分頁操作；PDF 可下載閱讀。Lab 投影片採同頁 **Code／Output** 分頁。先看 Code，再點 Output 讀結果；Output 有數個重點時，按右箭頭逐項看框選。完整可執行程式在 Lab 講義的折疊區塊。

## Class route

| Section | Slides | Question |
|---|---|---|
| Concepts and research map | 1–16 | What does a vector represent, and how is it learned? |
| Case 1 · Rheault & Cochrane | 17–26 | How can parliamentary language help locate parties? |
| Case 2 · Rodman | 27–36 | How can word associations reveal conceptual change? |
| Case 3 · Müller & Proksch | 37–46 | How do neighbours help build and validate a nostalgia measure? |
| Case 4 · Embedding regression | 47–71 | How can we compare uses of the same word across groups? |
| Multilingual resources and applications | 72–76 | Where else is this method used? |
| Lab guide and break | 77–80 | What will we compare in the Lab? |
| Flair and PCA | 81–85 | Load GloVe, obtain vectors, compare security and read the projection. |
| conText | 86–91 | Build context vectors, read neighbours and passages, then adjust the party comparison for gender. |
| Research design and references | 92–94 | What evidence would support our own comparison? |
| Supplement | 95–112 | Additional concepts, emotion measurement, evaluation and readability. |

## Lab plan

The guide on slides **77–79** precedes the five-minute break. The practical Lab runs **17:40–18:10**:

- **17:40–17:55:** [our original 2024 Lab](lab/reference/2024_qta_lab_week_11.html), adapted for Flair, static GloVe, security and same-run PCA figures. E06 checks the matrix units and identical security vectors.
- **17:55–18:10:** the [conText Quick Start](https://github.com/prodriguezsosa/conText/blob/master/vignettes/quickstart.md). E04 connects one occurrence, neighbour/context evidence and a party coefficient holding gender fixed.

Prepare the packages and cached model before class. If the R connection to Flair is unavailable, use the Python route in the Lab or follow the saved outputs. Flair uses 100-dimensional GloVe; the conText example has its own 300-dimensional vectors and matched ALC transformation.

Full PCA recalculation and sensitivity exercises are available after class. The [earlier handout](lab/Lab_Session_W9_earlier.html) retains optional readability, count/TF–IDF and local GloVe exercises. The 2024 materials are the instructor's own course materials.
