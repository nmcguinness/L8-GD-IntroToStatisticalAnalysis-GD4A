# Practical Analysis Tools & Lab Report Structure 

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

## Lab report requirements

Your user-testing report follows the template used in this module. In these notes we focus on the **statistics, tables, and plots** you must produce for:

- **Section 8: Data Analysis** (how you analysed the data)
- **Section 9: Results** (the numbers, tables, figures, and findings)

Use these as your minimum reporting components.

### Data Analysis section

Include short, factual statements covering:

- **Dataset handling:** what you excluded (e.g., incomplete sessions for time metrics) and why.
- **Metrics chosen:** 2–4 primary metrics linked to your testing objectives.
- **Quantitative methods used:** descriptive statistics, at least one 95% confidence interval, and optional correlation/regression if they help answer your objectives.
- **Qualitative approach (if used):** how you grouped comments (themes/categories) and what you counted or prioritised.

### Results section

Your Results must include:

- **Table 1:** a summary table comparing key metrics (and `n`) for each build/group.
- **At least one 95% CI:** reported as a sentence in gameplay terms.
- **Figures:** 2–4 plots that support your story (distribution, group comparison, and one plot that encodes an extra dimension using colour/fill or facets).
- **Comparison paragraph (if comparing builds/groups):** follow the 4-sentence template in Notes 02.
- **Optional supporting outputs:** a small correlation matrix and one simple regression, only if they are clearly relevant to your objectives.

### Where each output goes in the report

| Output | Report section |
| :- | :- |
| Exclusions + sanity checks | Methodology or Data Analysis |
| Table 1 (summary table) | Results |
| CI sentence | Results |
| Figures 1–4 | Results |
| Build/group comparison paragraph | Results (and Discussion if needed) |
| Correlation matrix (small) | Results or Appendix |
| Regression plot + slope sentence | Results (and Discussion if needed) |




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

## Minimal R setup

```r
# Read the CSV file into a data frame
df <- read.csv("data/open_world_user_testing_survey_data.csv")

# Quick inspection
str(df)
nrow(df)
table(df$build, useNA = "ifany")
```

---

## Cleaning and validation

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
# Count missing (NA) values
sum(is.na(df$task1_time_sec))

# Sanity checks for counts
# Basic summary stats per column
summary(df$deaths_total)

# Binary column check
table(df$task1_complete, useNA = "ifany")
```

---

## Descriptive statistics

A good lab report always begins with **simple summaries**.

### Report-ready summary table

This is the typical “Table 1” students include in Results.

```r
# Save the result into `mean_sd` for reuse
mean_sd <- function(x)
{
# Save the result into `x` for reuse
  x <- x[!is.na(x)]
  c(mean = mean(x), sd = sd(x), n = length(x))
}

# Example primary metric: Task 1 completion time
# Save the result into `a_time` for reuse
a_time <- df$task1_time_sec[df$build == "A" & df$task1_complete == 1]
# Save the result into `b_time` for reuse
b_time <- df$task1_time_sec[df$build == "B" & df$task1_complete == 1]

# Save the result into `a_stats` for reuse
a_stats <- mean_sd(a_time)
# Save the result into `b_stats` for reuse
b_stats <- mean_sd(b_time)

# Example binary outcome: Task 1 completion rate
# Compute the mean
a_rate <- mean(df$task1_complete[df$build == "A"], na.rm = TRUE)
# Compute the mean
b_rate <- mean(df$task1_complete[df$build == "B"], na.rm = TRUE)

# Save the result into `summary_table` for reuse
summary_table <- data.frame(
  metric = c("n (Task 1 completed)", "mean Task 1 time (s)", "SD Task 1 time (s)", "Task 1 completion rate"),
  build_A = c(a_stats["n"], a_stats["mean"], a_stats["sd"], a_rate),
  build_B = c(b_stats["n"], b_stats["mean"], b_stats["sd"], b_rate)
)

# Print the result to the output
print(summary_table, row.names = FALSE)
```

---



### Making tables look good in your report

Your Results should include **at least one clean table** that a reader can understand at a glance.

Beginner rules:
- include `n` (sample size),
- round to **1–2** decimal places,
- use human labels (not raw column names),
- keep large tables for an Appendix.

#### A simple table with `knitr::kable()`

```r
# Load dplyr package
library(dplyr)
# Load knitr package
library(knitr)

# Save the result into `summary_tbl` for reuse
summary_tbl <- df |>
# Group rows so summarise() runs per-group
  group_by(build) |>
# Compute summary statistics for each group
  summarise(
    n = n(),
# Compute the mean
    avg_time_sec = mean(task1_time_sec, na.rm = TRUE),
    sd_time_sec = sd(task1_time_sec, na.rm = TRUE),
# Compute the mean
    completion_rate = mean(task1_complete, na.rm = TRUE),
    .groups = "drop"
  )

# Create a simple, report-friendly table
kable(summary_tbl, digits = 2, caption = "Summary by build (Task 1)")
```

If you want nicer formatting later, you can upgrade the same table using a styling package (for example `gt`), but **kable is enough** for this module.

---
## Confidence intervals

You must include **at least one 95% CI** in your lab report.

At this stage, we recommend **bootstrap CIs** (they work well for playtest-sized samples).

**Important:** the full bootstrap helper function and two worked examples are in **Notes 02 — Comparing Groups & Testing Hypotheses**.  
In this note, we focus on *where the CI belongs* in your Results, and how to *report it clearly*.

### Where the CI belongs in your Results

A confidence interval should appear **immediately after** you report a difference, for example:

> “Build B reduced Task 1 completion time by **X seconds** on average (95% CI [L, U]).”

Then add **one or two** sentences of gameplay interpretation.

### Minimal CI call

```r
# See Notes 02 for bootstrap_ci_mean_diff()
# Example: Task 1 completion time difference

# Save the result into `a_time` for reuse
a_time <- df$task1_time_sec[df$build == "A" & df$task1_complete == 1]
# Save the result into `b_time` for reuse
b_time <- df$task1_time_sec[df$build == "B" & df$task1_complete == 1]

# Save the result into `ci` for reuse
ci <- bootstrap_ci_mean_diff(a_time, b_time, n_boot = 5000, seed = 42)

cat(sprintf(
  "Task 1 time difference (B - A): %.1f sec, 95%% CI [%.1f, %.1f]
",
  ci$estimate, ci$ci_low, ci$ci_high
))
```

---
## Plots

Use plots to support your conclusions. Most beginner reports need **two to three** plots.

### Plot: group comparison for a numeric metric

```r
# Draw a basic boxplot using base R
boxplot(task1_time_sec ~ build, data = df[df$task1_complete == 1, ],
        main = "Task 1 Completion Time by Build",
        xlab = "Build",
        ylab = "Time (seconds)")
```

### Plot: completion rate by build

```r
# Save the result into `rates` for reuse
rates <- tapply(df$task1_complete, df$build, mean, na.rm = TRUE)

barplot(rates,
        main = "Task 1 Completion Rate by Build",
        ylab = "Completion rate",
        ylim = c(0, 1))
```

### Plot: relationship for regression

```r
# Draw a basic scatter plot using base R
plot(df$deaths_total, df$task1_time_sec,
     xlab = "Deaths (total)",
     ylab = "Task 1 time (sec)",
     main = "Task 1 Time vs Deaths")
```

**Rule:** every plot must answer a question you stated in Aim/Research Questions.

---



### Using esquisse to build ggplot charts

If you struggle to remember ggplot syntax, use **esquisse** to build the chart visually, then export the code and paste it into your report.

```r
# Install once
# install.packages("esquisse")

# Load esquisse package
library(esquisse)
esquisser(df)
```

After you export the code, apply these **three** beginner upgrades:

```r
p +
# Add titles and labels
  labs(
    title = "Clear title",
    subtitle = "What the reader should notice",
    x = "Label with units",
    y = "Label with units",
    caption = "Data: open_world_user_testing_survey_data.csv"
  ) +
# Use a clean theme for readability
  theme_minimal(base_size = 12)
```

### Encoding more information clearly with ggplot

Below are **simple patterns** that let a single plot carry more meaning without making the analysis harder.

#### Pattern A — Stacked bars

Use when you want to show how a category is *made up* of subgroups (e.g. experience bands within each platform).

```r
# Load dplyr package
library(dplyr)
# Load ggplot2 package
library(ggplot2)

df |>
# Keep only rows that match a condition
  filter(!is.na(platform), !is.na(experience_band)) |>
# Start a ggplot: map variables to visual aesthetics
  ggplot(aes(x = platform, fill = experience_band)) +
# Draw bars
  geom_bar() +
# Add titles and labels
  labs(
    title = "Respondents by Platform",
    subtitle = "Stacked by experience band",
    x = "Platform",
    y = "Count",
    fill = "Experience"
  ) +
# Use a clean theme for readability
  theme_minimal(base_size = 12)
```

**100% stacked (proportions instead of counts):**

```r
df |>
# Keep only rows that match a condition
  filter(!is.na(platform), !is.na(experience_band)) |>
# Start a ggplot: map variables to visual aesthetics
  ggplot(aes(x = platform, fill = experience_band)) +
# Draw bars
  geom_bar(position = "fill") +
# Adjust the y-axis scale
  scale_y_continuous(labels = scales::percent) +
# Add titles and labels
  labs(
    title = "Respondents by Platform",
    subtitle = "Proportion in each experience band",
    x = "Platform",
    y = "Proportion",
    fill = "Experience"
  ) +
# Use a clean theme for readability
  theme_minimal(base_size = 12)
```

#### Pattern B — Grouped bars

Use when you want to compare A vs B *inside* each subgroup (e.g. completion rate by build, split by platform).

```r
df |>
# Keep only rows that match a condition
  filter(!is.na(platform), !is.na(build)) |>
# Group rows so summarise() runs per-group
  group_by(platform, build) |>
# Compute the mean
  summarise(rate = mean(task1_complete, na.rm = TRUE), .groups = "drop") |>
# Start a ggplot: map variables to visual aesthetics
  ggplot(aes(x = platform, y = rate, fill = build)) +
# Draw bars using precomputed values
  geom_col(position = "dodge") +
# Adjust the y-axis scale
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
# Add titles and labels
  labs(
    title = "Task 1 Completion Rate",
    subtitle = "Build comparison within each platform",
    x = "Platform",
    y = "Completion rate",
    fill = "Build"
  ) +
# Use a clean theme for readability
  theme_minimal(base_size = 12)
```

#### Pattern C — Facets

Use when a single plot gets too busy. Facets keep the same axes and repeat the plot in panels.

```r
df |>
# Keep only rows that match a condition
  filter(task1_complete == 1, !is.na(task1_time_sec), !is.na(platform)) |>
# Start a ggplot: map variables to visual aesthetics
  ggplot(aes(x = build, y = task1_time_sec)) +
# Draw a boxplot to show median, quartiles, and outliers
  geom_boxplot() +
# Split into small multiples
  facet_wrap(~ platform) +
# Add titles and labels
  labs(
    title = "Task 1 Completion Time by Build",
    subtitle = "One panel per platform",
    x = "Build",
    y = "Time (seconds)"
  ) +
# Use a clean theme for readability
  theme_minimal(base_size = 12)
```

#### Pattern D — Reorder categories

If categories appear in alphabetical order, your key message can get hidden.
Reorder by a value you care about (e.g. highest average score first).

```r
# Load forcats package
library(forcats)

df |>
# Keep only rows that match a condition
  filter(!is.na(platform), !is.na(score)) |>
# Group rows so summarise() runs per-group
  group_by(platform) |>
# Compute the mean
  summarise(avg_score = mean(score, na.rm = TRUE), .groups = "drop") |>
# Create or transform columns
  mutate(platform = fct_reorder(platform, avg_score)) |>
# Start a ggplot: map variables to visual aesthetics
  ggplot(aes(x = platform, y = avg_score)) +
# Draw bars using precomputed values
  geom_col() +
  coord_flip() +
# Add titles and labels
  labs(
    title = "Average Score by Platform",
    x = "Platform",
    y = "Average score"
  ) +
# Use a clean theme for readability
  theme_minimal(base_size = 12)
```

**Rule:** every plot must answer a question you stated in Aim/Research Questions, and every plot needs **2–4 sentences** of interpretation.

---
## Correlation matrices

Correlation helps you answer:
> “Which metrics move together?”

Correlation is **not** causation. Use it as evidence for “likely relationships” and to guide follow-up tests.

### Correlation matrix in R

Pick a small set of numeric metrics that make sense together.

```r
# Save the result into `metrics` for reuse
metrics <- c("task1_time_sec", "deaths_total", "score", "bugs_reported", "recommend_0to10")
# Save the result into `metrics` for reuse
metrics <- metrics[metrics %in% names(df)]

# Save the result into `num_df` for reuse
num_df <- df[metrics]
# Save the result into `num_df_complete` for reuse
num_df_complete <- na.omit(num_df)

# Save the result into `cor_mat` for reuse
cor_mat <- cor(num_df_complete, method = "pearson")
# Round numbers so tables are readable
print(round(cor_mat, 2))
```

### Report the top 3 strongest correlations

```r
# Save the result into `pairs` for reuse
pairs <- which(upper.tri(cor_mat), arr.ind = TRUE)

# Save the result into `pair_df` for reuse
pair_df <- data.frame(
  var1 = rownames(cor_mat)[pairs[, 1]],
  var2 = colnames(cor_mat)[pairs[, 2]],
  r = cor_mat[pairs]
)

# Save the result into `pair_df` for reuse
pair_df <- pair_df[order(abs(pair_df$r), decreasing = TRUE), ]
head(pair_df, 3)
```

Write one sentence per correlation in gameplay terms:
> “Completion time correlated with deaths (r = 0.62), consistent with players repeating the same encounter.”

---

## Simple linear regression

Regression answers:
> “If X increases, how does Y tend to change?”

At this stage:
- use **one predictor** (X),
- use **one outcome** (Y),
- treat it as **descriptive** (not proof of causation).

### Simple regression in R

Example: predict Task 1 completion time from deaths.

```r
# Use completed sessions only
# Save the result into `d` for reuse
d <- df[df$task1_complete == 1, ]

# Save the result into `model` for reuse
model <- lm(task1_time_sec ~ deaths_total, data = d)
# Basic summary stats per column
summary(model)

# Save the result into `slope` for reuse
slope <- coef(model)[["deaths_total"]]
# Save the result into `intercept` for reuse
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

## Writing your Results

For each metric you report, use this checklist:

1) **What** did you measure (metric + units)?  
2) **What** did you find (a number from a table or plot)?  
3) If comparing A vs B: **difference + 95% CI** (see Notes 02 for the full template).  
4) **So what?** one gameplay interpretation sentence.  
5) **Next action:** what the team should test or change next.

Keep it consistent. Your reader should never have to guess what a plot/table means.

---

## Common mistakes to avoid

- Reporting only plots with no numbers.
- Reporting only numbers with no plots.
- Treating correlation/regression as proof of causation.
- Using every metric you collected (pick what supports your aim).
- Over-claiming with small samples (use cautious language + CI).
- Forgetting to state exclusions (e.g., time only includes completed sessions).


## Appendix — Full copy‑paste QMD example

Copy this into a new Quarto file called something like `analysis.qmd`, save it in the same folder as your `data/` directory, and click **Render**.

```qmd
---
title: "Gameplay Testing — Simple Analysis"
format:
  html:
    toc: true
    number-sections: false
execute:
  echo: true
  warning: false
  message: false
---

## Setup

```{r}
# Load the packages we need for simple data work + charts
library(tidyverse)

# Read the survey CSV from the data/ folder
df <- read_csv("data/open_world_user_testing_survey_data.csv")

# Quick sanity checks
nrow(df)
ncol(df)
glimpse(df)
```

## 1) Clean a small working dataset

```{r}
# Keep only the columns we will use in this mini-report
work <- df |>
  select(build, platform, experience_band, task1_time_sec, would_recommend)

# Drop rows where the key metric is missing
work <- work |>
  filter(!is.na(task1_time_sec))

# Create a simple "recommend yes/no" column
work <- work |>
  mutate(recommend_yes = would_recommend >= 4)
```

## 2) Table: simple summary

```{r}
# Summarise task time by platform
summary_by_platform <- work |>
  group_by(platform) |>
  summarise(
    n = n(),
    mean_time_sec = mean(task1_time_sec, na.rm = TRUE),
    sd_time_sec = sd(task1_time_sec, na.rm = TRUE)
  ) |>
  mutate(
    mean_time_sec = round(mean_time_sec, 1),
    sd_time_sec = round(sd_time_sec, 1)
  ) |>
  arrange(desc(mean_time_sec))

# Print a clean table in the report
knitr::kable(summary_by_platform, caption = "Task 1 time (seconds) by platform")
```

## 3) Plot: 100% stacked bar

```{r}
# Count testers by platform and experience band
counts <- work |>
  count(platform, experience_band)

# 100% stacked bar shows composition clearly
ggplot(counts, aes(x = platform, y = n, fill = experience_band)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Tester experience by platform",
    subtitle = "100% stacked bars show the composition within each platform",
    x = "Platform",
    y = "Share of testers",
    fill = "Experience band",
    caption = "Source: gameplay testing survey"
  ) +
  theme_minimal()
```

## 4) Plot: facets

```{r}
# Visualise task time by experience, split into panels by platform
ggplot(work, aes(x = experience_band, y = task1_time_sec)) +
  geom_boxplot() +
  facet_wrap(~ platform) +
  labs(
    title = "Task 1 completion time by experience band",
    subtitle = "Facets make it easier to compare patterns platform-by-platform",
    x = "Experience band",
    y = "Task 1 time (seconds)",
    caption = "Source: gameplay testing survey"
  ) +
  theme_minimal()
```

## 5) Write-up

In your **Results**, for each table/figure write **2–4 sentences**:

- What is shown (what variables, what chart/table)
- The main visible pattern
- Why it matters for gameplay/design
- What you will test next (one concrete next step)

```