# W4 Classroom Code

These files accompany the Week 4 slides. Extract the ZIP before starting; no separate lab download is needed.

1. Open [W4_classroom.R](W4_classroom.R) in RStudio. Install `quanteda` and `quanteda.textstats` using the command at the top if needed, then run the entire **C01** block. If a file picker opens, select `workflow.R` in this folder.
2. Keep the same R session open and run one numbered block at a time when prompted by the slides. The script follows slide order; C15 follows C12. Run each block when we reach its slide. Open files in `examples/` when directed.
3. Keep `Data/`, `Dictionaries/` and `workflow.R` in their supplied locations. C01 loads the required data automatically.

For the three **TextRank: ranking candidate words** slides, open [W4_keywords_real.R](examples/W4_keywords_real.R). It contains the complete example: annotate Obama's 2013 speech with UDPipe, rank candidate words, print the word pairs and top five scores, then plot their network with `igraph`. Use the installation command at the top on first use; the UDPipe model also downloads on first use. This example runs independently of C01.

Optional Python demonstration: [W4_flair_ner.py](examples/W4_flair_ner.py) detects named entities with Flair. Run it in Python, not the R console; installation and a first-run model download are required. It is separate from the required R activities.
