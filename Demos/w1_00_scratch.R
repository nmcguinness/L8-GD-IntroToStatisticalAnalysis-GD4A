#' @title w1_00_scratch.R
#' @description A scratchpad introducing core R concepts (data types, control flow, functions, packages, vectors, data frames) and basic plotting for game user-test analysis.
#' @author NMCG
#' @bugs None
#' @keywords data types, conditionals, loops, functions, packages, vectors, data frames, str, head, summary, stripchart, hist, boxplot
#' @seealso https://www.w3schools.com/r/default.asp
#' @seealso https://r4ds.hadley.nz/

# Dont forget to set your working directory to the project root folder! Otherwise, file paths may not work. Do this by selecting Session > Set Working Directory > To Project Directory in RStudio.

# Clear workspace and console
rm(list = ls(all.names = TRUE))

 # Clear console
cat("\014")

# ---------------------------------------------
# Week 1: Quick CSV read + first inspection
# ---------------------------------------------

# Tip: Keep variable names consistent. In R, snake_case is common for variables.
# Tip: read.csv() returns a data.frame; readr::read_csv() returns a tibble and is often nicer.
# Tip: Use a relative path so your code works on other machines (project folder structure matters).

survey_data <- read.csv("data/open_world_user_testing_survey_data.csv")

# Tip: Use cat()/message() for readable console output (print() is fine, but a bit clunky for headings).
cat("\n--- Summary ---\n")
summary(survey_data)

cat("\n--- Head (first 5 rows) ---\n")
head(survey_data, 5)

cat("\n--- Tail (last 2 rows) ---\n")
tail(survey_data, 2)

# ---------------------------------------------
# Descriptive statistics (single-variable)
# ---------------------------------------------

# Tip: For a 0–10 recommendation rating, median is a robust "typical value".
# Tip: Add na.rm = TRUE if the column might contain missing values (NA).
median_like <- median(survey_data$recommend_0to10, na.rm = TRUE)

cat("\nThe median recommendation value is:", median_like, "\n")

# ---------------------------------------------
# Proportions for binary variables (0/1)
# ---------------------------------------------

# Tip: If task1_complete is coded as 0/1, then mean(task1_complete) = completion proportion.
# Tip: ave() is NOT the right function here (ave computes group-wise averages).
task1_completion_proportion <- mean(survey_data$task1_complete, na.rm = TRUE)

cat("Task 1 completion proportion:", task1_completion_proportion, "\n")

# ---------------------------------------------
# Basic plots (base R)
# ---------------------------------------------

# Tip: Before plotting time-on-task, decide whether to include only completed attempts.
# Example: only completed attempts
task1_times_completed <- survey_data$task1_time_sec[survey_data$task1_complete == 1]

# Tip: Avoid hard-coded xlim until you’ve inspected the data range; otherwise you can hide values.
# Tip: Use meaningful titles and axis labels (with units).
hist(
  task1_times_completed,
  main = "Task 1 time-on-task distribution (completed only)",
  breaks = 8,
  xlab = "Time-on-task (seconds)",
  ylab = "Count"
)

# Tip: Stripcharts show individual points and are nice for small datasets.
stripchart(survey_data$navigation_1to7, method = "jitter", main = "Navigation rating (1–7)")

# ---------------------------------------------
# Using an inbuilt dataset for plotting practice (chickwts)
# ---------------------------------------------

# Tip: Inbuilt datasets are great for learning plot types without file import.
data(chickwts)

# Stripchart of weights (quick view of individual observations)
stripchart(
  chickwts$weight,
  method = "jitter",
  main = "Chick weights (stripchart)",
  xlab = "Weight"
)

# Boxplot by group (feed type)
boxplot(
  weight ~ feed,
  data = chickwts,
  las = 2,
  main = "Chick weights by feed type (boxplot)",
  xlab = "Feed type",
  ylab = "Weight"
)

# ---------------------------------------------
# Improved base R boxplot using built-in options
# ---------------------------------------------

data(chickwts)

boxplot(
  weight ~ feed,
  data = chickwts,

  # Labels / title
  main = "Chick weights by feed type",
  xlab = "Feed type",
  ylab = "Weight (g)",

  # Axis readability
  las = 2,                 # rotate x labels (better for long names)
  cex.axis = 0.9,          # slightly smaller axis text
  cex.lab = 1.1,           # bigger axis labels
  cex.main = 1.2,          # bigger title

  # Box appearance
  #notch = TRUE,            # notches give a visual cue for median differences
  #varwidth = TRUE,         # box widths reflect sample size per group
  border = "gray25",       # box border colour
  col = "gray90",          # box fill (kept neutral)

  # Limits / layout
  ylim = range(chickwts$weight) * c(0.95, 1.05)  # a bit of headroom
)

# Add a light horizontal grid for easier reading (base R helper)
grid(nx = NA, ny = NULL, lty = 3, col = "gray85")





