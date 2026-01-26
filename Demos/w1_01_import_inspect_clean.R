#' @title w1_01_import_inspect_clean.R
#' @description Importing user-test survey data, inspecting structure, cleaning column names, validating basic rules, and saving a cleaned dataset.
#' @author NMCG
#' @bugs None
#' @keywords import, inspect, clean, validate, missing values, factors, user testing
#' @seealso https://r4ds.hadley.nz/data-import.html

# -----------------------------
# Week 1 Demo
# Import + Inspect + Clean (Basics)
# -----------------------------

# Clear the workspace so the script runs the same way every time.
rm(list = ls())

# (Optional) Clear the console for readability when running line-by-line.
cat("\014")

# Load required packages for this demo.
# readr  : fast, friendly CSV import
# dplyr  : data manipulation (select/filter/mutate/summarise)
# tidyr  : reshaping (pivot_longer/pivot_wider)
# janitor: cleaning column names (clean_names)
library(readr)
library(dplyr)
library(tidyr)
library(janitor)

# Define where the dataset lives (relative to your project folder).
# If you move files, update this path in ONE place.
DATA_PATH <- "data/open_world_user_testing_survey_data.csv"

# Define an output folder for files we generate (tables, cleaned data, etc.).
OUT_DIR <- "output"

# Create the output folder if it does not already exist.
dir.create(OUT_DIR, showWarnings = FALSE)

# Import the CSV into a data frame (tibble).
df_raw <- read_csv(DATA_PATH, show_col_types = FALSE)

# Print a quick summary of the imported data.
# This is the fastest way to spot obvious problems (wrong column types, unexpected NA, etc.).
glimpse(df_raw)

# Preview the first 5 rows so we can see typical values.
head(df_raw, 5)

# Clean column names to a consistent style (snake_case).
# This helps avoid mistakes when typing column names later.
df <- df_raw |> clean_names()

# Show the updated column names.
names(df)

# Count missing values in each column (NA counts).
# Missing values are common in user testing (e.g., time is NA when task not completed).
na_counts <- colSums(is.na(df))

# Print missing value counts in a readable format.
na_counts

# Confirm the number of rows (participants).
# We expect one row per tester.
nrow(df)

# Confirm the number of columns (variables).
ncol(df)

# Check basic frequency tables for key categorical variables.
# This helps confirm categories are spelled consistently.
table(df$build)
table(df$experience_band)
table(df$platform)

# Convert certain columns to factors (categorical variables).
# Factors are useful for grouping and plotting with consistent ordering.
df <- df |>
  mutate(
    build = factor(build, levels = c("A", "B")),
    platform = factor(platform),
    experience_band = factor(experience_band, levels = c("beginner", "intermediate", "experienced"), ordered = TRUE)
  )

# Confirm factor levels after conversion.
levels(df$build)
levels(df$experience_band)
levels(df$platform)

# Convert binary completion columns to integers (0/1).
# This ensures that mean(completion) really equals completion proportion.
df <- df |>
  mutate(
    task1_complete = as.integer(task1_complete),
    task2_complete = as.integer(task2_complete),
    task3_complete = as.integer(task3_complete)
  )

# Validate that completion columns contain only 0 or 1 (and no unexpected values).
unique(df$task1_complete)
unique(df$task2_complete)
unique(df$task3_complete)

# Validate basic measurement rules for time-on-task:
# If taskX_complete == 0, then taskX_time_sec should be NA (blank).
# We'll count any violations so we can decide what to do.
viol_task1 <- df |>
  filter(task1_complete == 0 & !is.na(task1_time_sec)) |>
  nrow()

viol_task2 <- df |>
  filter(task2_complete == 0 & !is.na(task2_time_sec)) |>
  nrow()

viol_task3 <- df |>
  filter(task3_complete == 0 & !is.na(task3_time_sec)) |>
  nrow()

# Print validation results.
# Ideally, these should be 0.
viol_task1
viol_task2
viol_task3

# Create a small "data audit" summary table.
# This is useful when you want a quick overview of data health.
audit <- tibble(
  metric = c(
    "participants",
    "missing_any",
    "viol_task1_time_given_incomplete",
    "viol_task2_time_given_incomplete",
    "viol_task3_time_given_incomplete"
  ),
  value = c(
    nrow(df),
    sum(!complete.cases(df)),
    viol_task1,
    viol_task2,
    viol_task3
  )
)

# Print the audit table.
audit

# Save the audit table to CSV for later reference.
write_csv(audit, file.path(OUT_DIR, "w1_audit_summary.csv"))

# Save a cleaned version of the dataset for Week 2 and Week 3 demos.
# We keep raw data unchanged and write cleaned data to output.
write_csv(df, file.path(OUT_DIR, "df_clean_week1.csv"))

# Print a final message so students know what files were created.
message("Week 1 demo complete. Outputs saved to: ", OUT_DIR)
