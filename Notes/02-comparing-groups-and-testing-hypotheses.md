# Comparing Groups and Testing Hypotheses

## Introduction

In the previous module, you learned to describe and summarise your playtest data. But game development decisions often require answering comparative questions:

- Did players who completed the tutorial rate the game higher than those who skipped it?
- Is there a relationship between playtime and satisfaction?
- Does the new control scheme perform better than the original?

This module introduces **inferential statistics** — techniques that help you determine whether patterns in your data reflect real effects or are just random variation.

---

## 1. The Logic of Statistical Testing

### 1.1 Why We Need Statistical Tests

Imagine you're comparing two versions of your combat system:
- Version A: Mean satisfaction = 7.2 (n=50)
- Version B: Mean satisfaction = 7.5 (n=50)

Version B scores higher, but is this difference **meaningful** or just chance? If you tested 50 different players tomorrow, would Version B still win?

Statistical tests help answer: "Given the variation in my data, how confident can I be that this difference is real?"

### 1.2 The Null Hypothesis

Statistical tests work by assuming there's **no real difference** (the null hypothesis) and then calculating how likely your observed results would be under that assumption.

**Null Hypothesis (H₀)**: There is no difference between groups / no relationship between variables.

**Alternative Hypothesis (H₁)**: There is a difference / there is a relationship.

If your data would be very unlikely under the null hypothesis, you **reject** the null and conclude there probably is a real effect.

### 1.3 P-Values: Probability of Chance Results

The **p-value** tells you the probability of getting results at least as extreme as yours if the null hypothesis were true.

- p = 0.05 means there's a 5% chance of seeing these results by random variation alone
- p = 0.01 means there's a 1% chance
- p = 0.50 means there's a 50% chance — your results are completely consistent with random variation

**Convention**: p < 0.05 is typically considered "statistically significant" — unlikely enough to reject the null hypothesis.

**Important caveats:**
- p < 0.05 is a convention, not a magic threshold
- Statistical significance ≠ practical importance
- A large sample can make tiny, meaningless differences "significant"

### 1.4 Effect Size: Practical Significance

Effect size measures the **magnitude** of a difference, separate from statistical significance.

Common effect size measures:
- **Cohen's d** for comparing two means (0.2 = small, 0.5 = medium, 0.8 = large)
- **Correlation coefficient (r)** for relationships (0.1 = small, 0.3 = medium, 0.5 = large)

**Example**: 
- Study 1: d = 0.8, p = 0.08 (large effect, not significant due to small sample)
- Study 2: d = 0.1, p = 0.001 (tiny effect, significant due to huge sample)

Study 1's finding might actually be more practically useful despite not reaching significance.

**Always report both p-value and effect size.**

---

## 2. Comparing Two Groups

### 2.1 Independent Samples t-Test

Use when comparing the means of **two separate groups**.

**When to use:**
- Comparing ratings between players who used controller vs. keyboard
- Comparing completion times between casual vs. hardcore gamers
- Comparing satisfaction between those who saw the tutorial vs. those who didn't

**Assumptions:**
- Data is numerical (or Likert treated as numerical)
- Groups are independent (different people in each group)
- Data is approximately normally distributed in each group
- Similar variance in both groups (can be relaxed with Welch's t-test)

**Example scenario:**

You want to know if players who received hints rated puzzle satisfaction differently from those who didn't.

| Group | n | Mean | SD |
|-------|---|------|-----|
| Hints | 45 | 7.8 | 1.4 |
| No Hints | 42 | 6.9 | 1.6 |

A t-test yields: t = 2.82, p = 0.006, Cohen's d = 0.60

**Interpretation**: The difference is statistically significant (p < 0.05) with a medium-to-large effect size. Players who received hints rated puzzle satisfaction meaningfully higher.

### 2.2 Paired Samples t-Test

Use when comparing two measurements **from the same people**.

**When to use:**
- Comparing ratings before and after a design change (same players)
- Comparing satisfaction with Level 1 vs. Level 2 (same players rated both)
- Pre/post training performance

**Example scenario:**

Players rated enjoyment before and after you added the new soundtrack:

| Player | Before | After |
|--------|--------|-------|
| 1 | 6 | 8 |
| 2 | 7 | 7 |
| 3 | 5 | 8 |
| ... | ... | ... |

Mean Before = 6.2, Mean After = 7.4

A paired t-test accounts for individual variation (some players rate everything high, some low) and tests whether the *change* is significant.

### 2.3 Mann-Whitney U Test (Non-Parametric Alternative)

Use when your data **violates t-test assumptions** (not normally distributed, ordinal data, small samples with outliers).

The Mann-Whitney U compares the **ranks** of values rather than the values themselves, making it robust to outliers and skewed distributions.

**When to use:**
- Small samples (n < 30 per group)
- Heavily skewed data
- Ordinal data (like Likert scales, if treating conservatively)
- When you have outliers you don't want to remove

**Trade-off**: Less statistical power than t-test when assumptions are met. Use t-test if your data allows; fall back to Mann-Whitney when it doesn't.

---

## 3. Comparing More Than Two Groups

### 3.1 One-Way ANOVA

Use when comparing means across **three or more groups**.

**When to use:**
- Comparing satisfaction across Easy/Normal/Hard difficulty settings
- Comparing completion times across different control schemes (A, B, C)
- Comparing ratings across player segments (Casual, Core, Hardcore)

**Why not just run multiple t-tests?**

If you compare Easy vs. Normal, Normal vs. Hard, and Easy vs. Hard separately, you inflate your chance of a false positive. With three comparisons at p = 0.05 each, your actual false positive rate rises to about 14%.

ANOVA controls this by testing all groups together.

**ANOVA output:**
- F-statistic: Ratio of variance between groups to variance within groups
- p-value: Whether any group differs significantly from any other

**Important**: A significant ANOVA tells you *something* differs but not *what*. You need **post-hoc tests** (like Tukey's HSD) to identify which specific groups differ.

**Example scenario:**

Rating "game feel" across three control schemes:

| Scheme | n | Mean | SD |
|--------|---|------|-----|
| A | 40 | 6.8 | 1.5 |
| B | 38 | 7.9 | 1.3 |
| C | 41 | 7.1 | 1.4 |

ANOVA result: F(2, 116) = 7.24, p = 0.001

Post-hoc (Tukey): B > A (p = 0.001), B > C (p = 0.02), A ≈ C (p = 0.58)

**Interpretation**: Scheme B is rated significantly higher than both A and C. No significant difference between A and C.

### 3.2 Kruskal-Wallis Test (Non-Parametric Alternative)

The non-parametric equivalent to one-way ANOVA. Use when ANOVA assumptions aren't met.

---

## 4. Analysing Categorical Data

When both your grouping variable and outcome are categorical, you need different techniques.

### 4.1 Chi-Square Test of Independence

Tests whether two categorical variables are related.

**When to use:**
- Is preferred difficulty related to player experience level?
- Is platform (PC/Console) related to genre preference?
- Is tutorial completion related to retention?

**Example scenario:**

You want to know if tutorial completion is related to first-week retention:

|  | Retained | Churned | Total |
|--|----------|---------|-------|
| Completed tutorial | 78 | 22 | 100 |
| Skipped tutorial | 45 | 55 | 100 |
| Total | 123 | 77 | 200 |

Chi-square test: χ² = 22.4, p < 0.001

**Interpretation**: There's a significant relationship between tutorial completion and retention. Players who completed the tutorial were more likely to be retained.

**Assumptions:**
- Expected count in each cell should be ≥ 5
- Observations are independent

### 4.2 Interpreting Chi-Square Results

A significant chi-square tells you variables are related, but not the strength or direction. Examine:

- **Percentages**: 78% of tutorial completers retained vs. 45% of skippers
- **Cramér's V**: Effect size for chi-square (0.1 = small, 0.3 = medium, 0.5 = large)

---

## 5. Correlation: Measuring Relationships

Correlation measures the strength and direction of a relationship between two numerical variables.

### 5.1 Pearson Correlation (r)

Measures **linear** relationships. Values range from -1 to +1:

- r = +1: Perfect positive relationship (as X increases, Y increases)
- r = 0: No linear relationship
- r = -1: Perfect negative relationship (as X increases, Y decreases)

**Interpreting strength:**
- |r| < 0.3: Weak
- 0.3 ≤ |r| < 0.5: Moderate  
- |r| ≥ 0.5: Strong

**Example scenario:**

You measure playtime (hours) and satisfaction rating (1-10):

| Playtime | Satisfaction |
|----------|--------------|
| 2 | 5 |
| 5 | 7 |
| 8 | 8 |
| 3 | 6 |
| 10 | 9 |
| ... | ... |

r = 0.72, p < 0.001

**Interpretation**: Strong positive correlation — players who played longer reported higher satisfaction. This is statistically significant.

### 5.2 Critical Warning: Correlation ≠ Causation

A correlation tells you two things vary together, not that one *causes* the other.

The playtime-satisfaction correlation could mean:
- Playing longer causes greater satisfaction
- More satisfied players choose to play longer
- A third factor (e.g., game interest) causes both

Don't conclude causation from correlation alone.

### 5.3 Spearman Correlation (ρ)

Non-parametric alternative using ranks instead of raw values.

**Use when:**
- Data is ordinal (like Likert scales)
- Relationship is monotonic but not linear
- Outliers are present

### 5.4 Visualising Correlations: Scatter Plots

Always visualise correlations with a scatter plot. This reveals:
- Whether the relationship is actually linear
- Outliers that might inflate/deflate the correlation
- Potential subgroups with different patterns

A correlation coefficient alone can be misleading — Anscombe's Quartet demonstrates four datasets with identical statistics but completely different patterns.

---

## 6. Choosing the Right Test: Decision Framework

```
WHAT ARE YOU TRYING TO DO?

├── Compare groups on a NUMERICAL outcome
│   ├── 2 groups
│   │   ├── Same people measured twice → Paired t-test (or Wilcoxon)
│   │   └── Different people → Independent t-test (or Mann-Whitney)
│   └── 3+ groups
│       └── Different people → ANOVA (or Kruskal-Wallis)
│
├── Test relationship between CATEGORICAL variables
│   └── Chi-square test
│
└── Test relationship between NUMERICAL variables
    └── Correlation (Pearson or Spearman)
```

### Parametric vs. Non-Parametric

| Parametric | Non-Parametric | Use Non-Parametric When |
|------------|----------------|------------------------|
| Independent t-test | Mann-Whitney U | Small n, skewed, ordinal |
| Paired t-test | Wilcoxon Signed-Rank | Small n, skewed, ordinal |
| One-way ANOVA | Kruskal-Wallis | Small n, skewed, ordinal |
| Pearson r | Spearman ρ | Ordinal, non-linear, outliers |

---

## 7. Practical Considerations for Playtest Analysis

### 7.1 Multiple Comparisons Problem

If you test 20 different hypotheses at p = 0.05, you'd expect 1 false positive by chance alone.

**Solutions:**
- Pre-register your key hypotheses — decide what you're testing before looking at data
- Apply Bonferroni correction: divide α by number of tests (0.05 / 20 = 0.0025)
- Distinguish confirmatory (hypothesis-testing) from exploratory analysis

### 7.2 Practical vs. Statistical Significance

A tiny improvement that's statistically significant might not be worth implementing. Consider:
- Development cost to implement
- Magnitude of the effect (effect size)
- What players actually notice

A 0.2-point improvement on a 10-point scale might be significant with n=1000 but completely imperceptible to players.

### 7.3 Sample Size and Statistical Power

**Power** is the probability of detecting a real effect if it exists.

With small samples, you might miss real effects (Type II error / false negative).

Rule of thumb for 80% power to detect medium effects:
- t-test: ~64 per group
- Correlation: ~85 total
- Chi-square: depends on expected proportions

For playtesting, you often work with smaller samples. Acknowledge this limitation — a non-significant result might mean "no effect" or "not enough data to detect an effect."

### 7.4 Reporting Your Results

When reporting statistical findings, include:

1. **Descriptive statistics**: Means, SDs, sample sizes per group
2. **Test statistic**: t, F, χ², r value
3. **Degrees of freedom**: (where applicable)
4. **P-value**: Exact value preferred (p = 0.023, not just p < 0.05)
5. **Effect size**: Cohen's d, Cramér's V, r
6. **Practical interpretation**: What this means for design decisions

**Example**: "Players who received hints (M = 7.8, SD = 1.4) rated puzzle satisfaction significantly higher than those without hints (M = 6.9, SD = 1.6), t(85) = 2.82, p = .006, d = 0.60. This medium-to-large effect suggests hints meaningfully improve the puzzle experience."

---

## 8. Practical Exercise

Your playtest collected satisfaction ratings (1-10) from three player segments:

**Casual players (n = 35)**: 6, 7, 5, 8, 6, 7, 7, 5, 6, 8, 7, 6, 5, 7, 6, 8, 7, 6, 7, 5, 6, 7, 8, 6, 7, 5, 6, 7, 7, 6, 8, 7, 6, 5, 7

**Core players (n = 30)**: 7, 8, 8, 9, 7, 8, 7, 8, 9, 8, 7, 8, 8, 9, 7, 8, 9, 8, 7, 8, 8, 9, 7, 8, 8, 7, 9, 8, 8, 7

**Hardcore players (n = 28)**: 5, 6, 4, 5, 6, 7, 5, 4, 6, 5, 6, 5, 4, 6, 5, 7, 5, 6, 4, 5, 6, 5, 4, 6, 5, 5, 6, 4

**Tasks:**

1. Calculate the mean and SD for each group
2. Which statistical test is appropriate to compare these groups?
3. Based on the means, which groups appear to differ?
4. If you found significant differences, what might this suggest about your game's design?
5. What additional data might help explain these patterns?

---

## Summary

You can now:

1. **Understand hypothesis testing logic** — null hypotheses, p-values, and their limitations
2. **Compare two groups** — using t-tests (paired and independent) and non-parametric alternatives
3. **Compare multiple groups** — using ANOVA and post-hoc tests
4. **Analyse categorical relationships** — using chi-square tests
5. **Measure correlations** — using Pearson and Spearman coefficients
6. **Choose appropriate tests** — based on your data type and question
7. **Interpret and report results** — with proper attention to effect sizes

The final module covers practical implementation: using spreadsheet tools to perform these analyses and presenting your findings effectively.

---

## Key Terms Glossary

| Term | Definition |
|------|------------|
| Alternative Hypothesis (H₁) | The hypothesis that there is an effect or difference |
| ANOVA | Analysis of variance — compares means across 3+ groups |
| Chi-Square Test | Tests association between categorical variables |
| Cohen's d | Effect size measure for mean differences |
| Correlation | Measure of linear relationship between two variables |
| Degrees of Freedom | Parameters that can vary in a statistical calculation |
| Effect Size | Measure of the magnitude of an effect |
| Null Hypothesis (H₀) | The hypothesis of no effect or no difference |
| Parametric Test | Assumes specific distribution (usually normal) |
| Non-Parametric Test | Makes no distribution assumptions |
| p-value | Probability of results under the null hypothesis |
| Post-hoc Test | Follow-up test after ANOVA to identify specific differences |
| Power | Probability of detecting a real effect |
| Statistical Significance | Result unlikely to occur by chance (typically p < 0.05) |
| t-test | Compares means between two groups |
| Type I Error | False positive — finding an effect that isn't real |
| Type II Error | False negative — missing a real effect |
