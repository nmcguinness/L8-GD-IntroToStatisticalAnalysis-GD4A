# Practical Analysis: Tools, Workflow, and Reporting

## Introduction

You now understand the statistical concepts behind playtest data analysis. This final module covers the practical side: how to actually perform these analyses using accessible tools, structure your analytical workflow, and communicate findings to inform design decisions.

---

## 1. Tools for Playtest Data Analysis

### 1.1 Spreadsheet Software (Excel / Google Sheets)

For most playtest analysis, spreadsheet software is sufficient and accessible.

**Advantages:**
- Familiar interface
- Built-in statistical functions
- Easy data visualisation
- Shareable with non-technical team members
- Google Sheets is free and collaborative

**Limitations:**
- Advanced tests may require add-ons
- Large datasets (10,000+ rows) can slow down
- Less reproducible than code-based approaches

**Recommendation for this module**: Google Sheets — free, accessible, and has the Data Analysis ToolPak equivalent built in.

### 1.2 Key Statistical Functions in Spreadsheets

**Descriptive Statistics:**

| Function | Google Sheets | Excel |
|----------|---------------|-------|
| Mean | `=AVERAGE(range)` | `=AVERAGE(range)` |
| Median | `=MEDIAN(range)` | `=MEDIAN(range)` |
| Mode | `=MODE(range)` | `=MODE.SNGL(range)` |
| Standard Deviation (sample) | `=STDEV(range)` | `=STDEV.S(range)` |
| Count | `=COUNT(range)` | `=COUNT(range)` |
| Min | `=MIN(range)` | `=MIN(range)` |
| Max | `=MAX(range)` | `=MAX(range)` |

**Statistical Tests:**

| Test | Google Sheets | Excel |
|------|---------------|-------|
| t-test (independent) | `=TTEST(range1, range2, 2, 2)` | `=T.TEST(range1, range2, 2, 2)` |
| t-test (paired) | `=TTEST(range1, range2, 2, 1)` | `=T.TEST(range1, range2, 2, 1)` |
| Correlation (Pearson) | `=CORREL(range1, range2)` | `=CORREL(range1, range2)` |
| Chi-Square | `=CHISQ.TEST(observed, expected)` | `=CHISQ.TEST(observed, expected)` |

**Note on TTEST parameters:**
- Third parameter (tails): 1 = one-tailed, 2 = two-tailed (use 2 unless you have strong directional hypothesis)
- Fourth parameter (type): 1 = paired, 2 = independent equal variance, 3 = independent unequal variance

### 1.3 When to Consider More Advanced Tools

Consider Python, R, or SPSS when you need:
- ANOVA and post-hoc tests (limited in basic spreadsheets)
- Non-parametric tests beyond basic options
- Automated reporting across multiple datasets
- Reproducible analysis pipelines
- Analysis of very large datasets

For Y4 projects, spreadsheets will handle most needs. Document your process for reproducibility.

---

## 2. Structuring Your Data

### 2.1 Tidy Data Principles

Organise data so that:
- Each variable has its own column
- Each observation (participant) has its own row
- Each type of observational unit forms a table

**Good structure:**

| Participant_ID | Age | Platform | Tutorial_Completed | Satisfaction | Playtime_Hours |
|----------------|-----|----------|-------------------|--------------|----------------|
| P001 | 24 | PC | Yes | 8 | 4.5 |
| P002 | 19 | Console | No | 5 | 1.2 |
| P003 | 31 | PC | Yes | 7 | 6.8 |

**Poor structure:**

| Metric | P001 | P002 | P003 |
|--------|------|------|------|
| Age | 24 | 19 | 31 |
| Satisfaction | 8 | 5 | 7 |

The "wide" format in the poor example makes statistical analysis difficult.

### 2.2 Coding Categorical Variables

Convert text responses to consistent codes:

| Original | Coded |
|----------|-------|
| "Yes", "yes", "YES", "Y" | 1 |
| "No", "no", "N" | 0 |
| "PC", "Computer", "Desktop" | "PC" |

Create a codebook documenting all conversions.

### 2.3 Handling Missing Data

Missing responses are inevitable. Options:

**Listwise deletion**: Exclude any participant with missing data
- Simple but loses information
- Appropriate if missing data is random and minimal (<5%)

**Pairwise deletion**: Use all available data for each analysis
- Maximises data use
- Sample sizes vary across analyses (report this)

**Imputation**: Replace missing values with estimates (mean, median)
- Preserves sample size
- Can introduce bias
- Advanced techniques exist but are beyond this scope

**Recommendation**: Use pairwise deletion for playtest analysis and clearly report sample sizes for each analysis.

---

## 3. Analysis Workflow: A Step-by-Step Approach

### Step 1: Define Your Questions

Before touching the data, write down:
- Primary research questions (2-3 maximum)
- Secondary/exploratory questions
- What would change your design decisions?

**Example primary questions:**
1. Does the tutorial improve player retention?
2. Which difficulty mode provides the best player experience?
3. What predicts overall satisfaction?

### Step 2: Clean and Prepare Data

1. Import data from survey tool (export as CSV)
2. Check for duplicate responses (same participant ID)
3. Identify and handle outliers (data entry errors vs. genuine extreme values)
4. Code categorical variables consistently
5. Create any calculated fields (e.g., total_playtime from multiple sessions)
6. Document all cleaning decisions

### Step 3: Exploratory Analysis

Before hypothesis testing:
- Calculate descriptive statistics for all variables
- Visualise distributions (histograms)
- Visualise relationships (scatter plots, grouped bar charts)
- Note any unexpected patterns

This stage generates insights and helps you check assumptions.

### Step 4: Confirmatory Analysis

Run the statistical tests for your primary research questions:
- Document which test and why
- Check assumptions
- Record full results (test statistic, df, p-value, effect size)

### Step 5: Exploratory Follow-Up

Investigate unexpected findings or secondary questions. Clearly label these as exploratory (not hypothesis-driven).

### Step 6: Document and Report

See Section 5 for reporting guidance.

---

## 4. Worked Example: Full Analysis Walkthrough

### The Scenario

You've conducted a playtest with 60 participants for a puzzle-platformer. Your survey collected:
- Demographics (age, experience level)
- Tutorial completion (yes/no)
- Difficulty selected (Easy/Normal/Hard)
- Satisfaction with puzzles (1-10)
- Satisfaction with platforming (1-10)
- Overall enjoyment (1-10)
- Playtime (minutes)

**Research Questions:**
1. Does tutorial completion affect overall enjoyment?
2. Does satisfaction differ across difficulty levels?
3. What predicts overall enjoyment?

### Step-by-Step in Google Sheets

**Setting Up:**

1. Create a sheet named "Raw_Data" with your cleaned data
2. Create a sheet named "Analysis" for your calculations
3. Create a sheet named "Visualisations" for charts

**Question 1: Tutorial Completion and Enjoyment**

In your Analysis sheet:

```
A1: Question 1: Tutorial Completion and Enjoyment
A2: 
A3: Tutorial Group
A4: Mean
A5: SD  
A6: n
A7:
A8: No Tutorial Group
A9: Mean
A10: SD
A11: n
A12:
A13: t-test p-value
A14: Cohen's d

B3: =AVERAGEIF(Raw_Data!C:C, "Yes", Raw_Data!G:G)
B4: [SD formula using STDEV with IF logic, or filter data first]
B5: =COUNTIF(Raw_Data!C:C, "Yes")

B8: =AVERAGEIF(Raw_Data!C:C, "No", Raw_Data!G:G)
...

B13: =TTEST(tutorial_range, no_tutorial_range, 2, 2)
B14: =(B3-B8)/SQRT((B4^2+B9^2)/2)  [approximate Cohen's d]
```

**Tip**: For complex analyses, create helper columns that filter data by group, then run statistics on those filtered columns.

**Question 2: Difficulty and Satisfaction**

ANOVA isn't available as a simple function. Options:
1. Use the ANOVA tool in Excel's Data Analysis ToolPak
2. In Google Sheets, use an add-on (XLMiner Analysis ToolPak)
3. Run pairwise t-tests with Bonferroni correction (0.05/3 = 0.017)

For three groups (Easy, Normal, Hard), with Bonferroni-corrected t-tests:

```
Compare Easy vs Normal: p = ?
Compare Normal vs Hard: p = ?
Compare Easy vs Hard: p = ?

Significant if p < 0.017
```

**Question 3: Predictors of Enjoyment**

Calculate correlations between enjoyment and:
- Puzzle satisfaction
- Platforming satisfaction
- Playtime

```
=CORREL(puzzle_satisfaction_range, enjoyment_range)
=CORREL(platforming_satisfaction_range, enjoyment_range)
=CORREL(playtime_range, enjoyment_range)
```

Visualise with scatter plots.

---

## 5. Reporting Your Findings

### 5.1 Structure of a Playtest Analysis Report

**Executive Summary** (1 paragraph)
- Key findings
- Recommended actions

**Method**
- Sample description (n, demographics)
- Survey instrument overview
- Analysis approach

**Results by Research Question**
- Descriptive statistics
- Test results with effect sizes
- Visualisations

**Discussion**
- Practical implications
- Limitations
- Recommended design changes

**Appendix**
- Full survey instrument
- Additional tables/figures
- Raw data summary

### 5.2 Writing About Statistics Clearly

Your audience (designers, producers) may not have statistical training. Translate findings into plain language.

**Too technical:**
"A one-way ANOVA revealed a statistically significant difference in satisfaction across difficulty conditions, F(2, 57) = 4.82, p = .012, η² = .14."

**Better:**
"Players on different difficulty settings reported significantly different satisfaction levels. Those on Normal difficulty (M = 7.8) were notably happier than those on Hard (M = 6.2), with Easy falling in between (M = 7.1). This difference was unlikely due to chance (p = .012) and represents a meaningful effect in practical terms."

### 5.3 Effective Visualisation for Reports

**Do:**
- Use clear titles that state the finding ("Normal Difficulty Shows Highest Satisfaction")
- Label axes clearly with units
- Include sample sizes
- Use consistent colour schemes
- Choose the right chart type for the data

**Don't:**
- Use 3D effects
- Include unnecessary gridlines or decorations
- Use pie charts for more than 4-5 categories
- Let Excel/Sheets auto-scale axes in misleading ways

### 5.4 Presenting Uncertainty

Always acknowledge:
- Sample size and its limitations
- Results that didn't reach significance (absence of evidence ≠ evidence of absence)
- Alternative explanations
- What you'd need to investigate further

**Example:**
"While we found no significant difference between control schemes (p = .23), our sample of 40 may have been too small to detect subtle differences. A larger follow-up study could confirm whether the schemes truly perform equivalently."

---

## 6. Common Pitfalls and How to Avoid Them

### 6.1 P-Hacking

**Problem**: Testing many combinations until something is significant.

**Symptoms:**
- "We compared 15 different metrics and found that players who prefer blue interfaces had higher satisfaction!"
- Testing until you hit p < 0.05, then stopping

**Solution:**
- Pre-specify your hypotheses
- Distinguish confirmatory from exploratory analysis
- Apply multiple comparison corrections
- Report all tests run, not just significant ones

### 6.2 Confusing Correlation with Causation

**Problem**: Concluding X causes Y from correlational data.

**Example**: Playtime correlates with satisfaction. Did more play cause higher satisfaction, or did higher satisfaction cause more play?

**Solution:**
- Use causal language ("causes", "leads to") only with experimental manipulation
- Use relational language ("is associated with", "predicts") for correlations
- Consider and discuss alternative explanations

### 6.3 Over-Relying on Statistical Significance

**Problem**: Treating p < 0.05 as the only thing that matters.

**Solution:**
- Always report effect sizes
- Consider practical significance
- A non-significant result with a meaningful effect size + small sample warrants further investigation, not dismissal

### 6.4 Ignoring Assumptions

**Problem**: Running tests on data that violates their assumptions.

**Common violations:**
- Using parametric tests on heavily skewed data
- Using chi-square with small expected counts
- Treating ordinal data as interval without consideration

**Solution:**
- Visualise your data first
- Check assumptions explicitly
- Use non-parametric alternatives when needed
- Report what you did and why

### 6.5 Survivorship Bias

**Problem**: Only analysing data from players who completed the survey.

**Example**: "Players rated satisfaction 7.5/10!" — but only the 30% who didn't quit early filled out the survey.

**Solution:**
- Track response rates
- Consider who didn't respond
- Collect in-game metrics alongside surveys
- Note limitations in reporting

---

## 7. Ethical Considerations

### 7.1 Informed Consent

Playtest participants should know:
- What data you're collecting
- How it will be used
- That participation is voluntary
- How to withdraw

### 7.2 Anonymity and Privacy

- Remove personally identifiable information before analysis
- Report aggregated results, not individual responses
- Store raw data securely
- Comply with GDPR if collecting from EU participants

### 7.3 Honest Reporting

- Don't cherry-pick results that support your preferred design
- Report negative findings
- Acknowledge limitations
- Distinguish exploratory findings from confirmed hypotheses

---

## 8. Quick Reference: Analysis Checklist

### Before Analysis
- [ ] Research questions defined
- [ ] Data cleaned and coded
- [ ] Codebook created
- [ ] Missing data documented

### Descriptive Phase
- [ ] Means, medians, SDs calculated
- [ ] Distributions visualised
- [ ] Sample sizes confirmed
- [ ] Outliers examined

### Inferential Phase
- [ ] Appropriate test selected
- [ ] Assumptions checked
- [ ] Test conducted
- [ ] Effect size calculated
- [ ] Results documented with full statistics

### Reporting Phase
- [ ] Executive summary written
- [ ] Methods described
- [ ] Results presented with visualisations
- [ ] Effect sizes and practical significance discussed
- [ ] Limitations acknowledged
- [ ] Recommendations provided

---

## 9. Template: Playtest Analysis Report

```markdown
# [Game Title] Playtest Analysis Report
**Date:** [Date]  
**Analyst:** [Name]  
**Version:** [Build/Version tested]

## Executive Summary
[2-3 sentences: Key findings and primary recommendations]

## Sample
- **Total participants:** n = X
- **Demographics:** [Age range, experience levels, platforms]
- **Recruitment:** [How participants were recruited]
- **Completion rate:** [X% completed full survey]

## Research Questions
1. [Primary question]
2. [Primary question]
3. [Secondary/exploratory questions]

## Results

### Question 1: [Question text]
**Method:** [Test used and why]  
**Findings:**  
- Group A: M = X.X, SD = X.X, n = X
- Group B: M = X.X, SD = X.X, n = X
- Test result: [statistic], p = [value], effect size = [value]

**Interpretation:** [Plain language explanation]

[Visualisation]

### Question 2: [Repeat structure]

## Exploratory Findings
[Unexpected patterns worth noting, clearly labelled as exploratory]

## Limitations
- [Sample limitations]
- [Measurement limitations]
- [Generalisability caveats]

## Recommendations
1. **[Specific actionable recommendation]** — based on [finding]
2. **[Specific actionable recommendation]** — based on [finding]
3. **[Suggestion for follow-up testing]**

## Appendix
- Survey instrument
- Full statistical tables
- Additional visualisations
```

---

## 10. Practical Exercise: End-to-End Analysis

Using the sample dataset provided (or your own playtest data):

1. **Clean the data** — identify and handle missing values, code categorical variables
2. **Explore** — calculate descriptive statistics, create visualisations
3. **Test one hypothesis** — choose appropriate test, check assumptions, calculate effect size
4. **Write a mini-report** — one page summarising your finding with visualisation

---

## Summary

You can now:

1. **Use spreadsheet tools** to perform statistical analyses
2. **Structure data properly** for analysis
3. **Follow a systematic workflow** from questions to findings
4. **Report results effectively** for non-technical audiences
5. **Avoid common analytical pitfalls**
6. **Apply ethical data practices**

These skills transfer beyond playtesting to any data-driven decision making in game development and beyond.

---

## Further Resources

**Books:**
- Field, A. — *Discovering Statistics Using IBM SPSS Statistics* (comprehensive, accessible)
- Sauro, J. & Lewis, J. — *Quantifying the User Experience* (practical UX focus)

**Online:**
- Laerd Statistics (https://statistics.laerd.com) — test selection and how-to guides
- Khan Academy Statistics — free video courses on fundamentals

**Tools:**
- Google Sheets (free)
- JASP (https://jasp-stats.org) — free, user-friendly statistical software
- R + RStudio (free, powerful, steeper learning curve)

---

## Comprehensive Glossary

| Term | Definition |
|------|------------|
| ANOVA | Analysis of variance; compares means across three or more groups |
| Assumption | Condition that must be met for a test to be valid |
| Bonferroni Correction | Adjusts significance threshold when making multiple comparisons |
| Categorical Variable | Variable representing group membership or categories |
| Chi-Square Test | Tests association between two categorical variables |
| Codebook | Documentation of how variables are coded and defined |
| Cohen's d | Standardised measure of effect size for mean differences |
| Confidence Interval | Range likely to contain the true population value |
| Confounding Variable | Unmeasured variable that affects both X and Y |
| Correlation | Measure of linear relationship between two variables |
| Cramér's V | Effect size measure for chi-square tests |
| Degrees of Freedom | Number of values free to vary in a calculation |
| Dependent Variable | Outcome variable you're trying to explain |
| Descriptive Statistics | Numbers that summarise your data (mean, SD, etc.) |
| Effect Size | Magnitude of a difference or relationship |
| Exploratory Analysis | Data-driven investigation without pre-specified hypotheses |
| Histogram | Visualisation of numerical data distribution |
| Hypothesis | Testable prediction about your data |
| Independent Variable | Variable you manipulate or use to group participants |
| Inferential Statistics | Tests that help generalise from sample to population |
| Interquartile Range | Middle 50% of data; used in box plots |
| Likert Scale | Rating scale measuring agreement, frequency, or satisfaction |
| Listwise Deletion | Removing cases with any missing data |
| Mean | Average value |
| Median | Middle value when data is ordered |
| Mode | Most frequent value |
| Non-Parametric Test | Statistical test that doesn't assume normal distribution |
| Normal Distribution | Symmetric, bell-shaped distribution |
| Null Hypothesis | Assumption of no effect or difference |
| Outlier | Unusually extreme value |
| P-Hacking | Manipulating analysis to achieve significance |
| P-Value | Probability of results if null hypothesis is true |
| Paired Data | Two measurements from the same participants |
| Parametric Test | Statistical test assuming specific distribution |
| Population | Entire group you want to understand |
| Post-Hoc Test | Follow-up test after significant ANOVA |
| Power | Probability of detecting a real effect |
| Range | Difference between maximum and minimum values |
| Sample | Subset of population you collected data from |
| Scatter Plot | Visualisation of relationship between two numerical variables |
| Skewness | Asymmetry in a distribution |
| Standard Deviation | Measure of spread around the mean |
| Statistical Significance | Result unlikely to occur by chance (conventionally p < .05) |
| Survivorship Bias | Analysing only successful/completing cases |
| T-Test | Compares means between two groups |
| Tidy Data | Data organised with variables in columns, observations in rows |
| Type I Error | False positive; finding effect that doesn't exist |
| Type II Error | False negative; missing effect that does exist |
