# W9 離線課後向量分析

[課後講義](../After_Class_W9.html)的 A02 與 A04 使用這個資料夾。主腳本只需要 base R，不載入 Python，不安裝套件，不取得模型。

在課程 root 執行：

```bash
Rscript W9/lab/after-class/after_class_lab.R
Rscript W9/lab/after-class/after_class_lab.R --help
```

預設讀取 `../flair/example-output/word-vectors.csv`，輸出到本資料夾的 `example-output/`。這兩個預設路徑以腳本位置解析。自訂 CSV 應另選輸出資料夾：

```bash
Rscript W9/lab/after-class/after_class_lab.R \
  --input /absolute/path/to/my-vectors.csv \
  --output-dir /absolute/path/to/my-output \
  --model-label "My prepared model"
```

## 輸入與列 ID

CSV 一列是一個詞或一次 token 出現。最小欄位為 `word` 或 `token` 與 `dim1...dimN`。可另提供正整數且唯一的 `position`、非空且唯一的 `id`。沒有這兩欄時依讀入順序建立 position 與 `row_0001...`。詞可以重複；詞本身不作唯一列 ID。

`read_token_vectors(path, token_column, id_column, dimension_columns)` 可明確指定欄位。自動維度判斷先選 `dim1...dimN`，再選其他數值欄，排除 position/id；含其他數值 metadata 的 CSV 應指定 dimension_columns。缺值、Inf 與重複 ID 會停止並說明原因。

## 輸出與數值關係

- `word-pca.csv`：position、token、id、可用的 PC1–PC3。座標保留 CSV 的數值精度。
- `word-pca-table.md`：同一份 scores 的四位小數表，供 Quarto include。
- `word-pca.png`：同一份 scores 的 PC1／PC2，等比例座標軸；有 PC3 時以點色表示。只有一個 PC 時呈現 1D 圖。
- `word-cosine.csv`：原始完整座標的 cosine 矩陣，列／欄依 id 命名。零向量對應值為 NA。
- `pca-check.json`：輸入 MD5、原始列／維度與 ID、PCA 設定和排除項、各 PC 變異比例、實際繪圖座標、CSV roundtrip 誤差，以及輸出檔 MD5。

canonical 設定為 `prcomp(..., center = TRUE, scale. = TRUE)`。零向量列與固定維度不進入 PCA，檢查紀錄保留排除清單。少於兩個可用 token 或沒有變動維度時，仍保存列資訊、cosine、原因圖與 JSON。原始 full cosine 不經逐維標準化或 PCA。

預設 11 × 100 資料來自 W9 已保存的 Flair `glove` 輸出。這次執行 PC1／PC2 變異比例合計為 **0.382444103057687**，rank 為 10，沒有零向量或固定維度。原 Rmd 的 `WordEmbeddings('en')` 是另一個 300 維 FastText，原檔及原圖片保存於 `../../course-materials/qta-week11-original/`，不作本次結果替代品。

## 可重用函數

`source("W9/lab/after-class/after_class_lab.R")` 只定義函數，不執行主程式。

| 函數 | 回傳與限制 |
|---|---|
| `read_token_vectors()` | rows、完整 vectors、維度欄名、輸入路徑及 MD5 |
| `full_cosine()` | 完整空間 cosine 矩陣，零向量為 NA |
| `fit_token_pca()` | 一份 scores、variance_share、rank、排除清單；最多保存前三個有效 PC |
| `word_set_association()` | coverage、目標詞相對兩組參照的 mean-cosine 差；預設 King／Queen 與 man／woman。任何缺詞、零向量或歧義都不計算關聯差；重複詞可用 `match_by = "id"` 指定。此處沒有 WEAT 檢定。 |
| `compare_prepared_models()` | 兩份本機 CSV 的 coverage、共同詞，以及各模型內的 cosine／PCA；不對齊模型座標 |
| `plot_pca_3d()` | 讀同一份 scores；只在已有 plotly 與至少三個 PC 時繪圖，不安裝套件 |
| `run_after_class_lab()` | 讀檔、計算、寫入上述五個輸出，驗證表圖同源與 CSV roundtrip，回傳所有分析物件 |

## 本次驗證

已於 2026-11-11 執行 canonical 重算，檢查 PNG 標籤與 axes，並在暫存資料驗證：重複 token 的唯一 ID、以 ID 選集合、缺詞 coverage guard、兩列／單列／全零／固定座標、零向量 cosine 為 NA、排除固定維度、拒絕重複 ID 與 Inf、同模型比較、無共同詞及不足三個 PC 的 3D guard。輸出 JSON 可由標準 JSON parser 讀取；canonical CSV roundtrip 最大誤差約 `5.33e-15`。

重新產生資料後，獨立開啟 CSV／PNG 即可檢查。已建置的課後 HTML 內嵌當時的表圖，須另行 render 才會更新；本腳本不負責建置講義。
