# Overview

When you “clean data” in R, you are usually doing four things:

1. choosing the columns you care about,
2. choosing the rows you want to keep,
3. transforming columns into a more useful form,
4. producing small summary tables you can report.

In the tidyverse, those four jobs map directly to four functions from **dplyr**:

- `select()` — choose columns  
- `filter()` — choose rows  
- `mutate()` — create/transform columns  
- `summarise()` — reduce many rows into summary values  

You’ll use these four verbs constantly in playtesting analysis because your data typically contains:

- categoric variables (platform, experience band),
- numeric measures (time, deaths, session length),
- rating scales (1–7, 0–10),
- free-text feedback (comments).

# Setup (copy into your QMD or R script)

```r
# Load tidyverse (includes dplyr)
library(tidyverse)

# Assume you already have a data frame called data
# data <- readr::read_csv("data/open_world_user_testing_survey_data_v2.csv", show_col_types = FALSE) |> janitor::clean_names()
```

# The pipe: reading tidyverse code left-to-right

Most tidyverse code uses the pipe operator: `%>%` (or the newer `|>`).

It lets you write:

> “Start with `data`, then do this, then do that, then do that…”

```r
data %>%
  select(platform, recommend_0to10) %>%
  filter(!is.na(recommend_0to10))
```

Read it as:

- Take `data`
- keep the columns `platform` and `recommend_0to10`
- keep only rows where `recommend_0to10` is not missing

# select(): choosing columns

## What select() does

`select()` keeps (or drops) columns. It never changes the number of rows.

```r
# Keep only these columns
data_small <- data %>%
  select(platform, experience_band, recommend_0to10)
```

### Why you use it in cleaning

- You reduce clutter (easier to think).
- You prevent later code from accidentally using the wrong columns.
- You create “analysis-ready” versions of the dataset for specific questions.

## Common select() patterns

### 1) Select a small set of columns by name

```r
data %>%
  select(platform, session_minutes, recommend_0to10)
```

### 2) Drop columns you do not want

```r
data %>%
  select(-free_text)   # Remove the comment column for numeric analysis
```

### 3) Select by a pattern in the name

This is useful when your survey has many similarly named columns.

```r
data %>%
  select(starts_with("task"))        # task1_complete, task2_time_sec, ...
```

Other helpers:

| Helper | Meaning |
| :- | :- |
| `starts_with("x")` | column names start with x |
| `ends_with("x")` | column names end with x |
| `contains("x")` | column names contain x |
| `matches("regex")` | match a regular expression |

Example (ratings ending in `_1to7`):

```r
data %>%
  select(ends_with("_1to7"))
```

### 4) Select using a character vector of column names

This is very common in reusable reports.

```r
key_numeric <- c("session_minutes", "recommend_0to10", "frustration_1to7")

data %>%
  select(all_of(key_numeric))
```

Why `all_of()`?
- It tells `select()` that `key_numeric` contains column names (strings).
- If a column name is wrong, it fails with a clear error (good in learning contexts).

## Quick practice

1. Create `data_small` containing: `platform`, `experience_band`, `recommend_0to10`, `free_text`.  
2. Create `ratings_only` containing all columns that end with `_1to7`.  
3. Create `tasks_only` containing all columns that start with `task`.

# filter(): choosing rows

## What filter() does

`filter()` keeps rows that meet a condition. It never changes the columns.

```r
# Keep only rows where the recommendation score is present
data %>%
  filter(!is.na(recommend_0to10))
```

### Why you use it in cleaning

- Remove missing values *for a specific analysis*.
- Focus on a subgroup (e.g., only console players).
- Remove impossible or nonsense values (data quality checks).

## Conditions you’ll use all the time

### 1) Missing / not missing

```r
data %>% filter(is.na(free_text))      # rows with missing comments
data %>% filter(!is.na(free_text))     # rows with comments
```

### 2) Equals / not equals

```r
data %>% filter(platform == "PC")
data %>% filter(platform != "PC")
```

### 3) Multiple conditions (AND)

Separate conditions with commas. Commas act like AND.

```r
data %>%
  filter(
    platform == "PC",
    !is.na(recommend_0to10)
  )
```

### 4) Either/or (OR)

Use `|` for OR.

```r
data %>%
  filter(platform == "PC" | platform == "Console")
```

### 5) “One of these values”

Use `%in%` for “is in this set”.

```r
data %>%
  filter(platform %in% c("PC", "Console"))
```

### 6) Numeric ranges

```r
data %>%
  filter(session_minutes >= 10, session_minutes <= 120)
```

Or with `between()`:

```r
data %>%
  filter(between(session_minutes, 10, 120))
```

## A very common playtesting filter pattern: “complete cases for these columns”

If you are going to calculate a correlation or run regression, you need rows with no missing values for the variables involved.

```r
vars <- c("recommend_0to10", "frustration_1to7", "combat_fun_1to7")

analysis_df <- data %>%
  select(all_of(vars)) %>%
  drop_na()   # keeps only rows where none of these are NA
```

## Quick practice

1. Keep only rows where `free_text` is not missing.  
2. Keep only rows where `session_minutes` is between 5 and 90.  
3. Keep only rows where `platform` is in two platforms of your choice.  

# mutate(): creating or transforming columns

## What mutate() does

`mutate()` adds new columns or transforms existing ones. It keeps the number of rows the same.

### Why you use it in cleaning

- Convert types (character → factor, numeric → integer).
- Recode messy values into consistent categories.
- Create derived features (e.g., “high frustration” flag).
- Produce more readable variables for plots and tables.

## Common mutate() patterns

### 1) Convert categoric columns to factors

```r
data2 <- data %>%
  mutate(
    platform = as.factor(platform),
    experience_band = as.factor(experience_band)
  )
```

### 2) Create a new derived column

Example: create a “high frustration” flag from a 1–7 scale.

```r
data2 <- data %>%
  mutate(
    high_frustration = frustration_1to7 >= 6
  )
```

Now you can summarise by that flag:

```r
data2 %>%
  group_by(high_frustration) %>%
  summarise(mean_recommend = mean(recommend_0to10, na.rm = TRUE))
```

### 3) Recode values into nicer labels

If your platform values are inconsistent (e.g., "pc", "PC", "Pc"), you can standardise them.

```r
data2 <- data %>%
  mutate(
    platform = str_to_upper(platform)   # "pc" -> "PC"
  )
```

### 4) Create a grouped/binned version of a numeric column

Example: turn session minutes into categories:

```r
data2 <- data %>%
  mutate(
    session_band = case_when(
      session_minutes < 15 ~ "Short (<15m)",
      session_minutes < 45 ~ "Medium (15–44m)",
      session_minutes >= 45 ~ "Long (45m+)",
      TRUE ~ NA_character_
    )
  )
```

Notes:
- `case_when()` reads like a set of IF rules.
- The final `TRUE ~ ...` is the “otherwise” case.

### 5) Make a rating explicitly ordered

For Likert ratings, it’s sometimes helpful to treat them as ordered categories:

```r
data2 <- data %>%
  mutate(
    ui_clarity_1to7 = factor(ui_clarity_1to7, levels = 1:7, ordered = TRUE)
  )
```

## Quick practice

1. Create `high_frustration` where ratings 6–7 are TRUE, otherwise FALSE.  
2. Create `session_band` with three bands.  
3. Convert `platform` to uppercase and then to factor.  

# summarise(): producing report-friendly numbers

## What summarise() does

`summarise()` collapses many rows into fewer rows by computing summary values.

Without grouping, you usually get **one row**.

```r
data %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10, na.rm = TRUE),
    sd_recommend = sd(recommend_0to10, na.rm = TRUE)
  )
```

### Why you use it in cleaning

- Produce counts and means for tables.
- Summarise by groups (platform, experience band).
- Create “missing values” summaries.
- Build descriptive statistics sections of reports.

## summarise() with group_by(): one of the most important patterns

### Group means by platform

```r
data %>%
  group_by(platform) %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_recommend))
```

Key idea:
- `group_by(platform)` splits the data into “platform groups”.
- `summarise(...)` runs separately inside each group.

### Group multiple metrics at once

```r
data %>%
  group_by(platform) %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10, na.rm = TRUE),
    mean_frustration = mean(frustration_1to7, na.rm = TRUE),
    mean_combat_fun = mean(combat_fun_1to7, na.rm = TRUE)
  )
```

## A classic cleaning summary: missing values by column

You’ve seen this in the report template — it’s a great example of `summarise()` + `across()`.

```r
missing_summary <- data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing") %>%
  arrange(desc(missing))

missing_summary
```

Read it as:
- “For every column, count NAs, then reshape into a tidy table.”

## Quick practice

1. Summarise `n`, mean, and sd for `recommend_0to10`.  
2. Summarise mean recommendation by `platform`.  
3. Summarise mean frustration by `experience_band`.  

# Putting it together: “classic cleaning pipelines”

These are the pipelines you’ll write most often.

## Pipeline 1: prepare an analysis dataset for a specific question

Question:
> Do highly frustrated players give lower recommendation scores?

```r
analysis_df <- data %>%
  # 1) Keep only the columns needed for this question
  select(frustration_1to7, recommend_0to10) %>%
  # 2) Keep only complete rows for these columns
  drop_na() %>%
  # 3) Create a derived column to define a group
  mutate(high_frustration = frustration_1to7 >= 6)

analysis_df
```

## Pipeline 2: produce a small report table

```r
analysis_df %>%
  group_by(high_frustration) %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10),
    mean_frustration = mean(frustration_1to7)
  )
```

## Pipeline 3: “clean then plot”

```r
plot_df <- data %>%
  select(platform, recommend_0to10) %>%
  drop_na() %>%
  mutate(platform = as.factor(platform))

ggplot(plot_df, aes(x = platform, y = recommend_0to10)) +
  geom_boxplot() +
  labs(
    title = "Recommendation (0–10) by platform",
    x = "Platform",
    y = "Recommend score"
  )
```

# Mini-checklist for students

When you’re stuck, ask:

- Do I have the columns I think I have? (`names(data)`)
- Am I accidentally including missing values? (`drop_na()` or `na.rm = TRUE`)
- Is a categoric column treated as a factor? (`as.factor(...)`)
- Can I reduce the problem by selecting fewer columns?

# Short exercises for mastery

1. Build `clean_df` that contains only `platform`, `session_minutes`, `recommend_0to10`, and has no missing values in those columns.  
2. Add a `session_band` column (short/medium/long).  
3. Produce a summary table of mean recommendation by `session_band`.  
4. Produce a summary table of mean recommendation by `platform` *and* `session_band`.  
5. (Stretch) Find the top 3 platforms (by mean recommendation) with at least 5 participants.  

# Common mistakes (and fixes)

| Mistake | Typical symptom | Fix |
| :- | :- | :- |
| Wrong column name | “object not found” | run `names(data)` and copy/paste |
| Missing values | means become NA | use `na.rm = TRUE` or `drop_na()` |
| Categories treated as text | plots in weird order | use `as.factor()` |
| Too much at once | confusing pipelines | `select()` fewer columns first |

