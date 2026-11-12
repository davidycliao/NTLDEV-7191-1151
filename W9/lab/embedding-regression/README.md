# W9 課後 embedding regression

[完整繁中 Lab](../Embedding_Regression_W9.html)接續 Case 3，預設用 conText 隨附的400份文本、500×300詞向量與配套轉換；不需要 Python，也不安裝或下載任何套件／模型。

從課程根目錄執行：

```bash
Rscript --vanilla W9/lab/embedding-regression/embedding_regression_lab.R --baseline
Rscript --vanilla W9/lab/embedding-regression/embedding_regression_lab.R --flair100
```

也可 `source("W9/lab/embedding-regression/embedding_regression_lab.R")`，再執行 `run_w9_embedding_regression("baseline")` 或 `("flair100")`。`--all` 依序執行兩條路徑。

Flair100路徑預設讀取隨附的固定500詞×100維CSV，再從相同教學文本重新估計100×100的ALC轉換；不沿用300維轉換。重建向量時才執行以下程式，只載入本機既有cache：

```bash
python3.10 W9/lab/embedding-regression/export_flair_glove.py
```

`input/`包含文本與黨別／性別、固定詞表、Flair100矩陣及模型／匯出雜湊。`example-output/baseline/`和`flair100/`各包含：

| 檔案 | schema |
|---|---|
| `target-family-counts.csv` | matched_word, n_contexts |
| `party-gender-counts.csv` | party, gender, n_contexts |
| `contexts.csv` | context_id, source_doc, party, gender, from, to, pre, keyword, post, model_context, used_in_dem |
| `context-coverage.csv` | context_id, retained_tokens, matched_tokens, coverage |
| `coefficient-norms.csv` | term, l2_length, squared_length, dimension |
| `coefficients.csv` | term與各維座標 |
| `group-neighbors.csv` | group, party, held_gender, rank, feature, cosine |
| `group-keyword-cosines.csv` | group, feature, cosine |
| `nearest-contexts.csv` | group, rank, cosine, retrieval_scope，加上語境／來源欄位 |
| `transform-matrix.csv` | coordinate與轉換各欄 |
| `package-squared-norm-summary.csv` | conText3原始摘要，數值為平方量，不能直接稱為長度 |
| `metadata.json`、`captured-output.txt` | 版本、參照組、視窗、padding、推論狀態、實跑數值與檢查 |

精確目標`immigration`有924筆語境；`immigr*`的1,337筆只作樣本定義對照。所有新增刪詞都保留padding，但套件文本本來已清理，閱讀片段不能當成未清理逐字稿。近鄰來自模型預測的DF／DM／RF／RM，回讀只在同黨、同性別中取前三筆；不是群體用法占比。

預設關閉jackknife及permutation，沒有CI或顯著性主張。差向量長度自行計算`sqrt(sum(beta^2))`，不是百分比；conText3內建`normed.estimate.orig`是平方長度。兩模型的長度不能直接比較優劣。

[flaiR教學對應段落](https://davidycliao.github.io/flaiR/articles/tutorial.html#extending-contexts-embedding-regression) · [Case 3原論文](https://doi.org/10.1017/S0003055422001228)
