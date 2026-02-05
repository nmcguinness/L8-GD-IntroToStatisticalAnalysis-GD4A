#' @title demo_3_esquisse.R
#' @description Using R packages to explore, clean, and plot data easily using the tidyverse and esquisse visual interface
#' @author NMCG
#' @bugs None
#' @keywords tidyverse, ggplot2, esquisse

# Load required packages --------------------------------------------------

# The tidyverse is a collection of R packages for data science (includes dplyr, ggplot2, readr, tibble, etc.)
if(!require("tidyverse"))
  install.packages("tidyverse")
library(tidyverse)

# esquisse is an add-in for RStudio that lets you build ggplot2 graphs visually
if(!require("esquisse"))
  install.packages("esquisse")
library(esquisse)

# Clear the console (same as pressing Ctrl+L) -----------------------------
cat("\014")

# View the built-in dataset 'chickwts' as a tibble ------------------------

# chickwts contains weights of chicks fed different types of feed
# Viewing it as a tibble gives a cleaner, modern data display
tibble(chickwts)

# Launch the esquisse graphical interface ---------------------------------

# esquisse lets you drag-and-drop variables to visually build a ggplot
# This is useful for beginners who want to explore data without writing code

# Launch the esquisse UI with chickwts
esquisse::esquisser(chickwts)

# Example ggplot2 code for boxplot visualization --------------------------

# Below is a sample ggplot2 visualization of chick weights by feed type

# ggplot(chickwts) +
#   aes(x = "", y = weight) +                # No x-axis grouping; y-axis is weight
#   geom_boxplot(fill = "#B22222") +         # Create a red boxplot
#   theme_minimal() +                        # Use a clean, minimal theme
#   facet_wrap(vars(feed))                   # Create a boxplot for each feed type
