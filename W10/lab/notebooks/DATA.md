# Irish environmental-policy data

The `irish_environmental_policies/` directory is the saved DatasetDict supplied with the original 2024 course materials. The two notebooks read the same saved split and columns.

| Split | Rows | Other policy (`0`) | Environmental policy (`1`) |
|---|---:|---:|---:|
| train | 1,880 | 1,772 | 108 |
| validation | 627 | 582 | 45 |
| test | 627 | 583 | 44 |

These counts were checked by reading the supplied dataset without fitting a model. The columns are `text` and `label`. The stored class names, in order, are **`None Environment Policy`** and **`Environment Policy`**; their original wording is retained.

Read one training text and discuss why its supplied label fits. Record uncertainty about the topic boundary. Keep validation and test labels for their existing evaluation roles.

The environmental class is a minority in every split. A high accuracy can therefore coexist with poor environmental-policy recall. Report per-class precision, recall and F1 as well as the overall score.

The original row split includes a few repeated headings and placeholder texts. A whitespace-normalized, case-insensitive check found 2 distinct text strings shared by train/validation, 4 by train/test and 2 by validation/test. The supplied split is retained for reading the notebooks; it does not establish independence by document, source or time.

Only the files referenced by the saved dataset state are included: `dataset_dict.json`, and each split's `state.json`, `dataset_info.json` and original data Arrow file. Unreferenced cache files are omitted; no data or split was regenerated. The original metadata do not provide a corpus citation or license. See the [course-material attribution and output records](../results/README.md).
