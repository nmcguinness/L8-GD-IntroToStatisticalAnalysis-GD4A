#' @title w2_01_tidy_summarise_compare.R
#' @description Reshaping user-test data to tidy (long) format, computing descriptive statistics, and comparing groups (Build A vs Build B; experience bands).
#' @author NMCG
#' @bugs None
#' @keywords tidy data, pivot_longer, summarise, proportions, median, IQR, group comparison, segmentation
#' @seealso https://r4ds.hadley.nz/data-tidy.html

# -----------------------------
# Week 2 Demo
# Tidy Transform + Descriptive Stats + Comparisons
# -----------------------------

# Clear the workspace for reproducible runs.
rm(list = ls())

# Clear the console for readability.
cat("\014")

# Load required packages.
library(readr)
library(dplyr)
library(tidyr)
library(janitor)

# Define paths.
# We use the cleaned dataset produced in Week 1 (in output/).
IN_PATH <- file.path("output", "df_clean_week1.csv")

# Define output directory.
OUT_DIR <- "output"

# Create output directory if it does not exist.
dir.create(OUT_DIR, showWarnings = FALSE)

# Load the cleaned dataset.
df <- read_csv(IN_PATH, show_col_types = FALSE)

# Confirm structure.
glimpse(df)

# Ensure factors are correctly set (in case someone edited the CSV).
df <- df |>
  mutate(
    build = factor(build, levels = c("A", "B")),
    platform = factor(platform),
    experience_band = factor(experience_band, levels = c("beginner", "intermediate", "experienced"), ordered = TRUE)
  )

# -----------------------------
# Part A: Completion proportions by task (wide → summary)
# -----------------------------

# Compute completion proportions for each task across all participants.
# The mean of a 0/1 column equals the proportion of 1s.
completion_overall <- df |>
  summarise(
    task1_completion_proportion = mean(task1_complete, na.rm = TRUE),
    task2_completion_proportion = mean(task2_complete, na.rm = TRUE),
    task3_completion_proportion = mean(task3_complete, na.rm = TRUE)
  )

# Print completion proportions.
completion_overall

# Reshape to a longer table for nicer printing and plotting later.
completion_overall_long <- completion_overall |>
  pivot_longer(
    cols = everything(),
    names_to = "task",
    values_to = "completion_proportion"
  ) |>
  mutate(
    task = gsub("_completion_proportion", "", task)
  )

# Print the long-form table.
completion_overall_long

# Save completion table.
write_csv(completion_overall_long, file.path(OUT_DIR, "w2_completion_overall.csv"))

# -----------------------------
# Part B: Create tidy long format for task completion + time-on-task
# -----------------------------

# Select completion columns and pivot to long format.
comp_long <- df |>
  select(respondent_id, build, experience_band, platform, starts_with("task"), ends_with("_complete")) |>
  pivot_longer(
    cols = ends_with("_complete"),
    names_to = "task",
    values_to = "complete"
  ) |>
  mutate(
    task = gsub("_complete", "", task)
  )

# Select time columns and pivot to long format.
time_long <- df |>
  select(respondent_id, starts_with("task"), ends_with("_time_sec")) |>
  pivot_longer(
    cols = ends_with("_time_sec"),
    names_to = "task",
    values_to = "time_sec"
  ) |>
  mutate(
    task = gsub("_time_sec", "", task)
  )

# Join completion and time on respondent_id + task.
task_long <- comp_long |>
  left_join(time_long, by = c("respondent_id", "task"))

# Convert task to an ordered factor so outputs appear in a stable order.
task_long <- task_long |>
  mutate(
    task = factor(task, levels = c("task1", "task2", "task3"), ordered = TRUE)
  )

# Inspect tidy task table.
glimpse(task_long)
head(task_long, 8)

# Save tidy long table for reuse in Week 3 plots.
write_csv(task_long, file.path(OUT_DIR, "w2_task_long.csv"))

# -----------------------------
# Part C: Time-on-task summaries (completed attempts only)
# -----------------------------

# Filter to completed attempts only (because time is meaningful only if completed).
task_time_summary <- task_long |>
  filter(complete == 1) |>
  group_by(task) |>
  summarise(
    n_completed = n(),
    median_time_sec = median(time_sec, na.rm = TRUE),
    iqr_time_sec = IQR(time_sec, na.rm = TRUE),
    .groups = "drop"
  )

# Print time summaries.
task_time_summary

# Save time summary.
write_csv(task_time_summary, file.path(OUT_DIR, "w2_task_time_summary.csv"))

# -----------------------------
# Part D: Compare builds for Task 2 (example analysis question)
# -----------------------------

# Compute Task 2 completion proportion by build.
task2_by_build <- df |>
  group_by(build) |>
  summarise(
    task2_completion_proportion = mean(task2_complete, na.rm = TRUE),
    .groups = "drop"
  )

# Print build comparison for completion.
task2_by_build

# Compute percentage-point difference (Build B minus Build A).
# Convert to percentages for readability in reporting.
task2_pp_diff <- (task2_by_build$task2_completion_proportion[task2_by_build$build == "B"] -
                  task2_by_build$task2_completion_proportion[task2_by_build$build == "A"]) * 100

# Print the percentage-point difference.
task2_pp_diff

# Compute median time-on-task for Task 2, completed only, by build.
task2_time_by_build <- task_long |>
  filter(task == "task2", complete == 1) |>
  group_by(build) |>
  summarise(
    n_completed = n(),
    median_time_sec = median(time_sec, na.rm = TRUE),
    iqr_time_sec = IQR(time_sec, na.rm = TRUE),
    .groups = "drop"
  )

# Print median time comparisons.
task2_time_by_build

# Save Task 2 comparison tables.
write_csv(task2_by_build, file.path(OUT_DIR, "w2_task2_completion_by_build.csv"))
write_csv(task2_time_by_build, file.path(OUT_DIR, "w2_task2_time_by_build.csv"))

# -----------------------------
# Part E: Segmentation by experience band (Task 2 example)
# -----------------------------

# Completion proportion of Task 2 by experience band.
task2_by_experience <- df |>
  group_by(experience_band) |>
  summarise(
    task2_completion_proportion = mean(task2_complete, na.rm = TRUE),
    .groups = "drop"
  )

# Print segmentation results.
task2_by_experience

# Median time-on-task for Task 2 by experience band (completed only).
task2_time_by_experience <- task_long |>
  filter(task == "task2", complete == 1) |>
  group_by(experience_band) |>
  summarise(
    n_completed = n(),
    median_time_sec = median(time_sec, na.rm = TRUE),
    iqr_time_sec = IQR(time_sec, na.rm = TRUE),
    .groups = "drop"
  )

# Print time segmentation results.
task2_time_by_experience

# Save segmentation tables.
write_csv(task2_by_experience, file.path(OUT_DIR, "w2_task2_completion_by_experience.csv"))
write_csv(task2_time_by_experience, file.path(OUT_DIR, "w2_task2_time_by_experience.csv"))

# Print a final message to confirm outputs.
message("Week 2 demo complete. Tables saved to: ", OUT_DIR)
