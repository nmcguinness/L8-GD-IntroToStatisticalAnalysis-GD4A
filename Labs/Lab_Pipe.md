---
title: "Playtesting Analytics — Exercises: Using the Base Pipe Operator (|>)"
subtitle: "Y4 Collaborative Project — Easier pipelines using your own functions"
description: "Beginner-friendly practice with R’s built-in pipe operator (|>) using simple user-defined functions (no dplyr verbs yet). Solutions included in collapsible sections."
tags: [r, pipe, base-r, functions, playtesting, exercises, year4]
---

# Overview

These exercises focus on the **built-in pipe operator**:

```r
|>
```

You will practice writing readable pipelines using **simple user-defined functions** (provided in the Appendix).

# Setup

## Step 1: Copy the Appendix functions into your R script

- Scroll to the **Appendix** at the bottom of this file.
- Copy all functions into an R script (e.g. `pipe_helpers.R`) and run them.

## Step 2: Load the class dataset (optional but recommended)

If you have the CSV available:

```r
library(janitor)

csv_file <- "data/open_world_user_testing_survey_data.csv"

if (!file.exists(csv_file))
  stop("CSV file not found: ", csv_file)

raw <- readr::read_csv(csv_file, show_col_types = FALSE)
data <- raw |> janitor::clean_names()

head(data, 3)
```

If you don’t have the CSV, you can still do Exercises 01–04 using the mini datasets provided.

---

# Exercises — Vectors with |> (base R)

## Exercise 01 — Pipe into summary functions

Create a numeric vector `scores` with at least 8 values and one `NA`.  
Using `|>`, compute:

- mean with `na.rm = TRUE`
- median with `na.rm = TRUE`

<details>
<summary>Solution</summary>

```r
scores <- c(6, 7, 9, 8, 10, 4, 7, NA)

scores |> mean(na.rm = TRUE)
scores |> median(na.rm = TRUE)
```

</details>

Write 1 sentence:
- Why is `na.rm = TRUE` important for survey-style data?

## Exercise 02 — Pipe into a user-defined cleaning function

Create a vector `times_sec` with 10 values and one `NA`.

Use the user-defined function `drop_na_vec()` in a pipeline to:

1. remove NA
2. compute the mean

<details>
<summary>Solution</summary>

```r
times_sec <- c(320, 415, 280, NA, 390, 450, 610, 305, 470, 360)

times_sec |>
  drop_na_vec() |>
  mean()
```

</details>

Write 1–2 sentences:
- What is the benefit of naming “remove NA” as its own function?

## Exercise 03 — Pipe into sort then head

Create a character vector `levels` with 8 level names.  
Pipe it into `sort()` then into `head()` to show the first 3 alphabetically.

<details>
<summary>Solution</summary>

```r
levels <- c("Grassy Plains", "Dark Dungeon", "Sky Castle", "Misty Mountains",
            "Arid Desert", "Icy Tundra", "Volcanic Island", "Final Fortress")

levels |>
  sort() |>
  head(3)
```

</details>

Write 1 sentence:
- Why can sorting be useful before presenting results in a report?

## Exercise 04 — A tiny “pipeline” on a vector of text

Create a character vector `comments` with 6 short sentences.  
Use the user-defined function `squish_text_vec()` to:

1. remove extra spacing
2. convert to lower-case (use `tolower()`)

<details>
<summary>Solution</summary>

```r
comments <- c(
  "   UI  text  is too small  ",
  "Camera   feels    slow",
  "I   got stuck   near a wall",
  "Combat is fun   ",
  "Tutorial   unclear",
  "  Great atmosphere  "
)

comments |>
  squish_text_vec() |>
  tolower()
```

</details>

Write 1–2 sentences:
- Why should free-text be cleaned before you try to analyse it?

---

# Exercises — Data frames with |> (using your functions)

If you don’t have a data CSV, use this small practice dataset:

```r
mini <- data.frame(
  player_id = c("P01","P02","P03","P04","P05","P06"),
  platform = c("PC","PC","Console","Console","PC","Console"),
  session_minutes = c(35, 12, 58, NA, 45, 9),
  frustration_1to7 = c(2, 6, 5, 7, NA, 6),
  recommend_0to10 = c(9, 5, 7, 3, 8, NA),
  free_text = c(
    " UI text too small ",
    " camera slow ",
    "combat fun",
    "got stuck near wall",
    NA,
    "tutorial unclear"
  )
)
```

## Exercise 05 — Keep only the columns you need (keep_cols)

Using `mini` (or `data`), create `core_df` that keeps only:

- `platform`, `frustration_1to7`, `recommend_0to10`

Use the user-defined function `keep_cols()` in a pipeline.

<details>
<summary>Solution</summary>

```r
core_df <- mini |>
  keep_cols(c("platform", "frustration_1to7", "recommend_0to10"))

core_df
```

</details>

Write 1–2 sentences:
- Why is it helpful to “shrink” your data frame before analysis?

## Exercise 06 — Drop rows with missing values for specific columns (drop_na_df)

Using `core_df`, remove rows where either:

- `frustration_1to7` is missing, or
- `recommend_0to10` is missing

Use the user-defined function `drop_na_df()`.

<details>
<summary>Solution</summary>

```r
clean_df <- core_df |>
  drop_na_df(c("frustration_1to7", "recommend_0to10"))

clean_df
```

</details>

Write 2 sentences:
- Why do we drop missing rows **only** for the columns used in this question?

## Exercise 07 — Add a new column using a rule (add_flag)

Using `clean_df`, add a column called `high_frustration`:

- TRUE if `frustration_1to7 >= 6`
- FALSE otherwise

Use the user-defined function `add_flag()`.

<details>
<summary>Solution</summary>

```r
flag_df <- clean_df |>
  add_flag(
    new_col = "high_frustration",
    source_col = "frustration_1to7",
    predicate = function(x) x >= 6
  )

flag_df
```

</details>

Write 1–2 sentences:
- What kind of reporting question becomes easier once you have `high_frustration`?

## Exercise 08 — Produce a simple summary table by group (group_mean)

Using `flag_df`, create a small summary table:

- group by `high_frustration`
- compute mean of `recommend_0to10`
- include a count (`n`) per group

Use the user-defined function `group_mean()`.

<details>
<summary>Solution</summary>

```r
summary_tbl <- flag_df |>
  group_mean(group_col = "high_frustration", value_col = "recommend_0to10")

summary_tbl
```

</details>

Write 3–4 sentences (What → Pattern → Meaning → Action):
- What does the table summarise?
- What pattern do you see?
- What design meaning might that have?
- What is one action the team could take?

## Exercise 09 — Clean free-text into a “comment table” (keep_cols + drop_na_df + squish_text_col)

Using `mini` (or `data`), build `comment_df` that:

1. keeps `player_id` and `free_text`
2. drops rows where `free_text` is missing
3. squishes whitespace in `free_text`

Use `|>` with the user-defined functions.

<details>
<summary>Solution</summary>

```r
comment_df <- mini |>
  keep_cols(c("player_id", "free_text")) |>
  drop_na_df(c("free_text")) |>
  squish_text_col("free_text")

comment_df
```

</details>

Write 2–3 sentences:
- Why is it a good idea to keep free-text in its own small table?
- What would you do next to turn this into “themes” for a report?

---

# Appendix — User-defined functions for this sheet

Copy all of the functions below into an R script and run them **before** attempting the exercises.

<details>
<summary>Show Appendix functions</summary>

```r
# Remove NA from a vector (returns a vector)
drop_na_vec <- function(x) {
  x[!is.na(x)]
}

# Trim and compress whitespace in each string (returns a character vector)
# Example: "  UI   too  small " -> "UI too small"
squish_text_vec <- function(x) {
  x <- as.character(x)
  x <- gsub("\\s+", " ", x)   # replace repeated whitespace with a single space
  x <- trimws(x)               # remove leading/trailing spaces
  x
}

# Keep only certain columns in a data frame (returns a data frame)
keep_cols <- function(df, cols) {
  if (!all(cols %in% names(df)))
    stop("Missing columns: ", paste(setdiff(cols, names(df)), collapse = ", "))

  df[, cols, drop = FALSE]
}

# Drop rows that have NA in any of the chosen columns (returns a data frame)
drop_na_df <- function(df, cols) {
  if (!all(cols %in% names(df)))
    stop("Missing columns: ", paste(setdiff(cols, names(df)), collapse = ", "))

  keep <- complete.cases(df[, cols, drop = FALSE])
  df[keep, , drop = FALSE]
}

# Add a TRUE/FALSE flag column based on a rule applied to a source column
# predicate must be a function that takes a vector and returns TRUE/FALSE per element
add_flag <- function(df, new_col, source_col, predicate) {
  if (!(source_col %in% names(df)))
    stop("Missing source_col: ", source_col)

  df[[new_col]] <- predicate(df[[source_col]])
  df
}

# Squish a single text column inside a data frame (returns a data frame)
squish_text_col <- function(df, col) {
  if (!(col %in% names(df)))
    stop("Missing text column: ", col)

  df[[col]] <- squish_text_vec(df[[col]])
  df
}

# Grouped mean summary table (base R) with count
# Returns a data frame with: group, n, mean
group_mean <- function(df, group_col, value_col) {
  if (!(group_col %in% names(df)))
    stop("Missing group_col: ", group_col)
  if (!(value_col %in% names(df)))
    stop("Missing value_col: ", value_col)

  g <- df[[group_col]]
  v <- df[[value_col]]

  # Drop NA in the value column for the summary
  ok <- !is.na(g) & !is.na(v)
  g <- g[ok]
  v <- v[ok]

  n_by_group <- tapply(v, g, length)
  mean_by_group <- tapply(v, g, mean)

  out <- data.frame(
    group = names(mean_by_group),
    n = as.integer(n_by_group[names(mean_by_group)]),
    mean_value = as.numeric(mean_by_group),
    row.names = NULL
  )

  out
}
```

</details>
