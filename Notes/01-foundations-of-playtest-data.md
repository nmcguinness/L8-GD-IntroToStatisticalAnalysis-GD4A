# Foundations of Playtest Data Analysis

## Introduction

Playtesting is essential to game development, but collecting feedback is only half the challenge. The real value comes from **analysing** that data to make informed design decisions. This guide introduces the statistical concepts you need to turn raw survey responses into actionable insights.

No prior statistics or data analytics experience is assumed. We'll build from first principles using examples drawn directly from game development contexts.

---

## 1. Understanding Your Data: Types of Variables

Before analysing anything, you need to understand what kind of data you're working with. Different data types require different analytical approaches.

### 1.1 Categorical Data

Categorical data represents groups or categories with no inherent numerical value.

**Nominal Data** — Categories with no natural order.

- Platform played on: PC, PlayStation, Xbox, Switch
- Character class selected: Warrior, Mage, Rogue, Healer
- How did you hear about this game?: Social media, Friend, Advertisement, Review site

**Ordinal Data** — Categories with a meaningful order, but the gaps between them aren't necessarily equal.

- Difficulty selected: Easy, Normal, Hard, Expert
- How likely are you to recommend this game? Very Unlikely → Very Likely
- Experience level: Beginner, Intermediate, Advanced, Expert

### 1.2 Numerical Data

Numerical data represents measurable quantities.

**Discrete Data** — Whole numbers, typically counts.

- Number of deaths in a level
- Hours played per week
- Number of bugs encountered

**Continuous Data** — Can take any value within a range.

- Time to complete a level (in seconds)
- Player satisfaction score (0-100)
- Session length (in minutes)

### 1.3 The Special Case: Likert Scales

Likert scales are ubiquitous in playtest surveys:

> "The controls felt intuitive"  
> ☐ Strongly Disagree ☐ Disagree ☐ Neutral ☐ Agree ☐ Strongly Agree

Technically, Likert data is **ordinal** — the gaps between "Strongly Disagree" and "Disagree" may not equal the gap between "Neutral" and "Agree". However, when you have 5+ points on the scale and responses are reasonably distributed, it's common practice to treat Likert data as numerical (assigning values 1-5) for analysis purposes. We'll discuss the implications of this later.

---

## 2. Descriptive Statistics: Summarising Your Data

Descriptive statistics help you summarise and understand your dataset before diving deeper.

### 2.1 Measures of Central Tendency

These tell you where the "middle" of your data lies.

**Mean (Average)**

Add all values together and divide by the count.

```
Mean = Sum of all values / Number of values

Example: Player ratings of combat system (1-10)
Ratings: 7, 8, 6, 9, 7, 8, 8, 7, 6, 9
Mean = (7+8+6+9+7+8+8+7+6+9) / 10 = 75 / 10 = 7.5
```

The mean is useful but sensitive to **outliers** (extreme values). If one player rated the combat 1/10 while everyone else rated it 7-9, the mean would drop significantly.

**Median**

The middle value when data is arranged in order. If there's an even number of values, take the average of the two middle values.

```
Ratings in order: 6, 6, 7, 7, 7, 8, 8, 8, 9, 9
Median = (7 + 8) / 2 = 7.5
```

The median is **robust to outliers**. Even if one rating was 1, the median would remain 7.5.

**Mode**

The most frequently occurring value.

```
Ratings: 6, 6, 7, 7, 7, 8, 8, 8, 9, 9
Modes = 7 and 8 (both appear 3 times) — this is "bimodal"
```

Mode is particularly useful for categorical data where mean and median don't apply.

### 2.2 When to Use Each Measure

| Data Type | Recommended Measure |
|-----------|-------------------|
| Nominal (categories) | Mode |
| Ordinal (ranked categories) | Median, Mode |
| Numerical (no outliers) | Mean, Median |
| Numerical (with outliers) | Median |
| Likert scales | Median (conservative) or Mean (common practice) |

### 2.3 Measures of Spread

Central tendency alone doesn't tell the whole story. Two datasets can have the same mean but very different distributions.

**Range**

The difference between maximum and minimum values.

```
Dataset A: 5, 6, 7, 7, 8, 9, 10    Range = 10 - 5 = 5
Dataset B: 1, 7, 7, 7, 7, 7, 13   Range = 13 - 1 = 12
```

Both have a mean of 7.43, but Dataset B has more extreme responses.

**Standard Deviation (SD)**

Measures how spread out values are from the mean. A low SD means values cluster tightly around the mean; a high SD means they're more dispersed.

```
The formula is:
SD = √(Σ(x - mean)² / n)

Don't worry about calculating this by hand — spreadsheet software does it automatically.
```

**Interpreting Standard Deviation**

For normally distributed data (bell curve):
- About 68% of values fall within 1 SD of the mean
- About 95% fall within 2 SDs
- About 99.7% fall within 3 SDs

**Practical example:**

If your "enjoyment rating" has Mean = 7.0 and SD = 1.5:
- Most players (68%) rated enjoyment between 5.5 and 8.5
- Nearly all players (95%) rated it between 4.0 and 10.0

If SD = 0.5 instead:
- Most players rated enjoyment between 6.5 and 7.5 — much more consensus

---

## 3. Visualising Survey Data

Visualisation helps you spot patterns, outliers, and distributions that numbers alone might obscure.

### 3.1 Bar Charts

Best for **categorical data** and **comparing groups**.

Use when:
- Showing response counts for each option
- Comparing ratings across different game features
- Displaying demographic breakdowns

Example: "Which feature needs the most improvement?"
- Combat: 45 responses
- Story: 23 responses  
- UI: 67 responses
- Audio: 12 responses

### 3.2 Histograms

Best for **numerical data distributions**.

A histogram groups continuous data into "bins" and shows how many values fall into each bin. Unlike bar charts, the bars touch because the data is continuous.

Use when:
- Viewing the distribution of completion times
- Seeing how ratings spread across the scale
- Identifying whether data is normally distributed

### 3.3 Box Plots (Box and Whisker)

Best for **comparing distributions across groups**.

A box plot shows:
- The median (line in the box)
- The interquartile range/IQR (the box — middle 50% of data)
- The range (whiskers)
- Outliers (individual points)

Use when:
- Comparing difficulty ratings across player experience levels
- Showing how different player segments rated the same feature

### 3.4 Pie Charts

Use sparingly and only for:
- Showing parts of a whole
- When you have 2-5 categories maximum
- When proportions are meaningfully different

Avoid when comparing values precisely — humans are poor at comparing angles.

---

## 4. Distributions: The Shape of Your Data

Understanding how your data is distributed affects which statistical tests you can use.

### 4.1 Normal Distribution (Bell Curve)

Many natural phenomena follow a normal distribution:
- Most values cluster around the mean
- Symmetric — values tail off equally on both sides
- Mean = Median = Mode

Many statistical tests assume normality. When your data is normally distributed, you have more analytical options.

### 4.2 Skewed Distributions

**Positively Skewed (Right Skew)**

Tail extends to the right. Most values are low, with some high outliers.

Example: Time to find a hidden collectible — most find it quickly, a few take much longer.

Mean > Median in positively skewed data.

**Negatively Skewed (Left Skew)**

Tail extends to the left. Most values are high, with some low outliers.

Example: Tutorial completion rate — most players complete it, a few drop off early.

Mean < Median in negatively skewed data.

### 4.3 Why This Matters

If your data is heavily skewed:
- The mean may not represent a "typical" value well
- Some statistical tests become unreliable
- Consider using the median instead
- Consider non-parametric tests (covered in the next module)

---

## 5. Sampling and Representativeness

Your playtest results are only useful if your sample reasonably represents your target audience.

### 5.1 Sample vs. Population

- **Population**: Everyone who might play your game
- **Sample**: The subset who actually participated in the playtest

You're using sample data to make inferences about the population.

### 5.2 Sample Size Considerations

Larger samples generally give more reliable results. As a rough guide:

| Purpose | Minimum Sample |
|---------|----------------|
| Spotting major usability issues | 5-10 |
| Basic quantitative patterns | 30+ |
| Detecting smaller effects | 100+ |
| Subgroup comparisons | 30+ per subgroup |

These are guidelines, not rules. A sample of 20 highly engaged players providing detailed feedback may be more valuable than 200 responses from disengaged participants.

### 5.3 Bias in Sampling

Be aware of who your playtest recruits:

- **Self-selection bias**: Players who volunteer may be more engaged or more critical than average
- **Survivor bias**: Only players who didn't quit early are providing feedback
- **Platform bias**: Testing only on PC may not represent console players

Document your sample's characteristics so you can contextualise your findings.

---

## 6. Practical Exercise

You've collected playtest data with the following results for "How would you rate the game's difficulty?" (1 = Too Easy, 5 = Perfect, 9 = Too Hard):

```
Responses: 4, 5, 6, 5, 7, 5, 4, 6, 5, 8, 5, 4, 5, 6, 5, 3, 5, 6, 5, 7
```

**Calculate:**

1. Mean
2. Median  
3. Mode
4. Range
5. Describe the distribution in plain language

**Consider:**

6. Is the mean or median more appropriate here? Why?
7. What does this data suggest about your game's difficulty tuning?

---

## Summary

Before any statistical analysis, you should be able to:

1. **Identify your variable types** — categorical vs. numerical, and their subtypes
2. **Calculate descriptive statistics** — mean, median, mode, range, standard deviation
3. **Choose appropriate visualisations** — bar charts, histograms, box plots
4. **Recognise distribution shapes** — normal, skewed, and what that implies
5. **Consider your sample** — size, representativeness, and potential biases

In the next module, we'll build on these foundations to compare groups and test whether differences in your data are statistically meaningful or just random variation.

---

## Key Terms Glossary

| Term | Definition |
|------|------------|
| Categorical | Data representing groups/categories |
| Continuous | Numerical data that can take any value in a range |
| Discrete | Numerical data limited to whole numbers |
| Distribution | The pattern of how values spread across the range |
| Likert Scale | Rating scale measuring agreement/frequency/satisfaction |
| Mean | Average of all values |
| Median | Middle value when data is ordered |
| Mode | Most frequently occurring value |
| Nominal | Categorical data with no inherent order |
| Ordinal | Categorical data with meaningful order |
| Outlier | A value far from most other values |
| Population | The entire group you want to understand |
| Sample | The subset you actually collected data from |
| Skewness | Asymmetry in a distribution |
| Standard Deviation | Measure of how spread out values are from the mean |
