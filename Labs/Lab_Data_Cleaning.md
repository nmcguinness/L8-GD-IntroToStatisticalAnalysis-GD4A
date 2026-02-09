---
title: "Playtesting Analytics — Lab: Data Cleaning"
subtitle: "Y4 Collaborative Project — R (Basics) for Report Generation"
description: "Practice select(), filter(), mutate(), and summarise() using a real playtesting survey dataset. Each verb has focused exercises with solutions in collapsible asides."
tags: [r, tidyverse, dplyr, select, filter, mutate, summarise, playtesting, year4]
---

# Overview

In playtesting analysis, “cleaning data” usually means:

- choosing the **columns** you need,
- choosing the **rows** you trust for a specific question,
- transforming columns into a **useful form**,
- producing **small summary tables** that belong in a report.

In this lab, you practice the four dplyr verbs that do exactly that:

| Verb | Think of it as | What it changes |
| :- | :- | :- |
| `select()` | choose columns | columns only |
| `filter()` | choose rows | rows only |
| `mutate()` | transform/create columns | column values (rows unchanged) |
| `summarise()` | reduce rows to summary values | number of rows |

You will work with the class dataset:

- `data/open_world_user_testing_survey_data.csv`

# Learning outcomes

By the end of this lab you can:

- use `select()`, `filter()`, `mutate()`, `summarise()` confidently in a pipeline
- create a **clean analysis dataset** for a specific playtesting question
- produce **report-ready** tables (overall + grouped)
- explain (in plain language) what your cleaning choices mean for results

# Ground rules

- Keep the CSV in the `data/` folder.
- Use **short pipelines**. If a pipeline feels confusing, split it into two.
- Do not “fix” missing values globally. Handle missingness **per task**.
- After each exercise output, write **2–3 sentences**:
  **What → Pattern → Meaning → Action**

# How to run

1. Put `open_world_user_testing_survey_data.csv` in `data/`
2. Open this `.md` file in RStudio
3. Copy the code blocks into an R script, or into a QMD report template
4. Run each block and answer the short write-up prompts

# Setup (copy once)

```r
# Load the tidyverse (includes dplyr + ggplot2 + tidyr + readr + stringr)
library(tidyverse)

# Optional: for clean column names
library(janitor)

csv_file <- "data/open_world_user_testing_survey_data.csv"

if (!file.exists(csv_file))
  stop("CSV file not found: ", csv_file, "\nExpected location: ", csv_file)

raw <- readr::read_csv(csv_file, show_col_types = FALSE)

# Standardise column names so your code is stable across teams
data <- raw %>% janitor::clean_names()

glimpse(data)
```

Write 1 sentence:
- What does the dataset shape (rows × columns) tell you about your playtest?

---

# Exercises — select()

`select()` is for **choosing columns**. It makes your analysis simpler and prevents mistakes.

## Exercise 01 — Keep only the “core report columns”

Create a data frame called `core_df` that keeps:

- `respondent_id`
- `platform`
- `experience_band`
- `session_minutes`
- `recommend_0to10`
- `free_text`

Then print `glimpse(core_df)`.

<details>
<summary>Solution</summary>

```r
core_df <- data %>%
  select(
    respondent_id,
    platform,
    experience_band,
    session_minutes,
    recommend_0to10,
    free_text
  )

glimpse(core_df)
```

</details>

Write 2 sentences:
- Why is it helpful to work with `core_df` instead of the full `data`?
- Which of these columns are categoric, numeric, and text?

## Exercise 02 — Select columns by name pattern

Create `task_df` that keeps **all task-related columns**.

Hint: many datasets name tasks like `task1_...`, `task2_...`, etc.

<details>
<summary>Solution</summary>

```r
task_df <- data %>%
  select(starts_with("task"))

glimpse(task_df)
```

</details>

Write 1–2 sentences:
- Why is pattern-based selection useful for surveys?

## Exercise 03 — Drop a column you don’t need

Create `no_text_df` that contains everything except `free_text`.

<details>
<summary>Solution</summary>

```r
no_text_df <- data %>%
  select(-free_text)

glimpse(no_text_df)
```

</details>

Write 1 sentence:
- When would dropping free-text be sensible?

---

# Exercises — filter()

`filter()` is for **choosing rows**. You normally filter to remove missing values for specific variables, or to focus on a subgroup.

## Exercise 04 — Remove missing recommendation scores

Create `rec_df` that keeps only rows where `recommend_0to10` is not missing.

Then print:

- `nrow(data)`
- `nrow(rec_df)`

<details>
<summary>Solution</summary>

```r
rec_df <- data %>%
  filter(!is.na(recommend_0to10))

nrow(data)
nrow(rec_df)
```

</details>

Write 2–3 sentences:
- How many rows were removed?
- Give one realistic reason why players might skip this question.

## Exercise 05 — Filter to a subgroup

Create `pc_df` that keeps only rows where `platform` is `"PC"` (or whichever platform exists in your dataset).

Then summarise how many rows remain.

<details>
<summary>Solution</summary>

```r
pc_df <- data %>%
  filter(platform == "PC")

pc_df %>% summarise(n = n())
```

</details>

Write 2 sentences:
- Why might analysing one platform separately be useful?
- What is the risk of making claims from a small subgroup?

## Exercise 06 — Filter to a numeric range

Create `session_range_df` that keeps only rows where `session_minutes` is between 5 and 90.

<details>
<summary>Solution</summary>

```r
session_range_df <- data %>%
  filter(between(session_minutes, 5, 90))

session_range_df %>% summarise(n = n())
```

</details>

Write 2 sentences:
- Why might you remove extremely short or extremely long sessions?
- What could you lose by doing this?

---

# Exercises — mutate()

`mutate()` is for **creating or transforming columns**. This is where you recode, bin, or create flags that make reporting easier.

## Exercise 07 — Convert categoric columns to factors

Create `typed_df` where:

- `platform` is a factor
- `experience_band` is a factor

Then print `glimpse(typed_df)`.

<details>
<summary>Solution</summary>

```r
typed_df <- data %>%
  mutate(
    platform = as.factor(platform),
    experience_band = as.factor(experience_band)
  )

glimpse(typed_df)
```

</details>

Write 1–2 sentences:
- Why do we often use factors for platforms/experience bands?

## Exercise 08 — Create a “high frustration” flag

Create `flag_df` with a new column:

- `high_frustration` is TRUE if `frustration_1to7 >= 6`, otherwise FALSE.

Then count how many TRUE/FALSE you have.

<details>
<summary>Solution</summary>

```r
flag_df <- data %>%
  mutate(
    high_frustration = frustration_1to7 >= 6
  )

flag_df %>% count(high_frustration)
```

</details>

Write 2–3 sentences:
- What question does this flag help you answer?
- Why is a TRUE/FALSE flag sometimes easier to report than a 1–7 scale?

## Exercise 09 — Create a session duration band

Create `band_df` with a new column:

- `session_band` is:
  - `"Short (<15m)"` if `session_minutes < 15`
  - `"Medium (15–44m)"` if `session_minutes < 45`
  - `"Long (45m+)"` if `session_minutes >= 45`

Then count sessions per band.

<details>
<summary>Solution</summary>

```r
band_df <- data %>%
  mutate(
    session_band = case_when(
      session_minutes < 15 ~ "Short (<15m)",
      session_minutes < 45 ~ "Medium (15–44m)",
      session_minutes >= 45 ~ "Long (45m+)",
      TRUE ~ NA_character_
    )
  )

band_df %>% count(session_band)
```

</details>

Write 2 sentences:
- Why can bands be more readable than raw minutes in a report?
- What might you change about the thresholds for your own game?

---

# Exercises — summarise()

`summarise()` is for turning many rows into a smaller set of **report-ready** numbers.

## Exercise 10 — Overall summary (one row)

Create `overall_tbl` with:

- `n`
- mean of `recommend_0to10`
- mean of `frustration_1to7`
- mean of `session_minutes` (ignore missing)

<details>
<summary>Solution</summary>

```r
overall_tbl <- data %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10, na.rm = TRUE),
    mean_frustration = mean(frustration_1to7, na.rm = TRUE),
    mean_session_minutes = mean(session_minutes, na.rm = TRUE)
  )

overall_tbl
```

</details>

Write 3–5 sentences:
- What stands out most in this summary?
- What does it suggest about player experience?
- What would you change next sprint?

## Exercise 11 — Grouped summary (platform)

Create `by_platform_tbl` that shows, per platform:

- `n`
- mean recommendation
- mean frustration

Sort by mean recommendation (highest first).

<details>
<summary>Solution</summary>

```r
by_platform_tbl <- data %>%
  group_by(platform) %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10, na.rm = TRUE),
    mean_frustration = mean(frustration_1to7, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_recommend))

by_platform_tbl
```

</details>

Write 3–5 sentences:
- Which platform appears strongest/weakest?
- Is the sample size per platform large enough to be confident?
- What follow-up test would you run next?

## Exercise 12 — Grouped summary (your new flag)

Using the flag idea from Exercise 08, create a table showing mean recommendation for:

- high frustration = TRUE
- high frustration = FALSE

<details>
<summary>Solution</summary>

```r
by_flag_tbl <- data %>%
  mutate(high_frustration = frustration_1to7 >= 6) %>%
  group_by(high_frustration) %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10, na.rm = TRUE),
    mean_frustration = mean(frustration_1to7, na.rm = TRUE),
    .groups = "drop"
  )

by_flag_tbl
```

</details>

Write 3–5 sentences:
- Does high frustration align with lower recommendation?
- What game-design change would you propose based on this?

---

# Appendix — Common mistakes

| Mistake | Symptom | Fix |
| :- | :- | :- |
| wrong column name | object not found | run `names(data)` and copy/paste |
| missing values | means become NA | use `na.rm = TRUE` or `drop_na()` |
| filtering too much | tiny n | justify your filter and report the remaining sample size |
| messy pipelines | hard to debug | `select()` fewer columns first, then build up step-by-step |
