#' @title w1_00_scratch_restructured.R
#' @description Scratchpad introducing core R concepts (data types, printing, operators, collections, control flow, functions, packages, data frames) and basic plotting for gameplay playtest analysis.
#' @author NMCG
#' @bugs None
#' @keywords data types, print, paste, cat, operators, vectors, lists, data frames, factors, conditionals, loops, functions, packages, str, head, summary, aggregate, stripchart, boxplot, hist, density, ecdf
#' @seealso https://www.w3schools.com/r/default.asp
#' @seealso https://r4ds.hadley.nz/

# -----------------------------
# Week 1 Scratch Demo (restructured)
# Goal: get comfortable with basic R code before touching the real dataset.
# Theme: simple gameplay playtesting examples (fake data).
# -----------------------------

# Clear the workspace so the script runs the same way every time.
rm(list = ls())

# Clear the console for readability.
cat("\014")

# -----------------------------
# 1) Core data types in R
# -----------------------------

# Numeric (double) values are used for measurements (e.g., time in seconds).
time_sec <- 245.5

# Integer values are whole numbers (e.g., number of deaths).
deaths <- 3L

# Logical values are TRUE/FALSE (e.g., task completion).
task_complete <- TRUE

# Character strings are text labels (e.g., build label "A" or "B").
build <- "A"

time_sec
deaths
task_complete
build

# -----------------------------
# 2) Printing and formatting output (so we can "see" what code is doing)
# -----------------------------

module <- "3DGD"
initials <- "NMCG"

print(module)                                                # Print a value (often used inside loops)
print(paste("Module:", module, "| Lecturer:", initials))      # Combine text + values into one string

paste("Participant:", "R01", "| Build:", "A", sep = " ")      # sep controls spacing
cat("Line1\nLine2\n")                                      # cat prints without quotes and handles \n nicely

# -----------------------------
# 3) Operators, comparisons, and simple type checks
# -----------------------------

# Arithmetic operators.
10 + 5
10 - 5
10 * 5
10 / 5
2 ^ 4

# Comparison operators (result is TRUE/FALSE).
time_sec < 300
time_sec >= 300
build == "A"
build != "B"

# Logical operators.
(time_sec < 300) & task_complete                              # AND
(time_sec < 300) | (deaths > 0)                               # OR
!(deaths == 0L)                                                # NOT

# Type checks (useful when debugging).
is.numeric(time_sec)
is.integer(deaths)
is.logical(task_complete)
is.character(build)

# Coercion (converting types).
as.integer(time_sec)
as.numeric("123.4")

# -----------------------------
# 4) Vectors (1D collection, usually one type)
# Example: one player's completion times across multiple test runs
# -----------------------------

p101_times_sec <- c(312, 290, 275, NA, 268)                   # NA = missing / aborted run

p101_times_sec
length(p101_times_sec)                                        # Number of runs
p101_times_sec[1]                                             # First run time (R is 1-based)
p101_times_sec[c(1, 3, 5)]                                    # Multiple positions
p101_times_sec[p101_times_sec < 280]                          # Filter (logical indexing)

mean(p101_times_sec, na.rm = TRUE)                            # na.rm ignores missing values
min(p101_times_sec, na.rm = TRUE)                             # Best time (fastest)

# -----------------------------
# 5) Lists (heterogeneous collection; can be nested)
# Example: one playtest session record (like a simple object / JSON)
# -----------------------------

session_p101 <- list(
  player_id = "P101",                                         # Identifier (character)
  build = "0.3.1",                                             # Game build string
  device = "PC",                                               # Platform/device string
  difficulty = "Normal",                                       # Condition label
  run_times_sec = p101_times_sec,                              # Vector stored inside the list
  deaths_per_run = c(6, 4, 3, 0, 2),                            # Another vector (same length)
  notes = list(                                                # Nested list for metadata
    enjoyment_rating = 7,
    main_issue = "Camera feels too floaty"
  )
)

session_p101
names(session_p101)                                           # Field names

session_p101$device                                           # $ gets a named element
session_p101[1]                                               # [ ] returns a sub-list (still a list)
session_p101[[1]]                                             # [[ ]] extracts the actual element

mean(session_p101$run_times_sec, na.rm = TRUE)                # Compute from a vector inside the list
str(session_p101)                                             # Inspect nested structure

# -----------------------------
# 6) Data frames (table-like; columns are vectors of equal length)
# One row = one run by one player (from first principles)
# -----------------------------

player_id <- c("P101", "P101", "P101", "P102", "P102", "P103") # Categorical identifier
run       <- c(1,     2,     3,     1,     2,     1)           # Run index (integer-ish)
time_sec  <- c(312,   290,   275,   420,   395,   520)         # Completion time (numeric)
deaths    <- c(6,     4,     3,     10,    8,     14)          # Death count (integer-ish)
device    <- c("PC",  "PC",  "PC",  "SteamDeck", "SteamDeck", "PC")

runs_df <- data.frame(
  player_id = player_id,
  run = run,
  time_sec = time_sec,
  deaths = deaths,
  device = device
)

runs_df
str(runs_df)
head(runs_df, 3)

runs_df$time_sec                                              # Extract a column (vector)
runs_df[runs_df$player_id == "P101", ]                         # Filter rows
runs_df[order(runs_df$time_sec), ]                             # Sort by fastest time

# -----------------------------
# 7) Conditionals: if / else (flow control)
# -----------------------------

time_sec <- 200
deaths <- 0

if (time_sec < 300)
{
  print("Fast run (under 300 seconds).")
}else{
  print("Slow run (300 seconds or more).")
}

# A slightly more realistic example using two variables.
if ((deaths == 0L) & (time_sec < 300))
{
  print("Clean run: fast and no deaths.")
}else if (deaths == 0L){
  print("No deaths, but time could improve.")
}else{
  print("Some deaths occurred; focus on avoiding damage.")
}

# -----------------------------
# 8) Loops: for (step-by-step logic)
# Loops come AFTER conditionals, so students can reason about the logic inside the loop.
# -----------------------------

for (i in seq_along(p101_times_sec))
{
  t <- p101_times_sec[i]
  
  if (is.na(t))
  {
    print(paste("Run", i, "was missing (aborted)."))
  }
  else if (t < 280)
  {
    print(paste("Run", i, "=", t, "sec (good)."))
  }
  else
  {
    print(paste("Run", i, "=", t, "sec (needs improvement)."))
  }
}

# -----------------------------
# 9) While loops (control flow alternative)
# Use when you do not know in advance how many iterations you need.
# -----------------------------

attempt <- 1
max_attempts <- 3

while (attempt <= max_attempts)
{
  print(paste("Attempt:", attempt))
  attempt <- attempt + 1
}

# -----------------------------
# 10) Writing your own functions
# -----------------------------

#' @title clamp
#' @description Clamp a numeric value between a min and max (common in gameplay + analytics).
#' @param value Numeric value to clamp.
#' @param min_val Minimum allowed value.
#' @param max_val Maximum allowed value.
#' @return Clamped numeric value.
clamp <- function(value, min_val, max_val)
{
  if (value < min_val)
    return(min_val)
  
  if (value > max_val)
    return(max_val)
  
  return(value)
}

clamp(12, 0, 10)
clamp(-5, 0, 10)
clamp(7, 0, 10)

# -----------------------------
# 11) Scripts and source()
# source() runs another .R file and brings its functions into the current script.
# -----------------------------

# Example (commented out so this demo file runs standalone):
# source("useful_functions.R")

# -----------------------------
# 12) External functions (packages) and why we use them
# -----------------------------

# install.packages("ggplot2")   # Run once per machine (commented out)
# library(ggplot2)              # Load the package in the current session

# -----------------------------
# 13) Interrogating a data frame (how to inspect your data)
# -----------------------------

nrow(runs_df)
ncol(runs_df)
names(runs_df)

summary(runs_df)
table(runs_df$device)

# -----------------------------
# 14) Basic descriptive statistics (base R)
# -----------------------------

mean(runs_df$time_sec)
median(runs_df$time_sec)
sd(runs_df$time_sec)

# Grouped mean time by device.
aggregate(time_sec ~ device, data = runs_df, mean)

# -----------------------------
# 15) Named arguments and flexible function calls
# -----------------------------

mean(runs_df$time_sec, trim = 0.0)                             # Named argument (trim)
head(runs_df, n = 2)                                           # Named argument (n)

# -----------------------------
# 16) Basic plots (base R) for quick insight
# -----------------------------

# a) Stripchart: see individual observations per category.
stripchart(
  time_sec ~ device,                                           # Formula: time grouped by device
  data = runs_df,                                              # Data frame containing columns
  method = "jitter",                                           # Jitter points to reduce overlap
  vertical = TRUE,                                             # Categories on x-axis, values on y-axis
  las = 2,                                                     # Rotate x labels
  main = "Completion time by device (stripchart)",             # Plot title
  ylab = "Time (sec)",                                         # Y-axis label
  xlab = "Device"                                              # X-axis label
)

# b) Boxplot + points overlay (summary + raw data).
boxplot(
  time_sec ~ device,                                           # Boxplots of time per device
  data = runs_df,                                              # Data source
  las = 2,                                                     # Rotate x labels
  main = "Completion time by device (boxplot + points)",       # Plot title
  xlab = "Device",                                             # X-axis label
  ylab = "Time (sec)"                                          # Y-axis label
)

stripchart(
  time_sec ~ device,                                           # Same grouping, overlay points
  data = runs_df,                                              # Data source
  method = "jitter",                                           # Jitter points
  vertical = TRUE,                                             # Match orientation
  add = TRUE,                                                  # Add to existing plot
  pch = 16,                                                    # Solid circles
  col = "black"                                                # Colour
)

# c) Histogram: quick shape check.
hist(
  runs_df$time_sec,                                            # Numeric data to histogram
  main = "Distribution of completion times (histogram)",       # Plot title
  xlab = "Time (sec)"                                          # X-axis label
)

# d) Density plot: smooth distribution.
plot(
  density(runs_df$time_sec),                                   # Kernel density estimate
  main = "Distribution of completion times (density)",         # Plot title
  xlab = "Time (sec)",                                         # X-axis label
  ylab = "Density"                                             # Y-axis label
)

abline(v = median(runs_df$time_sec), lty = 2)                  # Median line (dashed)

# e) ECDF: teaches percentiles (median = 0.5).
plot(
  ecdf(runs_df$time_sec),                                      # Empirical CDF function
  main = "ECDF of completion times",                           # Plot title
  xlab = "Time (sec)",                                         # X-axis label
  ylab = "F(time)"                                             # Cumulative proportion
)

abline(v = median(runs_df$time_sec), lty = 2)                  # Median x-position
abline(h = 0.5, lty = 2)                                       # 50th percentile

# -----------------------------
# 17) More vector tools (sequences, repetition, sorting)
# -----------------------------

seq(1, 10)                                                     # 1..10
seq(0, 1, by = 0.2)                                            # step size
rep("tick", times = 3)                                         # repeat values
order(runs_df$deaths)                                          # sort indices by deaths

# -----------------------------
# 18) Built-in math functions you will see in analysis work
# -----------------------------

log10(1000)
log2(64)
log(1000)                                                      # natural log
exp(1)                                                         # e
sqrt(25)
abs(-10.58)
round(pi, 3)

# -----------------------------
# 19) Where this fits in the module
# -----------------------------

# This file is intentionally a "sandbox":
# - Run line-by-line, watch outputs in the console, and change values.
# - The same skills apply when we load your real gameplay user-test dataset.
