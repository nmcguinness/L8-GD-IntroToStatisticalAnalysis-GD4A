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

# esquisse::esquisser(chickwts, viewer="browser")

# Example ggplot2 code for boxplot visualization --------------------------

# Below is a sample ggplot2 visualization of chick weights by feed type

chickwts %>%
  filter(weight >= 108L & weight <= 348L) %>%
  ggplot() +
  aes(x = feed, y = weight, fill = feed) +
  geom_violin(adjust = 0.2) +
  scale_fill_hue(direction = 1) +
  labs(fill = "Feed Types") +
  coord_flip() +
  theme_minimal() +
  ylim(50, 450)

