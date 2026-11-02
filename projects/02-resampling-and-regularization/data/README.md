# Data notes — Resampling and Regularization

No external data files. Everything comes from inside R:

- Exercises 1–2: simulated data generated in the script itself
  (y = −2x³ + 0.4x⁴ + Gaussian noise, n = 500, fixed seeds).
- Exercise 3: `Boston` dataset, bundled with the `ISLR2` package
  (506 suburbs, predicting median home value `medv`).
- Exercise 4: `birthwt` dataset, bundled with the `MASS` package
  (189 births, outcome `low` = birth weight under 2.5 kg).

Raw data files in this folder are ignored by git (see the repo
`.gitignore`).
