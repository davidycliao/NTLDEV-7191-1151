# Original teaching dictionaries

These lists were written for NTLDEV 7191. They are not extracted from an official LIWC dictionary and have not been validated as research instruments. You may modify and share these original lists with attribution to the course.

- `teaching_affect.dic`: ten illustrative affect words in the legacy LIWC plain-text format. The first `%` section maps category numbers to names; the second maps words to categories. Read it with `quanteda::dictionary(file = ..., format = "LIWC")`. Add your own word on a new line with its category number, then rerun the workflow. The supplied example contains only exact single-word patterns.
- `energy_policy.csv`: a broad v1 and an illustrative revised v2, both measuring the same proposed construct. `*` is a glob wildcard. Space-separated patterns are phrases for quanteda token lookup. The CSV is not itself a LIWC import file; it is our editable format for phrase-based policy rules.

LIWC is a program, a family of dictionaries, and a dictionary-file format: these are not interchangeable. Our scores use quanteda tokenization and matching. They are not official LIWC-22 scores or its proprietary summary measures. This lab does not claim support for the newer `.dicx` format in quanteda.

An instructor with appropriate LIWC access can optionally demonstrate importing a custom dictionary in LIWC's Dictionary Workbench, selecting the dictionary/categories, retaining document IDs, and exporting results. Check the applicable license before using or sharing proprietary dictionaries; do not add them to public GitHub repositories or course ZIPs. No LIWC purchase is needed for the core lab.

Technical references: [LIWC Dictionary Workbench](https://liwc.app/help/workbench), [LIWC Analysis](https://liwc.app/help/liwc), [quanteda dictionary import](https://quanteda.io/reference/dictionary.html), [quanteda token lookup](https://quanteda.io/reference/tokens_lookup.html).
