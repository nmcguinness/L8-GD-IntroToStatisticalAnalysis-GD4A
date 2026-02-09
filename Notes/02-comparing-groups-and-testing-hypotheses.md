# Comparing Two Groups & Testing Hypotheses 

These notes help you **compare two versions of a game (Build A vs Build B)** or **two player groups** and write a clear lab report.

**Your goal at this stage is not to become a statistician.** Your goal is to:
- ask a focused question,
- compare groups using sensible summaries,
- quantify uncertainty with a confidence interval,
- write a short, honest interpretation,
- make an actionable recommendation for the next iteration.

## What “comparing groups” means in gameplay testing

A comparison is usually one of these:

| Outcome type | Typical gameplay metric | What you compare |
| :- | :- | :- |
| Numeric | completion time, deaths, score, damage taken | average (mean/median) + spread |
| Binary | completed yes/no, used tutorial yes/no | completion rate (percentage) |
| Ordinal (Likert) | “fun” 1–5, “frustration” 1–7 | treat carefully (see policy box) |

### Using Likert Scale
For lab reports, if the scale is **5+ points** and the distribution is not extreme, you may:
- treat Likert as numeric **for summaries and plots**, and
- compare group averages cautiously.

Always include a sentence like:
> “This is a rating scale (ordinal), so we interpret differences as indicative rather than exact.”

## Hypotheses in plain English

A hypothesis keeps your analysis focused.

- **H0 (null):** “There is no difference between A and B in the metric.”  
- **H1 (alternative):** “There is a difference (or a specific directional difference).”

Examples:
- H0: “Average completion time is the same in Build A and Build B.”  
- H1: “Players complete the level faster in Build B than in Build A.”

Choose one metric as your headline result (e.g., completion time). You can still report secondary outcomes, but keep your story centred on one.

## Simplified comparison workflow 
### Step 1 — Sanity check the data
- Do both groups have enough rows (sessions)?
- Are there obvious data-entry issues (impossible times, negative scores)?
- Are you comparing like with like (same level, same task, same hardware)?

### Step 2 — Summarise each group
Report:
- **n** (sample size)
- **mean** (or **median** if heavily skewed)
- **spread** (SD or IQR)

### Step 3 — Visualise before you conclude
Required plot for numeric outcomes:
- **Box plot** (or histogram) by group.

This prevents “trusting one number” and helps you notice outliers or skew.

### Step 4 — Quantify the difference
For numeric outcomes, compute the **difference**:
- difference = mean(B) − mean(A) (or median difference)

For binary outcomes:
- difference = completion_rate(B) − completion_rate(A)

### Step 5 — Add uncertainty (confidence interval)
At this stage, we use an intuitive method: **bootstrap confidence intervals**.

## Confidence intervals (CI) for beginners

A **95% confidence interval** gives a plausible range for the “true” value in the population of similar players.

Two CIs are most useful:

### A) CI for the mean (one group)
Example reporting:
> “Mean completion time in Build B was 92s (95% CI [85, 99]).”

### B) CI for a mean difference (two groups)
This is usually what you want for A vs B.
Example reporting:
> “Build B was faster by 12s on average (95% CI [3, 21]).”

### How to calculate a 95% CI using the Bootstrap method

At this stage we use an intuitive method: **bootstrap confidence intervals**.

**Idea:** pretend your sample is the population, then repeatedly “re-run the study” by resampling sessions **with replacement**.

#### Bootstrap CI for a mean (one group)
1. Take the column you care about (e.g., `completion_time_s` for Build B).
2. Create a resample of the same size **with replacement** (some sessions repeat; some are missing).
3. Compute the statistic (e.g., the mean time).
4. Repeat (e.g., 1,000–10,000 times).
5. Sort the resampled statistics.
6. The **95% CI** is the **2.5th percentile** and **97.5th percentile** of those values.

#### Bootstrap CI for a mean difference (two groups)
1. Split your data into Build A and Build B.
2. Resample **within each group** (with replacement) to the original group sizes.
3. Compute `mean(B_resample) − mean(A_resample)`.
4. Repeat many times.
5. Take the 2.5th and 97.5th percentiles of the resampled differences.

#### How many repeats?
- **1,000** is often fine for a lab report.
- **10,000** is better if your spreadsheet can handle it.

#### When bootstrap is a good fit
- small-ish samples (common in playtests),
- skewed metrics (times, counts),
- you want a clear “range” rather than a single number.

### Example 1 — CI for a mean difference (completion time)

**Question:** Did Build B reduce completion time?

We test 6 players per build on the same level.

| Player | Build | Completion time (s) |
| :- | :- | :- |
| P1 | A | 120 |
| P2 | A | 110 |
| P3 | A | 105 |
| P4 | A | 130 |
| P5 | A | 115 |
| P6 | A | 125 |
| P7 | B | 98 |
| P8 | B | 100 |
| P9 | B | 95 |
| P10 | B | 102 |
| P11 | B | 97 |
| P12 | B | 93 |

**Step 1: Compute group means**
- mean(A) = (120+110+105+130+115+125) / 6 = 705 / 6 = **117.5s**
- mean(B) = (98+100+95+102+97+93) / 6 = 585 / 6 = **97.5s**

**Step 2: Compute the observed difference**
- difference = mean(B) − mean(A) = 97.5 − 117.5 = **−20.0s**  
Interpretation: Build B is faster (negative means less time).

**Step 3: Bootstrap the CI (what you do conceptually)**
Repeat these steps many times (e.g., 1,000):
- Resample 6 times from A **with replacement**, compute mean(A*)
- Resample 6 times from B **with replacement**, compute mean(B*)
- Compute diff* = mean(B*) − mean(A*)

After 1,000 repeats you have 1,000 diff* values.

**Step 4: Take the percentile CI**
- Sort diff*
- CI_low = 2.5th percentile
- CI_high = 97.5th percentile

**Example outcome (illustrative):**
- 95% bootstrap CI for the mean difference = **[−29.0, −11.0]** seconds

**How to write this in your report**
> “Build B reduced completion time by 20s on average (95% bootstrap CI [−29, −11]). This suggests the change likely reduced friction during the level.”

### Example 2 — CI for a completion-rate difference (completed yes/no)

**Question:** Did Build B increase completion rate?

We test 20 sessions per build:

- Build A: 11 completed, 9 did not → completion rate(A) = 11/20 = **55%**
- Build B: 15 completed, 5 did not → completion rate(B) = 15/20 = **75%**

**Observed difference**
- difference = 75% − 55% = **+20 percentage points**

#### Bootstrap CI for completion-rate difference (simple approach)
Repeat many times (e.g., 5,000):
1. Create a resample of 20 sessions from Build A’s 0/1 outcomes (with replacement), compute rate(A*)
2. Create a resample of 20 sessions from Build B’s 0/1 outcomes (with replacement), compute rate(B*)
3. diff* = rate(B*) − rate(A*)

Then take the 2.5th and 97.5th percentiles of diff*.

**Example outcome (illustrative):**
- 95% bootstrap CI for the rate difference = **[+2%, +38%]**

**How to write this in your report**
> “Completion rate improved by 20 percentage points in Build B (95% bootstrap CI [+2%, +38%]). This is consistent with the tutorial change helping more players finish the level.”

## Generating confidence intervals in R (using the module CSV)

In labs and reports, we use **R** to compute confidence intervals. The dataset is usually stored in a `data/` folder.

### The attached dataset (CSV)

Filename (expected path): `data/open_world_user_testing_survey_data.csv`

Key columns you can use:
- `build` : `"A"` or `"B"`
- `task1_time_sec`, `task2_time_sec`, `task3_time_sec` : numeric times (often `NA` when not completed)
- `task1_complete`, `task2_complete`, `task3_complete` : 0/1 completion flags
- `deaths_total`, `bugs_reported` : counts
- `ui_clarity_1to7`, `navigation_1to7`, `combat_fun_1to7`, `frustration_1to7`, `recommend_0to10` : ratings

### R helper functions (bootstrap 95% CI)

The functions below use **bootstrap resampling** (with replacement) to compute 95% CIs.

```r
# ----------------------------
# Bootstrap CI helper functions
# ----------------------------

bootstrap_ci_mean <- function(x, n_boot = 5000, conf_level = 0.95, seed = 123)
{
  # Returns a list with mean estimate and percentile CI.
  # x: numeric vector (can include NA).
  x <- x[!is.na(x)]
  if (length(x) < 2)
    stop("Need at least 2 non-missing values for a CI.")

  set.seed(seed)

  n <- length(x)
  boot_means <- numeric(n_boot)

  for (i in seq_len(n_boot))
    boot_means[i] <- mean(sample(x, size = n, replace = TRUE))

  alpha <- (1 - conf_level) / 2
  ci <- quantile(boot_means, probs = c(alpha, 1 - alpha), names = FALSE)

  list(
    estimate = mean(x),
    ci_low = ci[1],
    ci_high = ci[2],
    n = n,
    n_boot = n_boot
  )
}

bootstrap_ci_mean_diff <- function(x_a, x_b, n_boot = 5000, conf_level = 0.95, seed = 123)
{
  # Returns CI for mean(B) - mean(A).
  x_a <- x_a[!is.na(x_a)]
  x_b <- x_b[!is.na(x_b)]

  if (length(x_a) < 2 || length(x_b) < 2)
    stop("Need at least 2 non-missing values in each group for a CI.")

  set.seed(seed)

  n_a <- length(x_a)
  n_b <- length(x_b)

  boot_diffs <- numeric(n_boot)

  for (i in seq_len(n_boot))
  {
    mean_a <- mean(sample(x_a, size = n_a, replace = TRUE))
    mean_b <- mean(sample(x_b, size = n_b, replace = TRUE))
    boot_diffs[i] <- mean_b - mean_a
  }

  alpha <- (1 - conf_level) / 2
  ci <- quantile(boot_diffs, probs = c(alpha, 1 - alpha), names = FALSE)

  list(
    estimate = mean(x_b) - mean(x_a),
    ci_low = ci[1],
    ci_high = ci[2],
    n_a = n_a,
    n_b = n_b,
    n_boot = n_boot
  )
}

bootstrap_ci_rate_diff <- function(y_a, y_b, n_boot = 5000, conf_level = 0.95, seed = 123)
{
  # Returns CI for rate(B) - rate(A) where y is 0/1.
  y_a <- y_a[!is.na(y_a)]
  y_b <- y_b[!is.na(y_b)]

  if (length(y_a) < 2 || length(y_b) < 2)
    stop("Need at least 2 non-missing values in each group for a CI.")

  if (!all(y_a %in% c(0, 1)) || !all(y_b %in% c(0, 1)))
    stop("Rate CI expects 0/1 data (binary).")

  set.seed(seed)

  n_a <- length(y_a)
  n_b <- length(y_b)

  boot_diffs <- numeric(n_boot)

  for (i in seq_len(n_boot))
  {
    rate_a <- mean(sample(y_a, size = n_a, replace = TRUE))
    rate_b <- mean(sample(y_b, size = n_b, replace = TRUE))
    boot_diffs[i] <- rate_b - rate_a
  }

  alpha <- (1 - conf_level) / 2
  ci <- quantile(boot_diffs, probs = c(alpha, 1 - alpha), names = FALSE)

  list(
    estimate = mean(y_b) - mean(y_a),
    ci_low = ci[1],
    ci_high = ci[2],
    n_a = n_a,
    n_b = n_b,
    n_boot = n_boot
  )
}
```

### Example 1 — CI for mean difference in Task 1 completion time (Build B − Build A)

This example compares **Task 1 time** between builds, using only sessions where the task was completed.

```r
# ----------------------------
# Load data
# ----------------------------
df <- read.csv("data/open_world_user_testing_survey_data.csv")

# ----------------------------
# Filter to completed Task 1 (time is NA if not completed)
# ----------------------------
a_time <- df$task1_time_sec[df$build == "A" & df$task1_complete == 1]
b_time <- df$task1_time_sec[df$build == "B" & df$task1_complete == 1]

# ----------------------------
# Bootstrap CI for mean difference (B - A)
# ----------------------------
ci_time <- bootstrap_ci_mean_diff(a_time, b_time, n_boot = 5000, seed = 42)

print(ci_time)

cat(sprintf(
  "\nTask 1 time difference (B - A): %.1f sec, 95%% CI [%.1f, %.1f]\n",
  ci_time$estimate, ci_time$ci_low, ci_time$ci_high
))
```

**How you would write this in your report**
- Report the observed mean difference (B − A).
- Report the 95% CI.
- Interpret what it means for gameplay (e.g., reduced friction, improved guidance, etc.).

### Example 2 — CI for completion-rate difference in Task 2 (Build B − Build A)

This example compares **Task 2 completion rate** (0/1) between builds.

```r
df <- read.csv("data/open_world_user_testing_survey_data.csv")

a_comp <- df$task2_complete[df$build == "A"]
b_comp <- df$task2_complete[df$build == "B"]

ci_rate <- bootstrap_ci_rate_diff(a_comp, b_comp, n_boot = 5000, seed = 42)

print(ci_rate)

cat(sprintf(
  "\nTask 2 completion-rate difference (B - A): %.1f%%, 95%% CI [%.1f%%, %.1f%%]\n",
  100 * ci_rate$estimate, 100 * ci_rate$ci_low, 100 * ci_rate$ci_high
))
```

### Optional: CI for a mean in a single build (Build B only)

```r
df <- read.csv("data/open_world_user_testing_survey_data.csv")

b_time <- df$task1_time_sec[df$build == "B" & df$task1_complete == 1]
ci_b_mean <- bootstrap_ci_mean(b_time, n_boot = 5000, seed = 42)

cat(sprintf(
  "Build B mean Task 1 time: %.1f sec, 95%% CI [%.1f, %.1f] (n=%d)\n",
  ci_b_mean$estimate, ci_b_mean$ci_low, ci_b_mean$ci_high, ci_b_mean$n
))
```

> For your lab report, you only need **at least one** CI, but you may include more if they support your conclusions.

## What is “significance”?

For this module, use this rule of thumb:
- If your **95% CI for the difference** does **not** include 0, the evidence for a real difference is stronger.
- If it **does** include 0, your data is consistent with “no difference” (or you need more data).

You still report the observed difference — you just phrase your confidence honestly.

## Reporting your results

### The 4-sentence results paragraph template
We will use this structure in our lab report:

1) **Metric + direction**  
> “Players completed the level faster in Build B than Build A.”

2) **Magnitude**  
> “The mean difference was −12 seconds (B − A).”

3) **Uncertainty**  
> “A 95% bootstrap CI for the mean difference was [−21, −3].”

4) **Interpretation in game terms**  
> “This suggests Build B reduced friction during the puzzle sequence, likely due to the new waypoint hinting.”

### Add a recommendation
End your Results/Discussion with a design action:
> “We recommend keeping the waypoint hinting and next testing whether it also reduces early drop-off in the first 3 minutes.”

## Common pitfalls (short, important)

- **Too many outcomes:** pick one primary metric.
- **Comparing different tasks:** make sure A and B are truly comparable.
- **Tiny samples:** avoid strong claims; be honest about uncertainty.
- **Outliers:** investigate whether they are real behaviour or data errors.
- **Causation language:** comparisons show differences, not guaranteed causes.

## Minimum lab report requirements from these notes

| Item | What you must include |
| :- | :- |
| Hypothesis | H0/H1 in plain English |
| Summary table | n, mean/median, spread for each group |
| One comparison | mean/median difference (or rate difference) |
| One uncertainty statement | a 95% CI for the mean or difference |
| One plot | group comparison plot (box plot or similar) |
| Interpretation | 2–4 sentences in gameplay terms |
| Recommendation | one concrete design/next test action |
