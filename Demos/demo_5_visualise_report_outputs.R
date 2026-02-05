#' @title demo_5_visualise_report_outputs.R
#' @description Creating clear ggplot2 visualisations for user-test data and exporting plots/tables for use in a Quarto report (QMD).
#' @author NMCG
#' @bugs None
#' @keywords ggplot2, visualisation, histogram, boxplot, bar chart, export, ggsave, reporting
#' @seealso https://ggplot2.tidyverse.org/

# -----------------------------
# Week 3 Demo
# Visualise + Export for Reporting (Quarto-ready)
# -----------------------------

# Clear the workspace for reproducible runs.
rm(list = ls())

# Clear the console for readability.
cat("\014")

# Load required packages.
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# Define input paths (from Week 1 and Week 2 outputs).
DF_PATH <- file.path("output", "df_clean_week1.csv")
TASK_LONG_PATH <- file.path("output", "w2_task_long.csv")

# Define output directory for plots and tables.
OUT_DIR <- "output"

# Create output directory if it does not exist.
dir.create(OUT_DIR, showWarnings = FALSE)

# Load cleaned wide dataset.
df <- read_csv(DF_PATH, show_col_types = FALSE)

# Load tidy long task dataset.
task_long <- read_csv(TASK_LONG_PATH, show_col_types = FALSE)

# Ensure factors have sensible ordering for plots.
df <- df |>
  mutate(
    build = factor(build, levels = c("A", "B")),
    experience_band = factor(experience_band, levels = c("beginner", "intermediate", "experienced"), ordered = TRUE)
  )

# Ensure task is ordered for plotting.
task_long <- task_long |>
  mutate(
    task = factor(task, levels = c("task1", "task2", "task3"), ordered = TRUE),
    build = factor(build, levels = c("A", "B")),
    experience_band = factor(experience_band, levels = c("beginner", "intermediate", "experienced"), ordered = TRUE)
  )

# -----------------------------
# Plot 1: Completion proportion by task
# -----------------------------

# Compute completion proportions using the tidy long table.
completion_by_task <- task_long |>
  group_by(task) |>
  summarise(
    completion_proportion = mean(complete, na.rm = TRUE),
    .groups = "drop"
  )

# Build a bar chart for completion proportion by task.
p1 <- ggplot(completion_by_task, aes(x = task, y = completion_proportion)) +
  geom_col() +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    title = "Completion proportion by task",
    x = "Task",
    y = "Completion proportion (0–1)"
  )

# Display the plot in the viewer.
p1

# Save the plot for reporting.
ggsave(
  filename = file.path(OUT_DIR, "plot_completion_by_task.png"),
  plot = p1,
  width = 8,
  height = 4.5,
  dpi = 150
)

# -----------------------------
# Plot 2: Completion proportion by build (Task 2)
# -----------------------------

# Compute Task 2 completion by build.
task2_completion_by_build <- task_long |>
  filter(task == "task2") |>
  group_by(build) |>
  summarise(
    completion_proportion = mean(complete, na.rm = TRUE),
    .groups = "drop"
  )

# Build grouped bar chart (here it's just one bar per build).
p2 <- ggplot(task2_completion_by_build, aes(x = build, y = completion_proportion)) +
  geom_col() +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    title = "Task 2 completion proportion by build",
    x = "Build",
    y = "Completion proportion (0–1)"
  )

# Display the plot.
p2

# Save the plot for reporting.
ggsave(
  filename = file.path(OUT_DIR, "plot_task2_completion_by_build.png"),
  plot = p2,
  width = 6.5,
  height = 4.5,
  dpi = 150
)

# -----------------------------
# Plot 3: Time-on-task distribution by build (Task 2, completed only)
# -----------------------------

# Filter to Task 2 completed attempts only.
task2_times <- task_long |>
  filter(task == "task2", complete == 1)

# Create a boxplot of Task 2 time-on-task by build.
p3 <- ggplot(task2_times, aes(x = build, y = time_sec)) +
  geom_boxplot() +
  labs(
    title = "Task 2 time-on-task by build (completed only)",
    x = "Build",
    y = "Time-on-task (seconds)"
  )

# Display the plot.
p3

# Save the plot for reporting.
ggsave(
  filename = file.path(OUT_DIR, "plot_task2_time_by_build_boxplot.png"),
  plot = p3,
  width = 6.5,
  height = 4.5,
  dpi = 150
)

# -----------------------------
# Plot 4: Likert-style ordinal ratings (UI clarity)
# -----------------------------

# Build a histogram for UI clarity ratings (1–7), using binwidth 1.
p4 <- ggplot(df, aes(x = ui_clarity_1to7)) +
  geom_histogram(binwidth = 1) +
  labs(
    title = "UI clarity rating distribution (1–7)",
    x = "UI clarity rating (1–7)",
    y = "Count"
  )

# Display the plot.
p4

# Save the plot.
ggsave(
  filename = file.path(OUT_DIR, "plot_ui_clarity_hist.png"),
  plot = p4,
  width = 7.5,
  height = 4.5,
  dpi = 150
)

# -----------------------------
# Export a compact summary table for Quarto
# -----------------------------

# Create a summary table that could be embedded in a report.
report_summary <- df |>
  summarise(
    n_participants = n(),
    task2_completion_proportion = mean(task2_complete, na.rm = TRUE),
    task2_median_time_sec_completed = median(task2_time_sec[task2_complete == 1], na.rm = TRUE),
    task2_iqr_time_sec_completed = IQR(task2_time_sec[task2_complete == 1], na.rm = TRUE),
    ui_clarity_median = median(ui_clarity_1to7, na.rm = TRUE),
    ui_clarity_iqr = IQR(ui_clarity_1to7, na.rm = TRUE),
    frustration_median = median(frustration_1to7, na.rm = TRUE),
    frustration_iqr = IQR(frustration_1to7, na.rm = TRUE)
  )

# Print the report summary.
report_summary

# Save the report summary as CSV so Quarto can read it easily.
write_csv(report_summary, file.path(OUT_DIR, "report_summary_week3.csv"))

# Final message confirming outputs.
message("Week 3 demo complete. Plots and tables saved to: ", OUT_DIR)
