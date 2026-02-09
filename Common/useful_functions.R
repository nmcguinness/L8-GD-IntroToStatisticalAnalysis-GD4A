
# A function is reusable code that takes inputs and returns outputs.
categorise_time <- function(time_in_seconds)
{
  # Validate input: if missing, return NA (not available).
  if (is.na(time_in_seconds))
    return(NA)
  
  # Use thresholds to return a category label.
  if (time_in_seconds < 180)
    return("fast")
  else if (time_in_seconds < 360)
    return("moderate")
  else
    return("slow")
}

# ------------------------------------------------------------
# Function: clear_workspace_and_console()
# Purpose :
#   Reset the R session to a "clean start" so scripts behave
#   consistently when re-run (especially in teaching labs).
#
# What it does:
#   1) Removes all user-created objects from the Global Environment.
#   2) Clears the RStudio console (visual only; does not affect objects).
#
# Parameters:
#   confirm (logical):
#     If TRUE (default), the workspace is cleared. If FALSE, nothing is removed.
#     This is a small safety switch for when you're experimenting.
#
#   clear_console (logical):
#     If TRUE (default), attempts to clear the console (RStudio-friendly).
#
# Notes:
#   - rm(list = ls(...)) clears variables, data frames, functions, etc.
#   - cat("\014") is mainly for RStudio; it may do nothing in some terminals.
# ------------------------------------------------------------
clear_workspace_and_console <- function(confirm = TRUE, clear_console = TRUE) {
  if (!isTRUE(confirm))
    return(invisible(FALSE))

  rm(list = ls(all.names = TRUE))     # Remove all objects from the environment.

  if (isTRUE(clear_console))
    cat("\014")                      # Clear the console (RStudio).

  invisible(TRUE)
}

# ------------------------------------------------------------------------------
# load_pkg(pkg)
#
# Purpose:
#   Ensure an R package is available and loaded. If the package is not currently
#   installed, it can optionally be installed from CRAN and then loaded.
#
# Parameters:
#   pkg (character):
#     The package name (e.g., "ggplot2", "dplyr") as a single string.
#
#   install_if_missing (logical):
#     If TRUE (default), installs missing packages from CRAN.
#     If FALSE, throws an error if the package is not installed.
#
#   quietly (logical):
#     If TRUE (default), suppresses startup messages when attaching the package.
#
# Behaviour:
#   - Uses requireNamespace(..., quietly = TRUE) to test installation without
#     attaching the package.
#   - If missing and install_if_missing = TRUE, calls install.packages(pkg).
#   - Loads the package with library(pkg, character.only = TRUE).
#
# Returns:
#   Invisibly returns TRUE if the package is attached successfully.
#
# Notes:
#   - Installing packages may prompt for a CRAN mirror if one is not configured.
#   - If you need non-CRAN sources (Bioconductor/GitHub), this helper should be
#     adapted accordingly.
#
# Example:
#   load_pkg("tidyverse")
#   load_pkg("shiny", install_if_missing = FALSE)
# ------------------------------------------------------------------------------
load_pkg <- function(pkg, install_if_missing = TRUE, quietly = TRUE) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (!isTRUE(install_if_missing))
      stop("Package '", pkg, "' is not installed. Install it and re-run.")

    install.packages(pkg)
  }

  if (isTRUE(quietly)) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  } else {
    library(pkg, character.only = TRUE)
  }

  invisible(TRUE)
}

# ------------------------------------------------------------------------------
# require_pkg(pkg)
#
# Purpose:
#   A stricter alternative to load_pkg() for assessed work / reproducible scripts:
#   it will *not* install packages automatically. It errors with a helpful message.
#
# Example:
#   require_pkg("tidyverse")
# ------------------------------------------------------------------------------
require_pkg <- function(pkg, quietly = TRUE) {
  load_pkg(pkg, install_if_missing = FALSE, quietly = quietly)
}

# ------------------------------------------------------------------------------
# set_wd_to_this_file()
#
# Purpose:
#   Set the R working directory (getwd()) to the folder containing the "current"
#   source file being executed. This makes relative paths (e.g., "data/file.csv")
#   resolve relative to the script location rather than the project root or
#   wherever R was launched from.
#
# How it determines the file location (in priority order):
#   1) RStudio: Uses rstudioapi::getActiveDocumentContext() to get the active
#      document path (works when running code from an open script).
#   2) Command line (Rscript): Uses commandArgs() and the --file=... argument.
#   3) knitr / Quarto: Uses knitr::current_input() when rendering an Rmd/Qmd.
#
# Parameters:
#   verbose (logical):
#     If TRUE, prints the working directory it set.
#
# Returns:
#   Invisibly returns the new working directory path (character string).
#
# Notes:
#   - If none of the detection methods can determine a file path, the function
#     throws an error.
#   - Recommended usage: call once near the top of your script.
#
# Example:
#   set_wd_to_this_file()
#   read.csv("data/survey.csv")
# ------------------------------------------------------------------------------
set_wd_to_this_file <- function(verbose = FALSE) {
  # 1) Best case: running in RStudio (active document has a path)
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    ctx <- rstudioapi::getActiveDocumentContext()
    if (!is.null(ctx$path) && nzchar(ctx$path)) {
      setwd(dirname(normalizePath(ctx$path)))
      if (isTRUE(verbose))
        message("Working directory set to: ", getwd())
      return(invisible(getwd()))
    }
  }

  # 2) If running via Rscript (command line): use --file=...
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  hit <- grep(paste0("^", file_arg), args, value = TRUE)
  if (length(hit) == 1) {
    this_path <- sub(file_arg, "", hit)
    setwd(dirname(normalizePath(this_path)))
    if (isTRUE(verbose))
      message("Working directory set to: ", getwd())
    return(invisible(getwd()))
  }

  # 3) If running inside knitr / Quarto: fall back to the input document
  if (!is.null(getOption("knitr.in.progress")) && getOption("knitr.in.progress")) {
    if (requireNamespace("knitr", quietly = TRUE)) {
      in_path <- knitr::current_input(dir = TRUE)
      if (!is.null(in_path) && nzchar(in_path)) {
        setwd(dirname(normalizePath(in_path)))
        if (isTRUE(verbose))
          message("Working directory set to: ", getwd())
        return(invisible(getwd()))
      }
    }
  }

  stop("Couldn't determine the current file path (not RStudio, not Rscript --file, and not knitr).")
}

# ------------------------------------------------------------
# Function: create_directory(dir)
# Purpose :
#   Ensure a target folder exists before saving files (CSVs, plots,
#   reports, exports). This is a reusable version that works for
#   *any* directory name/path you provide.
#
# Parameters:
#   dir (character):
#     The folder path you want to ensure exists.
#     Examples:
#       "output"
#       "output/plots"
#       "results/week1"
#
#   recursive (logical):
#     If TRUE (default), creates parent folders as needed.
#
#   verbose (logical):
#     If TRUE, prints whether the directory was created or already existed.
#
# What it does:
#   - Checks whether the folder specified by `dir` exists.
#   - If it does not exist, it creates it (optionally recursively).
#
# Returns:
#   Invisibly returns the directory path.
# ------------------------------------------------------------
create_directory <- function(dir, recursive = TRUE, verbose = FALSE) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = isTRUE(recursive), showWarnings = FALSE)
    if (isTRUE(verbose))
      message("Created directory: ", dir)
  } else {
    if (isTRUE(verbose))
      message("Directory already exists: ", dir)
  }

  invisible(dir)
}
