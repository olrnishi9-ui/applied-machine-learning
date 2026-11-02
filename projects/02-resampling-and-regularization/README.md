# Project 2 — Resampling and Regularization

How do you choose between models — and how much does the choice method
itself wobble? This project works through the resampling and shrinkage
toolkit (the ISLR cross-validation and model-selection chapters) in four
exercises: choosing a polynomial degree by cross-validation, subset
selection three ways, ridge vs lasso on Boston housing prices, and
penalized logistic regression for low birth weight.

## The code file

### `code/resampling_and_regularization.R`

1. **Cross-validation for polynomial degree.** Simulates data from a
   known curve (y = −2x³ + 0.4x⁴ + noise, n = 500) and runs 10-fold CV
   for polynomial fits of degree 1–4. Then it repeats the whole thing
   under **10 different random fold assignments** and plots all 10 CV
   curves together — a direct look at how much the "best degree" answer
   can move just because the folds were shuffled differently.
2. **Subset selection.** Builds polynomial features up to x¹⁰ and runs
   `bestglm` three ways — exhaustive best subsets, forward, and backward
   selection, all by AIC — then compares the chosen models and their AIC
   side by side.
3. **Ridge vs lasso — Boston housing.** On the `ISLR2::Boston` data
   (predicting median home value `medv`), 5-fold CV compares plain OLS
   against ridge and lasso (`glmnet`, λ chosen by CV). For the lasso it
   also contrasts `lambda.min` with `lambda.1se` and quantifies the
   trade-off explicitly: how much CV error you pay to remove how many
   predictors.
4. **Penalized logistic regression — low birth weight.** On
   `MASS::birthwt` (predicting `low`), fits ridge and lasso logistic
   models with 5-fold CV (deviance as the loss) and reports the
   misclassification rate at a 0.3 probability threshold, comparing
   ridge at `lambda.min` against lasso at `lambda.1se`.

## Data

- Simulated data, generated inside the script (exercises 1–2).
- `Boston` from the `ISLR2` package (exercise 3).
- `birthwt` from the `MASS` package (exercise 4).
- Nothing to download; see `data/README.md`.

## Packages

`bestglm`, `ISLR2`, `glmnet`, `MASS`. Install them once before running
(see the commented lines in the script).

## Notes on the file in this repo

The script is the author's original (submitted as
`HWK2_Applied_Machine_learning.R`), renamed to match this series'
naming, with exactly one kind of edit: the two `install.packages()`
calls were commented out, so re-running the file doesn't reinstall
packages every time (the lines are still there as comments, marked
"Run once if needed"). Nothing else was changed.

## Status

Complete. Plots the script draws (CV curves across partitions, glmnet
coefficient paths) are produced when it runs; they are not stored in
`output/`.
