# W8 · Topic Models and Their Variants

Use the same 719 political speeches to build a count table, fit LDA, check topic labels against original texts, then fit STM and compare parties.

## Slides

- [View slides](https://raw.githack.com/davidycliao/NTLDEV-7191-1151/main/W8/slide/week8.html#/title-slide)
- [Download PDF](slide/week8.pdf)
- [Editable student slides and complete Lab ZIP](https://github.com/davidycliao/NTLDEV-7191-1151/raw/refs/heads/main/W8/downloads/week8-student-source.zip)

## R Lab

- [View student Lab](https://raw.githack.com/davidycliao/NTLDEV-7191-1151/main/W8/lab/Lab_Session_W8.html)
- [Download Lab ZIP](https://github.com/davidycliao/NTLDEV-7191-1151/raw/refs/heads/main/W8/downloads/week8-lab.zip)
- [R script](classroom/W8.R) · [Instructions](lab/README.md)

Download and extract the complete Lab ZIP. Open `W8/W8_lab.Rproj` in RStudio, then `classroom/W8.R`. Install the eight packages listed in the handout before class. Restart R and run one step at a time, keeping the same session and folder structure.

The Lab contains **19 steps and five exercises**, covering LDA and STM. In class, follow R01 → R02 → R03a–R03b and E02 → R05a–R05e and E05. Complete R00 before class; R03c–R04c and the remaining exercises are after-class practice. The supplied alternative models support the optional K check.

The editable source bundle includes the student QMD, its required images and styles, and the Lab. From the extracted folder, run `quarto render W8/slide/week8.qmd` to rebuild the slides. To rebuild the Lab, render `W8/lab/source/Lab_Session_W8.qmd`, then move the resulting HTML to `W8/lab/Lab_Session_W8.html` so its relative links work.

The Lab adapts Martijn Schoonvelde's [ESS 2026 quantitative text analysis course](https://essexsummerschool.com/course/ess-2026-course-list/1k/). Keep the document IDs and original speeches when interpreting topic labels. Party comparisons are observational; training perplexity alone cannot validate a political measure.
