# Week 4: Dictionaries and Sentiment Analysis

[Slides: HTML](slide/week4.html) · [Slides: PDF](slide/week4.pdf) · [Student source ZIP](downloads/week4-student-source.zip)

The slides cover dictionary construction, phrase matching, sentiment scores, denominators and validation in political texts.

## Classroom code

Download and extract the [classroom ZIP](downloads/week4-classroom.zip), then open `W4_classroom.R` and run C01. Follow the slides one block at a time. See the [classroom instructions](classroom/README.md).

The source ZIP includes the student QMD, slides, required styles and images, bibliography, and classroom code. Presenter notes and take-home lab materials are not included. Keep the folder structure intact when extracting it.

## Take-home lab

[Lab HTML](https://raw.githack.com/davidycliao/NTLDEV-7191-1151/main/W4/lab/Lab_Session_W4.html) · [R script](lab/Lab_Session_W4.R) · [Lab ZIP](https://github.com/davidycliao/NTLDEV-7191-1151/raw/refs/heads/main/W4/downloads/week4-lab.zip) · [Instructions](lab/README.md)

Download and extract the lab ZIP, then read the handout and run `Lab_Session_W4.R` one section at a time. It includes the required data, teaching dictionaries and worked answers. The four core tasks cover dictionary matching, rule revision, error analysis and validation. You do not need to run W2 first.

## Compile the slides

With Quarto, R and the `knitr` and `rmarkdown` packages installed, run this command from the repository root or the extracted source ZIP's top folder:

```sh
quarto render W4/slide/week4.qmd
```

The HTML build needs `W4/slide/week4.qmd`, `W4/assets/`, `styles/text-preparation.css` and `image/ntu-logo.png`, with their relative paths preserved. It does not need `W4/lab/`, `W4/classroom/`, W2 files or presenter notes. R generates the compile timestamp; the displayed example code is not executed during rendering.

To run the examples in R, use `W4/classroom/` with its `workflow.R`, `Data/` and `Dictionaries/` folders. Those files are already in the classroom ZIP; no lab download is needed. Keep the classroom files, bibliography and downloads alongside the slides if you want their local links to work. This command builds the HTML; the supplied PDF is generated separately.

## References

The required readings and software resources are listed on the closing reference slides. Additional bibliographic entries are in [supplementary.bib](references/supplementary.bib). Source acknowledgments accompany the relevant slides.
