#' @title demo_1_vector.R
#' @description Creating, accessing, transforming, subsetting and applying in-built functions to a vector 
#' @author NMCG
#' @bugs None
#' @keywords vector, subset, sort, sample, element-wise operations
#' @seealso https://www.tutorialspoint.com/r/r_vectors.htm

# Clear the console (equivalent to Ctrl+L in RStudio) --------------------
cat("\014")

# Create sample game data using vectors ----------------------------------

# Level numbers 1 through 10
level_numbers <- 1:10

# Player scores from ten rounds of a game
player_scores <- c(150, 200, 180, 220, 170, 190, 210, 230, 200, 215)

# Names of 10 game levels
levels <- c("Grassy Plains", "Misty Mountains", "Arid Desert", "Icy Tundra", 
            "Volcanic Island", "Lava Lair", "Ocean Abyss", "Sky Castle", 
            "Dark Dungeon", "Final Fortress")

# Checkpoints reached by player (TRUE/FALSE)
checkpoints <- c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE)

# Print all the vectors --------------------------------------------------

print(level_numbers)
print(player_scores)
print(levels)
print(checkpoints)

# Print each level name (loop example)
for(i in 1:length(levels)) {
  print(levels[i])
}

# Accessing vector elements ----------------------------------------------

# Single element by index
print(levels[7])                          # 7th level
print(player_scores[c(1, 6, 10)])        # 1st, 6th, and 10th round scores

# Subsetting and modifying vectors ---------------------------------------

player_names <- c('alan', 'bea', 'ciara', 'dave', 'erica')

player_names[2] <- "beatrix"             # Update a name
name <- player_names[2]                  # Access second name
excl_name <- player_names[-2]           # Exclude second name
some_names1 <- player_names[c(2,4)]     # Access 2nd and 4th
some_names2 <- player_names[2:4]        # Range 2 to 4
some_names3 <- player_names[-c(1,2)]    # Exclude 1st and 2nd

# Modify elements of player scores and levels ----------------------------

player_scores[c(2, 9)] <- c(205, 215)    # Update scores
levels[c(3, 8)] <- c("Dusty Dunes", "Cloud Kingdom")  # Rename levels
print(player_scores)
print(levels)

# Vectorized operations --------------------------------------------------

bonus_points <- c(10, 5, 10, 5, 10, 5, 10, 5, 10, 5)
updated_scores <- player_scores + bonus_points      # Add bonus points
print(updated_scores)

player2_scores <- c(155, 195, 175, 215, 165, 185, 205, 225, 195, 210)
score_difference <- player_scores - player2_scores  # Compare scores
print(score_difference)

# Useful vector functions ------------------------------------------------

print(length(levels))          # Count of levels
print(sum(player_scores))      # Total score
print(range(player_scores))    # Min and max score

unique_scores <- unique(player_scores)  # Remove duplicates
print("Unique scores:")
print(unique_scores)

# Basic descriptive statistics -------------------------------------------

mn <- mean(player_scores)
md <- median(player_scores)
variance <- var(player_scores)
std_dev <- sd(player_scores)
quantiles <- quantile(player_scores, 0.75)
iqr <- quantile(player_scores, 0.75) - quantile(player_scores, 0.5)

print(paste("Mean:", mn))
print(paste("Median:", md))
print(paste("Variance:", variance))
print(paste("Standard Deviation:", std_dev))
print("75th percentile:")
print(quantiles)
print(paste("Interquartile Range (IQR):", iqr))

# Visualisation
boxplot(player_scores)

# Sequence generation ----------------------------------------------------

rounds <- seq(1, 20, by = 2)             # Odd-numbered rounds
difficulty_levels <- seq(0.5, 5, length.out = 10)
print(rounds)
print(difficulty_levels)

# Repetition examples ----------------------------------------------------

life_counts <- rep(3, times = 10)       # Each player starts with 3 lives
repeated_levels <- rep(levels, each = 2)
print(life_counts)
print(repeated_levels)

job_split <- rep(c("job", "no job"), times = c(35, 13))  # Simulate group labels
print(job_split)

# Logical filtering and indexing -----------------------------------------

high_scores <- player_scores[player_scores > 200 & player_scores %% 2 == 1]
print("High, odd scores:")
print(high_scores)

unreached_levels <- levels[!checkpoints]      # Where checkpoints were not reached
print("Unreached levels:")
print(unreached_levels)

dark_levels <- levels[grep("un", levels)]     # Match pattern in name
print("Levels containing 'un':")
print(dark_levels)
print("Matching indices:")
print(grep("un", levels))

# Logical condition testing ----------------------------------------------

all_above_100 <- all(player_scores > 100)
any_above_220 <- any(player_scores > 220)

print(paste("All scores above 100?", all_above_100))
print(paste("Any score above 220?", any_above_220))

# Apply a function to each element using sapply --------------------------

percentage_scores <- sapply(player_scores, 
                            function(score) (score / max(player_scores)) * 100)
print("Scores as percentages:")
print(percentage_scores)

# Sorting and ordering ---------------------------------------------------

sorted_scores <- sort(player_scores)                       # Ascending
sorted_scores_desc <- sort(player_scores, decreasing = TRUE)  # Descending
order_scores <- order(player_scores)                       # Sorting indices

print("Sorted scores (asc):")
print(sorted_scores)
print("Sorted scores (desc):")
print(sorted_scores_desc)
print("Order indices:")
print(order_scores)

# TODO: Add custom sort example

# Set operations ---------------------------------------------------------

completed_levels <- c("Grassy Plains", "Misty Mountains", "Arid Desert", "Icy Tundra")
yet_to_complete_levels <- c("Icy Tundra", "Volcanic Island", "Lava Lair")

all_levels <- union(completed_levels, yet_to_complete_levels)
common_levels <- intersect(completed_levels, yet_to_complete_levels)
remaining_levels <- setdiff(completed_levels, yet_to_complete_levels)
sum_set_diff <- union(setdiff(completed_levels, yet_to_complete_levels),
                      setdiff(yet_to_complete_levels, completed_levels))

print("All levels encountered:")
print(all_levels)
print("Common levels:")
print(common_levels)
print("Levels only completed:")
print(remaining_levels)
print("Symmetric difference (not shared):")
print(sum_set_diff)
