# Practical Analysis Tools & Lab Report Structure (Beginner + R)

These notes show **what to do** with gameplay testing data and **how to write it up**.

At this stage, your analysis should be:
- **small** (a few clear metrics),
- **honest** (state uncertainty),
- **actionable** (recommend a next design/test step).

You will use R to generate:
- descriptive statistics (tables),
- at least one 95% confidence interval (CI),
- a small correlation matrix,
- a simple linear regression (one predictor),
- a small set of plots that support your story.

---

## The dataset you will analyse

For this module, your CSV is normally stored in a `data/` folder:

- `data/open_world_user_testing_survey_data.csv`

Typical columns you may see (your dataset may include a subset):

| Column | Type | Example | Notes |
| :- | :- | :- | :- |
| player_id | categorical | P014 | anonymised |
| build | categorical | A / B | the version tested |
| task1_complete | binary | 0/1 | did they finish the task? |
| task1_time_sec | numeric | 92.3 | often `NA` if not completed |
| deaths_total | count | 5 | integer count |
| bugs_reported | count | 2 | integer count |
| score | numeric | 1840 | game-specific |
| ui_clarity_1to7 | ordinal | 1–7 | treat cautiously |
| recommend_0to10 | ordinal-ish | 7 | can be treated as numeric for summaries |

**Tidy rule:** one row = one play session (or one attempt). One column = one variable.

---

## Minimal R setup (read + inspect)

```r
df <- read.csv("data/open_world_user_testing_survey_data.csv")

# Quick inspection
str(df)
nrow(df)
table(df$build, useNA = "ifany")
```

---

## Cleaning and validation (what you must do before analysis)

You do not need perfect data. You do need data that is **not misleading**.

| Check | Why it matters | Typical fix |
| :- | :- | :- |
| Missing values | can bias summaries | analyse completed-only for time metrics; report exclusions |
| Impossible ranges | indicates entry bugs | validate ranges; fix obvious errors; otherwise exclude |
| Inconsistent labels | breaks grouping | standardise values (A/B, 0/1, Yes/No) |
| Duplicates | inflates n | remove duplicate sessions |
| Outliers | can distort means | verify; report effect of removal if you remove |

**Rule:** never delete data silently. If you exclude rows, state what you excluded and why.

Useful checks in R:

```r
# Missingness for a key metric
sum(is.na(df$task1_time_sec))

# Sanity checks for counts
summary(df$deaths_total)

# Binary column check (should be 0/1/NA)
table(df$task1_complete, useNA = "ifany")
```

---

## Descriptive statistics (your Results should start here)

A good lab report always begins with **simple summaries**.

### Report-ready summary table (Build A vs Build B)

This is the typical “Table 1” students include in Results.

```r
mean_sd <- function(x)
{
  x <- x[!is.na(x)]
  c(mean = mean(x), sd = sd(x), n = length(x))
}

# Example primary metric: Task 1 completion time (completed sessions only)
a_time <- df$task1_time_sec[df$build == "A" & df$task1_complete == 1]
b_time <- df$task1_time_sec[df$build == "B" & df$task1_complete == 1]

a_stats <- mean_sd(a_time)
b_stats <- mean_sd(b_time)

# Example binary outcome: Task 1 completion rate (0/1)
a_rate <- mean(df$task1_complete[df$build == "A"], na.rm = TRUE)
b_rate <- mean(df$task1_complete[df$build == "B"], na.rm = TRUE)

summary_table <- data.frame(
  metric = c("n (Task 1 completed)", "mean Task 1 time (s)", "SD Task 1 time (s)", "Task 1 completion rate"),
  build_A = c(a_stats["n"], a_stats["mean"], a_stats["sd"], a_rate),
  build_B = c(b_stats["n"], b_stats["mean"], b_stats["sd"], b_rate)
)

print(summary_table, row.names = FALSE)
```

---

## Confidence intervals (required in your report)

You must include **at least one 95% CI** in your lab report.

At this stage, we recommend **bootstrap CIs** (they work well for playtest-sized samples).

### Bootstrap CI for a mean difference (Build B − Build A)

```r
bootstrap_ci_mean_diff <- function(x_a, x_b, n_boot = 5000, conf_level = 0.95, seed = 123)
{
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

  list(estimate = mean(x_b) - mean(x_a), ci_low = ci[1], ci_high = ci[2])
}

# Example: Task 1 completion time difference (Build B - Build A)
a_time <- df$task1_time_sec[df$build == "A" & df$task1_complete == 1]
b_time <- df$task1_time_sec[df$build == "B" & df$task1_complete == 1]

ci <- bootstrap_ci_mean_diff(a_time, b_time, n_boot = 5000, seed = 42)

cat(sprintf(
  "Task 1 time difference (B - A): %.1f sec, 95%% CI [%.1f, %.1f]\n",
  ci$estimate, ci$ci_low, ci$ci_high
))
```

### How to write the CI sentence in your report

Use the same pattern every time:

> “Build B changed Task 1 completion time by **X seconds** on average (95% CI [L, U]).”

Then follow with gameplay interpretation.

---

## Plots (keep them few and purposeful)

Use plots to support your conclusions. Most beginner reports need **two to three** plots.

### Plot: group comparison for a numeric metric (box plot)

```r
boxplot(task1_time_sec ~ build, data = df[df$task1_complete == 1, ],
        main = "Task 1 Completion Time by Build",
        xlab = "Build",
        ylab = "Time (seconds)")
```

### Plot: completion rate by build (bar chart)

```r
rates <- tapply(df$task1_complete, df$build, mean, na.rm = TRUE)

barplot(rates,
        main = "Task 1 Completion Rate by Build",
        ylab = "Completion rate",
        ylim = c(0, 1))
```

### Plot: relationship for regression (scatter plot)

```r
plot(df$deaths_total, df$task1_time_sec,
     xlab = "Deaths (total)",
     ylab = "Task 1 time (sec)",
     main = "Task 1 Time vs Deaths")
```

**Rule:** every plot must answer a question you stated in Aim/Research Questions.

---

## Comparing groups (A vs B) in one paragraph

For your lab report, keep your A vs B write-up short and consistent.

Use this structure:

1) **Direction**: which build is better (and for what metric)?  
2) **Magnitude**: how big is the difference?  
3) **Uncertainty**: CI for the difference.  
4) **Meaning**: what does this suggest about gameplay?  
5) **Action**: what should the team do next?

(Details and wording templates are in Notes 02.)

---

## Correlation matrices (discover relationships)

Correlation helps you answer:
> “Which metrics move together?”

Correlation is **not** causation. Use it as evidence for “likely relationships” and to guide follow-up tests.

### Correlation matrix in R

Pick a small set of numeric metrics that make sense together.

```r
metrics <- c("task1_time_sec", "deaths_total", "score", "bugs_reported", "recommend_0to10")
metrics <- metrics[metrics %in% names(df)]

num_df <- df[metrics]
num_df_complete <- na.omit(num_df)

cor_mat <- cor(num_df_complete, method = "pearson")
print(round(cor_mat, 2))
```

### Report the top 3 strongest correlations (optional but useful)

```r
pairs <- which(upper.tri(cor_mat), arr.ind = TRUE)

pair_df <- data.frame(
  var1 = rownames(cor_mat)[pairs[, 1]],
  var2 = colnames(cor_mat)[pairs[, 2]],
  r = cor_mat[pairs]
)

pair_df <- pair_df[order(abs(pair_df$r), decreasing = TRUE), ]
head(pair_df, 3)
```

Write one sentence per correlation in gameplay terms:
> “Completion time correlated with deaths (r = 0.62), consistent with players repeating the same encounter.”

---

## Simple linear regression (one predictor)

Regression answers:
> “If X increases, how does Y tend to change?”

At this stage:
- use **one predictor** (X),
- use **one outcome** (Y),
- treat it as **descriptive** (not proof of causation).

### Simple regression in R

Example: predict Task 1 completion time from deaths.

```r
# Use completed sessions only (time is NA otherwise)
d <- df[df$task1_complete == 1, ]

model <- lm(task1_time_sec ~ deaths_total, data = d)
summary(model)

slope <- coef(model)[["deaths_total"]]
intercept <- coef(model)[["(Intercept)"]]

cat(sprintf("Model: time = %.2f + %.2f * deaths\n", intercept, slope))

plot(d$deaths_total, d$task1_time_sec,
     xlab = "Deaths (total)",
     ylab = "Task 1 time (sec)",
     main = "Task 1 Time vs Deaths (with regression line)")

abline(model)
```

### What to say in the report

- Interpret the slope in plain English:  
  > “Each additional death is associated with about **slope seconds** longer completion time on average.”

- State one limitation (confound):  
  > “Player skill likely influences both deaths and time, so this relationship is not necessarily causal.”

---

## How the analysis pieces fit together

| Stage | Output | Goes in the report as |
| :- | :- | :- |
| Clean & validate | exclusions + sanity checks | Methods (data handling) |
| Describe | summary table | Results (Table 1) |
| CI | one 95% CI sentence | Results |
| Visualise | 2–3 plots | Results (Figures 1–3) |
| Compare A vs B | difference + CI + meaning | Results + Discussion |
| Correlate | correlation matrix + notes | Results / Appendix |
| Regress | scatter + slope sentence | Results + Discussion |
| Recommend | next design + next test | Discussion / Conclusion |

---

### Minimum lab report outputs 

- One cleaned dataset (or clear description of exclusions)
- One summary table (n, mean/median + spread, completion rate)
- At least one 95% CI (mean or mean difference)
- Two to three plots (distribution, group comparison, and/or completion rate)
- One A vs B comparison paragraph (difference + CI + interpretation)
- One correlation matrix with top 3 correlations explained
- One simple regression (scatter + line + slope interpretation)
- One actionable recommendation + one follow-up test question

---

## Common mistakes to avoid

- Reporting only plots with no numbers.
- Reporting only numbers with no plots.
- Treating correlation/regression as proof of causation.
- Using every metric you collected (pick what supports your aim).
- Over-claiming with small samples (use cautious language + CI).
- Forgetting to state exclusions (e.g., time only includes completed sessions).
