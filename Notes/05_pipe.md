# Why the pipe matters

When you write analysis code for a playtesting report, you often do a **sequence** of steps:

- load data
- clean column names
- keep a few columns
- remove missing values
- create a new column
- produce a summary table

Without a pipe, R code can get “inside-out”:

```r
summarise(
  mutate(
    filter(
      select(data, platform, recommend_0to10),
      !is.na(recommend_0to10)
    ),
    platform = as.factor(platform)
  ),
  mean_recommend = mean(recommend_0to10)
)
```

This is hard to read because you have to start from the middle.

The **pipe** lets you write the same logic **left-to-right**:

```r
data |>
  dplyr::select(platform, recommend_0to10) |>
  dplyr::filter(!is.na(recommend_0to10)) |>
  dplyr::mutate(platform = as.factor(platform)) |>
  dplyr::summarise(mean_recommend = mean(recommend_0to10))
```

# What is the base pipe (|>)?

R’s built-in pipe operator is:

```r
|>
```

Read it as:

> “Take the result from the left and use it as the first argument of the function on the right.”

So these two are equivalent:

```r
mean(x)
x |> mean()
```

# A gentle mental model

If you see:

```r
A |> f() |> g() |> h()
```

Read it as:

1. start with `A`
2. do `f`
3. then do `g`
4. then do `h`

# Base pipe (|>) vs tidyverse pipe (%>%)

You will see both in the wild:

- `%>%` is from **magrittr** (loaded by tidyverse)
- `|>` is built into **base R** (recommended going forward)

For our modules:

- prefer **`|>`** because it works without extra packages
- you can still use tidyverse functions (dplyr/ggplot2) with `|>`

## Key differences you should know (beginner level)

| Feature | base | magrittr |
| :- | :- | :- |
| Needs package? | no | yes (tidyverse/magrittr) |
| Default behaviour | passes LHS as 1st argument | similar |
| Placeholder | does not use `.` | uses `.` |
| Works with anonymous functions | yes (`\(x)`) | yes (`{}` or `~`) |

If you have learned `%>%` already, don’t panic. The main idea is the same.

# Writing clean pipelines

## One job per line

Good:

```r
data |>
  dplyr::select(platform, recommend_0to10) |>
  dplyr::filter(!is.na(recommend_0to10))
```

Avoid:

```r
data |> dplyr::select(platform, recommend_0to10) |> dplyr::filter(!is.na(recommend_0to10))
```

## Name intermediate results when it helps

If you can’t explain a pipeline in one breath, split it:

```r
core_df <- data |>
  dplyr::select(platform, recommend_0to10, frustration_1to7)

clean_df <- core_df |>
  tidyr::drop_na()
```

# Common patterns you will use in playtesting reports

The examples below assume:

- you have a data frame called `data`
- you have loaded tidyverse packages (or use `dplyr::` prefixes)

## Pattern 1: select → filter → summarise

Question:
> What is the average recommendation score overall?

```r
data |>
  dplyr::select(recommend_0to10) |>
  dplyr::filter(!is.na(recommend_0to10)) |>
  dplyr::summarise(
    n = dplyr::n(),
    mean_recommend = mean(recommend_0to10)
  )
```

## Pattern 2: select → drop_na → mutate → summarise

Question:
> Do highly frustrated players recommend less?

```r
data |>
  dplyr::select(frustration_1to7, recommend_0to10) |>
  tidyr::drop_na() |>
  dplyr::mutate(high_frustration = frustration_1to7 >= 6) |>
  dplyr::group_by(high_frustration) |>
  dplyr::summarise(
    n = dplyr::n(),
    mean_recommend = mean(recommend_0to10),
    .groups = "drop"
  )
```

## Pattern 3: grouped summaries

Question:
> How do recommendation scores vary by platform?

```r
data |>
  dplyr::select(platform, recommend_0to10) |>
  tidyr::drop_na() |>
  dplyr::group_by(platform) |>
  dplyr::summarise(
    n = dplyr::n(),
    mean_recommend = mean(recommend_0to10),
    .groups = "drop"
  ) |>
  dplyr::arrange(desc(mean_recommend))
```

## Pattern 4: “clean then plot”

Question:
> Show a boxplot of recommendation by platform.

```r
plot_df <- data |>
  dplyr::select(platform, recommend_0to10) |>
  tidyr::drop_na() |>
  dplyr::mutate(platform = as.factor(platform))

ggplot2::ggplot(plot_df, ggplot2::aes(x = platform, y = recommend_0to10)) +
  ggplot2::geom_boxplot() +
  ggplot2::labs(
    title = "Recommendation score by platform",
    x = "Platform",
    y = "Recommend (0–10)"
  )
```

# Anonymous functions with the pipe

Sometimes you want to pipe a value into a “one-off” transformation that you **don’t** want to name as a separate function.
That’s when an **anonymous function** is useful.

An anonymous function is a function you write **inline** without giving it a name.

In modern R, the short syntax is:

```r
\(x) x + 1
```

Read it as:

- `\(x)` : “a function that takes input called `x`”
- `x + 1` : “and returns `x + 1`”

## Why this matters with `|>`

The base pipe `|>` always passes the left-hand value into the **first argument** of the next function.

Most of the time this is perfect:

```r
scores |> mean(na.rm = TRUE)
```

But sometimes you want to insert the piped value **somewhere else**, or do a custom step.

That’s when you can pipe into an anonymous function.

## Pattern 1: transform then continue

Example: remove missing values, then compute mean.

```r
scores <- c(6, 7, 9, 8, NA, 10)

scores |>
  (\(x) x[!is.na(x)])() |>
  mean()
```

What’s happening?

- `scores` is piped into the anonymous function as `x`
- the function returns `x` with NA removed
- then the cleaned vector is piped into `mean()`

### Beginner-friendly alternative

This is equivalent (and often clearer early on):

```r
scores_no_na <- scores[!is.na(scores)]
scores_no_na |> mean()
```

## Pattern 2: insert into a non-first argument

Sometimes the function you want to call does **not** take your data as the first argument.

Example: you want `"Player score: <value>"`.

`paste()` takes strings first, then values — so piping straight into `paste()` can be confusing.

Use an anonymous function:

```r
score <- 42

score |>
  (\(v) paste("Player score:", v))()
```

## Pattern 3: “peek” / print inside a pipeline (debugging)

When a pipeline fails or gives a weird result, it helps to print an intermediate value.

```r
data |>
  dplyr::select(platform, recommend_0to10) |>
  (\(df) { print(head(df, 3)); df })() |>
  dplyr::filter(!is.na(recommend_0to10))
```

The anonymous function:

- prints the first 3 rows
- returns the same data frame so the pipeline continues

## Common mistakes

### Forgetting to call the function

This will **not** run the anonymous function:

```r
scores |> (\(x) x[!is.na(x)])
```

You must call it with `()`:

```r
scores |> (\(x) x[!is.na(x)])()
```

### Using `function(x)` vs `\(x)`

Both are valid:

```r
scores |> (function(x) x[!is.na(x)])() |> mean()
scores |> (\(x) x[!is.na(x)])() |> mean()
```

Use whichever you find easier to read. In this module, we’ll usually use `\(x)` for brevity.

# Pipes with base R (no tidyverse)

You can still benefit from `|>` without dplyr.

## Example: vectors

```r
scores <- c(6, 7, 9, 8, 10, 4, 7, NA)

scores |>
  (\(x) x[!is.na(x)])() |>
  mean()
```

What is happening?

- `(\(x) ...)()` is an **anonymous function** you call immediately.
- Here it removes NA before computing the mean.

A clearer (beginner-friendly) approach is to name the step:

```r
scores_no_na <- scores[!is.na(scores)]
scores_no_na |> mean()
```

# Important pitfall: pipes pass into the first argument

This works:

```r
x |> mean()
```

Because `mean(x)` expects `x` as the first argument.

But this is a common mistake:

```r
x |> round(2)
```

It works because `round(x, 2)` expects `x` first, but the same idea can fail if the function’s first argument isn’t your data.

## When the first argument is NOT the data

Some functions don’t take the “data” as the first argument.  
In that case, don’t force a pipe — call the function normally or restructure.

If you need to insert the piped value somewhere else, use an anonymous function:

```r
x |> (\(v) paste("Value:", v))()
```

# Debugging pipelines (fast)

If a pipeline fails:

1. run the pipeline one line at a time
2. insert a temporary `head()` or `glimpse()` step

Example:

```r
data |>
  dplyr::select(platform, recommend_0to10) |>
  (\(df) { print(head(df, 3)); df })() |>
  dplyr::filter(!is.na(recommend_0to10))
```

That function is just:

- “print something”
- “return the same object so the pipeline continues”

# Style checklist for your reports

- Use `|>` for pipelines.
- One verb per line.
- Use clear object names: `core_df`, `clean_df`, `plot_df`.
- Prefer **readability** over clever code.
