# Applied Machine Learning

A series of applied machine learning projects in R (RStudio), from
STAT 4230 — Applied Machine Learning in Business. Kept separate from the
[criminology data analysis series](https://github.com/olrnishi9-ui/criminology-data-analysis):
same organization, different subject.

## How this repo is organized

One rule for everything, so any project is easy to find later:

- Projects live in `projects/`, numbered in the order they were added: `01-…`, `02-…`, …
- Every project folder has the same inside layout:
  - `README.md` — what the project is, its data, and its status. Start here.
  - `code/` — R scripts (`.R`) and R Markdown / Quarto sources (`.Rmd` / `.qmd`)
  - `data/` — data notes only. Raw datasets are not tracked (see each project's `data/README.md` for the source)
  - `output/` — finished reports, figures, and tables
- New project? Copy `00-project-template/`, give it the next number, and fill in its README.

## Projects

| # | Project | What it is | Status |
|---|---|---|---|
| 01 | [SaaS Trial Conversion — Classification](projects/01-saas-trial-conversion-classification/) | Predicting which SaaS trial users upgrade to paid: logistic regression vs LDA vs KNN on trial-usage data | Complete |
| 02 | [Resampling and Regularization](projects/02-resampling-and-regularization/) | Cross-validation for model choice, subset selection, and ridge/lasso on Boston housing and low-birth-weight data | Complete |

More projects will be added with the next numbers.

## Tools

- R / RStudio
- (packages listed per project)
