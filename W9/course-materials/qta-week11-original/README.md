# Week 11 本課原始教材

此資料夾保存既有課件原檔，作為 W9 教學材料的一部分。原始 Rmd、PDF、Lab Qmd 與使用的圖檔逐位元保留，沒有套用 W9 的內容修正。

- [原投影片 Rmd](qta_2024_week_11.Rmd) · [原投影片 PDF，34 頁](qta_2024_week_11.pdf)
- [原 Lab Qmd](2024_qta_lab_week_11.qmd)
- [W9 補充講義](../../handout/Word_Embeddings_Supplement.html)
- [W9 課後 Lab](../../lab/After_Class_W9.html)
- [W9 教材入口](../../README.md)

原投影片的 `WordEmbeddings('en')` 載入 300 維靜態 FastText；原 Lab 則用 `WordEmbeddings('glove')` 的 100 維靜態 GloVe。原 PDF 第 30 頁的 PCA 座標表與第 31 頁的固定圖片不是同一組結果。W9 修正版將方法分類分成訓練訊號與靜態／語境化表示兩軸，並用同一份 GloVe 向量重算 PCA 表與圖。

目前的操作步驟、R／Python 環境選擇與課後驗收，以 W9 Lab 為準。原課件的安裝說明及固定圖片保留作教學版本紀錄。
