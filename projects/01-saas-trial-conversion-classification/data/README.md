# Data notes — SaaS Trial Conversion

Dataset: `saas_trial.csv` — course data for STAT 4230 (Applied Machine
Learning in Business). One row per SaaS trial user.

Columns used by the analysis:

- Continuous: `trial_days_active`, `features_used`, `sessions_per_week`,
  `team_size`, `usage_index`
- Categorical: `signup_channel` (Organic / Paid / Referral)
- Outcome: `upgraded` (0 = stayed free, 1 = upgraded to paid)

The raw CSV is not tracked in this repo (see the repo `.gitignore`).
Keep this file updated with the dataset's source and any version notes,
so the analysis stays reproducible.
