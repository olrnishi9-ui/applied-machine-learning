# Project 1 — SaaS Trial Conversion: Predicting Who Upgrades

A classification project on SaaS (software-as-a-service) trial users:
given how a user behaved during their free trial — how many days they
were active, how many features they used, how often they logged in, team
size, and a usage index — can we predict whether they **upgrade to a paid
plan**? Three classic classifiers are built on the same prepared data and
compared head-to-head.

## The code file

### `code/saas_trial_conversion_classification.R`

1. **Preparation.** Loads `saas_trial.csv`, counts and drops incomplete
   rows, then transforms the skewed continuous variables with `log1p`
   and standardizes them (z-scores) — scaling matters because one of the
   three models (KNN) measures distance. The signup channel
   (Organic / Paid / Referral) is one-hot encoded, with a bar chart of
   users by channel.
2. **Split.** A 70/30 train/test split (`set.seed(2025)`), used by all
   three models so the comparison is fair.
3. **Logistic regression.** Fit on the training set; evaluated at the
   default 0.5 cutoff and again at the *optimal* cutoff read off the ROC
   curve (closest-to-top-left). Reports confusion matrices and
   TPR / TNR / FPR / FNR for both cutoffs — the point being how much the
   cutoff choice, not just the model, changes the error balance.
4. **LDA.** Linear discriminant analysis (`MASS::lda`), same split,
   dummy channel variables removed. Same error rates, plus a look at how
   many test users the model classifies with high certainty
   (posterior probability > 0.8).
5. **KNN.** `FNN::knn` for k = 3 to 11, with train and test error for
   every k, a confusion matrix per k, and the best k chosen by test
   error.

## Data

- `saas_trial.csv` — a course dataset of SaaS trial users; one row per
  user, outcome `upgraded` (0/1). Not tracked in this repo; see
  `data/README.md`.

## Packages

Base R plus `MASS` (LDA), `FNN` (KNN), and `pROC` (the ROC curve and
optimal-cutoff code).

## Notes on the file in this repo

The script is the author's original (submitted as `Rcodes_AMLIBHW1.R`),
renamed to match this series' naming, with exactly one repair: the
original used `pROC`'s `roc()` and `coords()` without loading the
package (it was loaded in the author's RStudio session), so
`library(pROC)` was added at section 3c to make the file run standalone.
Nothing else was changed. The middle of the file rebuilds the train/test
split from the raw CSV a second time — that is how the original was
written, and it is harmless because the preparation steps are
deterministic.

## Status

Complete. Figures the script draws (users by signup channel, ROC curve)
are produced when it runs; they are not stored in `output/`.
