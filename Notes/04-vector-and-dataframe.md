
# Why this matters for playtesting reports

Most playtesting analysis starts with two building blocks:

- a **vector**: one “column” of values (scores, times, ratings, names)
- a **data frame**: a table of columns (the survey dataset)

If you understand these two, you can:

- clean your survey data,
- compute summaries,
- produce plots and report tables.

# Vectors

A **vector** is a *single* sequence of values.  
Vectors are the foundation of almost everything in R.

## Creating vectors

### Numeric vectors

```r
# Level numbers 1 to 10
level_numbers <- 1:10

# Player scores from 10 rounds
player_scores <- c(150, 200, 180, 220, 170, 190, 210, 230, 200, 215)
```

### Character vectors

```r
# Names of game levels
levels <- c(
  "Grassy Plains", "Misty Mountains", "Arid Desert", "Icy Tundra",
  "Volcanic Island", "Lava Lair", "Ocean Abyss", "Sky Castle",
  "Dark Dungeon", "Final Fortress"
)
```

### Logical vectors

```r
# Checkpoints reached? (TRUE/FALSE)
checkpoints <- c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE)
```

## Printing and inspecting vectors

```r
print(level_numbers)
print(player_scores)
print(levels)
print(checkpoints)

length(player_scores)   # number of elements
```

Common “what is it?” tools:

| Function | What it tells you |
| :- | :- |
| `length(x)` | how many elements |
| `class(x)` | the type (numeric, character, logical) |
| `str(x)` | a quick structural summary |

## Indexing: getting elements out

Vectors are indexed starting at **1** (not 0).

```r
levels[7]                     # 7th level
player_scores[c(1, 6, 10)]     # 1st, 6th, and 10th score
levels[2:4]                   # a range: 2nd to 4th
levels[-2]                    # everything except the 2nd
levels[-c(1,2)]               # everything except the 1st and 2nd
```

### A quick loop (only to show the idea)

You usually *don’t* need loops for vectors, but here is the idea:

```r
for (i in 1:length(levels)) {
  print(levels[i])
}
```

## Modifying vectors

You can update values by index:

```r
player_names <- c("alan", "bea", "ciara", "dave", "erica")

player_names[2] <- "beatrix"  # update the 2nd name
player_names
```

You can update multiple values at once:

```r
player_scores[c(2, 9)] <- c(205, 215)
levels[c(3, 8)] <- c("Dusty Dunes", "Cloud Kingdom")
```

## Vectorised operations

Vectorised means: R performs the operation **element-by-element** automatically.

```r
bonus_points <- c(10, 5, 10, 5, 10, 5, 10, 5, 10, 5)

updated_scores <- player_scores + bonus_points
updated_scores
```

Comparing two players:

```r
player2_scores <- c(155, 195, 175, 215, 165, 185, 205, 225, 195, 210)

score_difference <- player_scores - player2_scores
score_difference
```

## Useful vector functions

These are common in playtesting:

```r
sum(player_scores)         # total
mean(player_scores)        # average
median(player_scores)      # middle value
range(player_scores)       # min and max
min(player_scores)
max(player_scores)
sd(player_scores)          # standard deviation
var(player_scores)         # variance
unique(player_scores)      # remove duplicates
```

### Quantiles and IQR (spread)

```r
quantile(player_scores, 0.75)                 # 75th percentile
iqr <- quantile(player_scores, 0.75) - quantile(player_scores, 0.25)
iqr
```

## Sequences and repetition

Useful for generating test data.

```r
rounds <- seq(1, 20, by = 2)             # odd rounds
difficulty_levels <- seq(0.5, 5, length.out = 10)

life_counts <- rep(3, times = 10)        # ten players with 3 lives
repeated_levels <- rep(levels, each = 2) # each level repeated twice
```

## Logical filtering (a very important skill)

You can select elements using a logical condition:

```r
# Scores greater than 200
player_scores[player_scores > 200]
```

You can combine conditions with:

- `&` (AND)
- `|` (OR)

```r
# High scores that are also odd numbers
high_odd <- player_scores[player_scores > 200 & player_scores %% 2 == 1]
high_odd
```

Using a logical vector to filter another vector:

```r
# Levels where checkpoints were NOT reached
unreached_levels <- levels[!checkpoints]
unreached_levels
```

### Pattern matching in character vectors

`grep()` finds matches by pattern:

```r
dark_levels <- levels[grep("un", levels)]
dark_levels

grep("un", levels)   # indices of matching elements
```

## Checking conditions across a whole vector

```r
all(player_scores > 100)   # are all scores above 100?
any(player_scores > 220)   # is any score above 220?
```

## Applying a function to each element

For beginners, `sapply()` is a readable start:

```r
percentage_scores <- sapply(
  player_scores,
  function(score) (score / max(player_scores)) * 100
)

percentage_scores
```

## Sorting and ordering

```r
sort(player_scores)                         # ascending
sort(player_scores, decreasing = TRUE)      # descending

order(player_scores)                        # indices that would sort the vector
```

Why `order()` matters:
- you can use it to sort *another* vector the same way.

## Set operations (treating vectors like sets)

Useful for comparing lists (e.g., levels completed vs not completed).

```r
completed_levels <- c("Grassy Plains", "Misty Mountains", "Arid Desert", "Icy Tundra")
yet_to_complete_levels <- c("Icy Tundra", "Volcanic Island", "Lava Lair")

union(completed_levels, yet_to_complete_levels)
intersect(completed_levels, yet_to_complete_levels)
setdiff(completed_levels, yet_to_complete_levels)
```

# Data frames

A **data frame** is a table:

- each **column** is usually a vector
- each **row** is one observation (one participant, one session, one event)

Playtesting survey data is almost always a data frame.

## Creating a data frame

Here’s a small example:

```r
animation_df <- data.frame(
  Movie = c("Shrek", "Up", "Jungle Book", "Aladdin"),
  Director = c("John Doe", "Jane Smith", "Alice Brown", "Bob White"),
  ReleaseYear = c(2020, 2021, 2019, 2022),
  BudgetMillions = c(150, 200, 180, 210),
  BoxOfficeMillions = c(500, 650, 550, NA)
)

animation_df
```

Notice:
- columns can be different types
- missing values are written as `NA`

## Inspecting a data frame

```r
nrow(animation_df)    # number of rows
ncol(animation_df)    # number of columns
names(animation_df)   # column names
str(animation_df)     # structure + types
summary(animation_df) # quick stats per column
```

## Accessing columns and rows

### Columns

```r
animation_df$Movie          # $ notation
animation_df[["Director"]]  # [[ notation (good when names are strings)
```

### Rows and cells

```r
animation_df[1, ]       # first row
animation_df[, 1]       # first column
animation_df[2, 3]      # row 2, column 3
animation_df[1:3, ]     # rows 1 to 3
animation_df[c(1, 4), ] # rows 1 and 4
```

Select multiple columns by name:

```r
animation_df[, c("Movie", "BudgetMillions")]
```

## Adding and removing columns

Add a column:

```r
animation_df$DurationMinutes <- c(90, 100, 95, 105)
animation_df
```

Remove a column by setting it to `NULL`:

```r
animation_df$DurationMinutes <- NULL
animation_df
```

## Adding and removing rows

Add a row with `rbind()`:

```r
new_movie <- data.frame(
  Movie = "Virtual Voyage",
  Director = "Gary Green",
  ReleaseYear = 2023,
  BudgetMillions = 220,
  BoxOfficeMillions = NA
)

animation_df <- rbind(animation_df, new_movie)
```

Remove a row by index:

```r
animation_df <- animation_df[-5, ]
```

## Creating derived columns (column calculations)

```r
animation_df$ProfitMillions <- animation_df$BoxOfficeMillions - animation_df$BudgetMillions
animation_df
```

You can also use `sapply()` for column-wise rules:

```r
animation_df$ProfitabilityRatio <- sapply(
  animation_df$ProfitMillions,
  function(x) if (!is.na(x)) x / 100 else NA
)
```

## Filtering rows (base R style)

```r
movies_after_2020 <- animation_df[animation_df$ReleaseYear > 2020, ]
movies_after_2020
```

## Sorting a data frame

Sort by profit descending:

```r
sorted_by_profit <- animation_df[order(animation_df$ProfitMillions, decreasing = TRUE), ]
sorted_by_profit
```

## Handling missing values

Find rows with missing values:

```r
animation_df[is.na(animation_df$BoxOfficeMillions), ]
```

Remove rows with any missing values:

```r
cleaned_df <- na.omit(animation_df)
cleaned_df
```

Important:
- `na.omit()` is fine for small examples.
- In playtesting reports, you usually drop missing values **only for the variables you are analysing**, not the entire dataset.

## Merging data frames

If you have two tables that share a key column (like `Movie`), you can merge them:

```r
ratings_df <- data.frame(
  Movie = c("Shrek", "Up", "Jungle Book", "Aladdin"),
  IMDBRating = c(7.5, 8.3, 7.0, 8.0)
)

merged_df <- merge(animation_df, ratings_df, by = "Movie")
merged_df
```

Playtesting example:
- merging survey responses with a separate table containing build version or hardware specs.

## Grouped summaries (base R)

### aggregate()

```r
avg_budget_by_year <- aggregate(BudgetMillions ~ ReleaseYear, data = animation_df, FUN = mean)
avg_budget_by_year
```

### tapply()

```r
avg_budget_by_year_2 <- tapply(animation_df$BudgetMillions, animation_df$ReleaseYear, mean)
avg_budget_by_year_2
```

## Splitting data into groups

```r
split_by_year <- split(animation_df, animation_df$ReleaseYear)
split_by_year
```

# Bridge to tidyverse reports

In your playtesting labs/reports, you’ll often use **dplyr** instead of base indexing because it reads more clearly.

Here is the same “filter then summarise” idea in tidyverse:

```r
library(tidyverse)

data %>%
  filter(!is.na(recommend_0to10)) %>%
  group_by(platform) %>%
  summarise(
    n = n(),
    mean_recommend = mean(recommend_0to10),
    .groups = "drop"
  )
```

# Mini-checklist for students

When you are stuck:

- Is the thing I’m working with a **vector** or a **data frame**?
- Am I selecting a **column** or a **row**?
- Did I check the column names with `names(data)`?
- Are missing values (`NA`) affecting my result?

# Short practice tasks

Try these with your class survey dataset (not the movie example):

1. Extract one numeric column (a vector) and compute: `mean`, `median`, `sd`, and `range`.
2. Use logical filtering to list only the rows where `recommend_0to10` is missing.
3. Create a new column `high_recommend` where recommendation is 8–10.
4. Create a small 3-column data frame that only contains: `platform`, `frustration_1to7`, `recommend_0to10`.
5. Sort the data frame by `recommend_0to10` descending and inspect the top 5 rows.
