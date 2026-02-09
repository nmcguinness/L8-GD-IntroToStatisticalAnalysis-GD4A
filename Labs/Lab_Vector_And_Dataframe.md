---
title: "Playtesting Analytics — Lab: Vectors & Data Frames"
subtitle: "Y4 Collaborative Project — R Foundations for Report Generation"
description: "Hands-on practice with vectors and data frames (tibbles): creating, indexing, filtering, summarising, and preparing playtesting-style data for analysis."
authors: ["3DGD / GD4 Teaching Team"]
tags: [r, vectors, dataframes, tibbles, indexing, subsetting, playtesting, year4]
---

# Overview

Most playtesting analysis is built from two things:

- a **vector** (one column of values: times, scores, ratings, names)
- a **data frame** (a table: many columns, many rows)

In this lab you will:

- create and work with vectors (numeric, character, logical)
- create and work with a data frame (columns + rows)
- load a CSV dataset and perform simple inspection and subsetting

# Learning outcomes

By the end you can:

- create vectors with `c()`, `:`, `seq()`, `rep()`
- index vectors with `[]` using positions, ranges, and logical filters
- compute basic vector statistics (`mean`, `median`, `sd`, `min/max`)
- create a data frame, access rows/columns, add/remove columns
- subset a data frame by rows and columns using base R indexing

# Ground rules

- Write short code, run it, check the result.
- If something goes wrong, print intermediate values (e.g., `head()`, `length()`, `names()`).
- When you see `NA`, stop and decide: is it expected, or does it mean missing data?

# How to run

1. Open this `.md` file in RStudio.
2. Copy code blocks into an R script (recommended), or run line-by-line in the Console.
3. After each exercise, confirm you get the expected type/shape (vector length, data frame dimensions).

# Setup

```r
library(tidyverse)  # optional in this lab, but handy for tibble() later
```

---

# Vectors — Exercises

A vector is a single sequence of values of one main type (numeric, character, logical).

## Exercise 01 — Create numeric and character vectors

Create:

- `times_sec` with 10 session times (in seconds)
- `player_ids` with 10 player IDs (like "P01", "P02", ...)

Then print both and check `length()`.

<details>
<summary>Solution</summary>

```r
times_sec <- c(320, 415, 280, 510, 390, 450, 610, 305, 470, 360)

player_ids <- c("P01","P02","P03","P04","P05","P06","P07","P08","P09","P10")

times_sec
player_ids

length(times_sec)
length(player_ids)
```

</details>

Write 1–2 sentences:
- Why must both vectors have the same length if you want to combine them into a table?

## Exercise 02 — Indexing: pick specific elements and ranges

Using `times_sec`:

- get the 1st value
- get values 3 to 6
- get the last value (hint: `length(times_sec)`)

<details>
<summary>Solution</summary>

```r
times_sec[1]
times_sec[3:6]
times_sec[length(times_sec)]
```

</details>

Write 1 sentence:
- What is the biggest indexing difference between R and C#/Java?

## Exercise 03 — Vectorised operations

Create `times_plus_bonus` where each time has 15 seconds added.

Then create `times_minutes` converting seconds to minutes.

<details>
<summary>Solution</summary>

```r
times_plus_bonus <- times_sec + 15
times_plus_bonus

times_minutes <- times_sec / 60
times_minutes
```

</details>

Write 1–2 sentences:
- What does “vectorised” mean in R?

## Exercise 04 — Logical filtering

Create a logical vector `fast_run` which is TRUE when `times_sec < 360`.

Then use it to list the *player IDs* who were fast.

<details>
<summary>Solution</summary>

```r
fast_run <- times_sec < 360
fast_run

fast_players <- player_ids[fast_run]
fast_players
```

</details>

Write 2 sentences:
- What question about your game does `fast_run` help you answer?
- What would be a sensible follow-up metric to check?

## Exercise 05 — Basic summary stats

Compute:

- mean time, median time
- min and max time
- standard deviation

<details>
<summary>Solution</summary>

```r
mean(times_sec)
median(times_sec)

min(times_sec)
max(times_sec)

sd(times_sec)
```

</details>

Write 2–3 sentences:
- If mean and median are very different, what might that suggest about the distribution?

## Exercise 06 — Missing values in vectors

Create a new vector `times_with_na` by adding an `NA` into your times.

Compute the mean twice:

- once without handling missing values
- once using `na.rm = TRUE`

<details>
<summary>Solution</summary>

```r
times_with_na <- c(times_sec[1:4], NA, times_sec[5:10])
times_with_na

mean(times_with_na)                 # returns NA
mean(times_with_na, na.rm = TRUE)   # ignores NA
```

</details>

Write 1–2 sentences:
- Why is it dangerous to ignore `NA` without thinking?

---

# Data frames — Exercises

A data frame is a table where each column is usually a vector.

## Exercise 07 — Create a data frame from vectors

Create a data frame called `session_df` with columns:

- `player_id`
- `time_sec`
- `completed` (TRUE/FALSE)

Use 10 rows.

<details>
<summary>Solution</summary>

```r
completed <- c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE)

session_df <- data.frame(
  player_id = player_ids,
  time_sec = times_sec,
  completed = completed
)

session_df
```

</details>

Write 1–2 sentences:
- What does one row represent in this table?

## Exercise 08 — Inspect and access rows/columns

Using `session_df`:

- print the column names
- print the first 3 rows
- print the `time_sec` column in two different ways (`$` and `[[]]`)

<details>
<summary>Solution</summary>

```r
names(session_df)

session_df[1:3, ]

session_df$time_sec
session_df[["time_sec"]]
```

</details>

Write 1 sentence:
- When is `[["colname"]]` more useful than `$colname`?

## Exercise 09 — Add a derived column

Add a new column `time_min` (minutes) and a new column `speed_band`:

- "Fast" if `time_sec < 360`
- "Medium" if `time_sec < 480`
- "Slow" otherwise

<details>
<summary>Solution</summary>

```r
session_df$time_min <- session_df$time_sec / 60

session_df$speed_band <- ifelse(
  session_df$time_sec < 360, "Fast",
  ifelse(session_df$time_sec < 480, "Medium", "Slow")
)

session_df
```

</details>

Write 2 sentences:
- Why are derived columns useful for plotting and summarising?

## Exercise 10 — Filter rows (base R indexing)

Create `completed_df` that contains only rows where `completed == TRUE`.

Then report how many rows remain.

<details>
<summary>Solution</summary>

```r
completed_df <- session_df[session_df$completed == TRUE, ]
completed_df

nrow(completed_df)
```

</details>

Write 1–2 sentences:
- Why might you analyse completed sessions separately?

## Exercise 11 — Sort the data frame

Sort `session_df` by `time_sec` ascending (fastest first). Save it as `sorted_df`.

<details>
<summary>Solution</summary>

```r
sorted_df <- session_df[order(session_df$time_sec), ]
sorted_df
```

</details>

Write 1 sentence:
- What is `order()` returning, conceptually?

## Exercise 12 — Load and inspect the real playtesting CSV

Load the dataset:

- `data/open_world_user_testing_survey_data.csv`

Then:

- print the first 5 rows
- print the number of rows and columns
- list the column names

<details>
<summary>Solution</summary>

```r
library(janitor)

csv_file <- "data/open_world_user_testing_survey_data.csv"

if (!file.exists(csv_file))
  stop("CSV file not found: ", csv_file)

raw <- readr::read_csv(csv_file, show_col_types = FALSE)
data <- raw %>% janitor::clean_names()

head(data, 5)
nrow(data)
ncol(data)
names(data)
```

</details>

Write 2–3 sentences:
- What does one row represent in this dataset?
- Identify one categoric column, one numeric column, and one free-text column.

---
