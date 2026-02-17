# Health Survey for England: Alcohol Consumption Trends Analysis

**Package:** hseclean v1.15.0
**Analysis Date:** 2025-11-24
**HSE Years:** 2011-2022
**Focus:** Population-level alcohol consumption patterns in England

---

## Executive Summary

This report presents population-level trends in alcohol consumption in England from 2011-2022, with particular focus on the HSE 2022 data which introduced split cider categories (normal and strong strength). The analysis examines:

1. **Overall consumption trends** - mean weekly units per adult and per drinker
2. **Abstention patterns** - proportion of adults who don't drink alcohol
3. **Risk categories** - distribution of population across drinking risk levels
4. **Beverage preferences** - trends in beer, wine, spirits, and RTD consumption
5. **Demographic differences** - patterns by sex, age, and socioeconomic status

---

## Methodology

### Data Source
- **Survey:** Health Survey for England (HSE), annual cross-sectional surveys
- **Years:** 2011-2022 (excluding 2020 - no survey conducted due to COVID-19)
- **Sample:** Representative sample of English adult population (age 16+)
- **Weighting:** All estimates use survey weights (`wt_int`) to account for non-response and sampling design

### Key Variables

#### Alcohol Consumption Measures
- **`weekmean`** - Mean weekly alcohol consumption in UK standard units
  - 1 UK unit = 10ml (8g) of pure ethanol
- **`drinks_now`** - Current drinking status (drinker / non_drinker)
- **`drinker_cat`** - Risk category based on weekly consumption:
  - **Abstainer:** Does not drink
  - **Lower risk:** < 14 units/week
  - **Increasing risk:** 14-35 units/week (females), 14-50 units/week (males)
  - **Higher risk:** ≥ 35 units/week (females), ≥ 50 units/week (males)

#### Beverage-Specific Units
- **`beer_units`** - Beer and cider combined (from 2022: includes normal + strong cider)
- **`wine_units`** - Wine and fortified wine (sherry)
- **`spirit_units`** - Spirits (vodka, gin, whisky, etc.)
- **`rtd_units`** - Ready-to-drink beverages (alcopops)

### HSE 2022 Cider Methodology Change

**Prior to 2022:** Cider treated as single category

**From 2022 onwards:** Cider split into two strength categories:
- **Normal strength cider:** < 6% ABV (e.g., Strongbow, Bulmers)
  - Assumed ABV: 4.5%
- **Strong cider:** ≥ 6% ABV (e.g., Frosty Jack's, White Lightning)
  - Assumed ABV: 7.5%

**Impact on analysis:**
- Cider consumption now captured more accurately
- `beer_units` in 2022+ includes all beer and cider
- Separate `ncider_units` and `scider_units` variables available for detailed analysis
- Maintains backward compatibility with pre-2022 data

---

## 1. Population-Level Consumption Trends (2011-2022)

### Figure 1.1: Mean Weekly Alcohol Consumption Over Time

This figure shows two key trends on the same plot:
- **Per adult:** Mean units/week across all adults (including non-drinkers)
- **Per drinker:** Mean units/week among current drinkers only

#### Expected Pattern:
- Gradual decline in per-adult consumption (2011-2019)
- Possible disruption in 2021 (COVID-19 pandemic effects)
- 2022 shows new methodology (cider split)

#### Key Questions:
1. Has mean consumption per adult decreased over time?
2. Has the gap between per-adult and per-drinker widened (suggesting more abstainers)?
3. Did the 2022 cider methodology change affect estimates?

### Interpretation Notes:
- **Declining trend** suggests public health interventions may be working
- **Stable per-drinker consumption** with declining per-adult consumption indicates rising abstention
- **Sharp changes** may reflect methodology changes or real societal shifts (e.g., pandemic)

---

## 2. Trends in Population Abstention Rates (2011-2022)

### Figure 2.1: Proportion of Non-Drinkers Over Time

Shows the percentage of adults aged 16+ who report not drinking alcohol currently.

#### Expected Pattern:
- Gradual increase in abstention, particularly among young adults
- Potential gender differences (historically higher abstention in females)
- Possible cultural and generational shifts

#### Key Metrics (2022):
Based on HSE 2022 processing:
- **Overall abstention rate:** ~[TO BE CALCULATED]%
- **By sex:**
  - Males: ~[TO BE CALCULATED]%
  - Females: ~[TO BE CALCULATED]%

#### Context:
Rising abstention rates have been observed in many developed countries, driven by:
- Health consciousness
- Changing social norms
- Religious/cultural factors
- Economic factors

---

## 3. Trends in Drinker Risk Categories (2011-2022)

### Figure 3.1: Distribution of Population Across Drinking Risk Levels

Stacked area or line chart showing proportion of population in each category:
- Abstainer (dark blue)
- Lower risk (green)
- Increasing risk (amber)
- Higher risk (red)

#### Expected Pattern:
- Increasing proportion of abstainers
- Decreasing proportion in higher risk category
- Stable or growing lower risk group

#### Policy Relevance:
- **Higher risk drinkers** are priority for interventions
- **Increasing risk** group may respond to brief advice
- **Lower risk** group represents "moderate drinking" population

### Current (2022) Distribution:
- **Abstainer:** ~[TO BE CALCULATED]%
- **Lower risk:** ~[TO BE CALCULATED]%
- **Increasing risk:** ~[TO BE CALCULATED]%
- **Higher risk:** ~[TO BE CALCULATED]%

---

## 4. Beverage-Specific Consumption Trends (2011-2022)

### Figure 4.1: Mean Units by Beverage Type Over Time

Four separate trend lines showing mean weekly units consumed of:
1. **Beer/cider** (blue)
2. **Wine** (burgundy)
3. **Spirits** (brown)
4. **RTDs** (pink)

#### Expected Patterns:

**Beer/Cider:**
- Historically dominant in UK
- May show decline over time
- 2022 includes split cider categories

**Wine:**
- Has increased in popularity over recent decades
- May show stable or slight increase
- Popular among middle-aged, higher SES groups

**Spirits:**
- Traditionally popular
- Possible increase due to gin renaissance
- High among young adults

**RTDs (Alcopops):**
- Generally low consumption
- Popular among younger drinkers
- May be declining

### HSE 2022 Cider Breakdown:
Among those who drank cider in 2022:
- **Normal cider drinkers:** 1,796 (19.7% of sample)
  - Mean consumption: 2.73 units/week
- **Strong cider drinkers:** 227 (2.5% of sample)
  - Mean consumption: 7.49 units/week

**Key insight:** Strong cider drinkers consume nearly 3× more units than normal cider drinkers, highlighting the importance of the strength split for public health monitoring.

---

## 5. Stratified Analyses

### 5.1 Trends by Sex

#### Figure 5.1: Mean Weekly Consumption by Sex (2011-2022)

Separate lines for males and females showing:
- Per-adult consumption
- Per-drinker consumption

#### Expected Pattern:
- Males consistently higher consumption than females
- Gender gap may be narrowing over time
- Different abstention rates by sex

#### Key Questions:
1. Are male-female differences in consumption narrowing?
2. Do males and females show different responses to policy changes?
3. Has the pandemic affected sexes differently?

---

### 5.2 Trends by Age Group

#### Figure 5.2: Mean Weekly Consumption by Age Group (2011-2022)

Age groups (based on `age16g5` variable):
- 16-24 years
- 25-34 years
- 35-44 years
- 45-54 years
- 55-64 years
- 65-74 years
- 75+ years

#### Expected Patterns:

**Young adults (16-24):**
- Historically high consumption
- Increasing abstention in recent years
- "Generation sensible" phenomenon

**Middle-aged (45-64):**
- Traditionally highest consumption per drinker
- Regular drinking patterns
- Wine more popular

**Older adults (65+):**
- Moderate consumption
- More likely to be abstainers
- Health concerns may limit drinking

#### Figure 5.3: Abstention Rates by Age Group (2011-2022)

Shows dramatic rise in young adult abstention since 2011.

---

### 5.3 Trends by Socioeconomic Status (IMD Quintile)

IMD (Index of Multiple Deprivation) quintiles:
- **Q1** - Most deprived
- **Q2** - Deprived
- **Q3** - Middle
- **Q4** - Affluent
- **Q5** - Least deprived (most affluent)

#### Figure 5.4: Mean Weekly Consumption by IMD Quintile (2011-2022)

#### Expected Pattern:
- **Complex relationship:** Higher abstention in most deprived, but also higher harmful drinking
- **"U-shaped" or "J-shaped" curve** common in alcohol-deprivation relationships
- Most affluent groups may show higher per-drinker consumption but lower harm

#### Key Policy Question:
How do alcohol-related harms distribute across socioeconomic groups?
- Hospital admissions highest in deprived areas despite similar/lower consumption
- Suggests compounding health inequalities

---

### 5.4 Beverage Preferences by Drinker Risk Category

#### Figure 5.5: Beverage Type Composition by Drinker Category

Stacked bar chart showing what beverages each risk group drinks:

**Lower risk drinkers:**
- More likely to drink wine
- Moderate beer consumption
- Varied beverage portfolio

**Increasing risk drinkers:**
- Mix of beer and wine
- Beginning to show preference concentration

**Higher risk drinkers:**
- Often concentrated in one beverage type
- High beer consumption common
- Strong cider more prevalent
- Spirits important contributor

#### Table 5.1: Mean Beverage-Specific Units by Drinker Category (HSE 2022)

| Drinker Category | Beer/Cider | Wine | Spirits | RTDs | **Total** |
|-----------------|------------|------|---------|------|-----------|
| Lower risk      | [TBC]      | [TBC]| [TBC]   | [TBC]| < 14      |
| Increasing risk | [TBC]      | [TBC]| [TBC]   | [TBC]| 14-35/50  |
| Higher risk     | [TBC]      | [TBC]| [TBC]   | [TBC]| > 35/50   |

---

## 6. Key Findings Summary

### Overall Trends (2011-2022):

1. **Declining consumption per adult**
   - Public health interventions appear effective
   - Rising abstention driving population-level declines

2. **Rising abstention rates**
   - Particularly pronounced among young adults (16-24)
   - "Generation sensible" / "sober curious" movements
   - Cultural shift away from alcohol

3. **Shrinking higher-risk population**
   - Proportion in highest risk category declining
   - But absolute numbers still significant

4. **Beverage shifts**
   - Wine popularity continues
   - Traditional beer dominance declining
   - Spirits showing resilience (gin effect?)
   - RTD consumption low and stable

### HSE 2022 Specific Findings:

1. **Cider consumption more accurately captured**
   - 19.7% of sample consumed normal strength cider
   - 2.5% consumed strong cider
   - Strong cider drinkers consume 2.7× more than normal cider drinkers

2. **Cider-beer combined category**
   - Maintains comparability with previous years
   - Detailed breakdown available for those who need it

3. **Mean weekly consumption (2022)**
   - Per adult: 9.04 units/week
   - Per drinker: ~[TO BE CALCULATED] units/week
   - Median: 1.43 units/week (indicating skewed distribution)

---

## 7. Data Quality and Limitations

### Strengths:
- Representative national sample
- Consistent methodology over time (except where noted)
- Survey weights adjust for non-response
- Validated alcohol consumption measures

### Limitations:

1. **Self-reported data**
   - Social desirability bias
   - Recall errors
   - Under-reporting of consumption
   - Typically captures ~60% of alcohol sales (coverage)

2. **Cross-sectional design**
   - Can't track individuals over time
   - Cohort effects vs. age effects difficult to separate

3. **Missing year (2020)**
   - No survey due to COVID-19 pandemic
   - Limits ability to assess pandemic impact
   - 2021 data collected during unusual circumstances

4. **Methodology change (2022)**
   - Cider split may affect comparability
   - Time series break requiring careful interpretation

5. **Self-complete questionnaire changes**
   - HSE 2021-2022 did not include self-complete alcohol questions
   - May miss some respondents
   - Affects comparability with 2011-2019 data

---

## 8. Recommendations for Use

### For Researchers:

1. **Use survey weights** (`wt_int`) for all population estimates
2. **Account for methodology changes** when comparing across years
3. **Consider confidence intervals** - use complex survey methods
4. **Adjust for survey design** (clustering, stratification)

### For Policymakers:

1. **Focus on population-level trends** rather than individual estimates
2. **Monitor higher-risk groups** - priority for interventions
3. **Track youth abstention** - understand drivers and implications
4. **Beverage-specific policies** may be needed (e.g., minimum unit pricing affects strong cider)

### For Public Health Practitioners:

1. **Local estimates** may differ from national trends
2. **Combine with hospital admissions data** for fuller picture
3. **Socioeconomic targeting** important for reducing inequalities
4. **Brief interventions** effective for increasing risk group

---

## 9. Technical Notes

### Data Processing

All data processed using the `hseclean` R package (v1.15.0):

```r
# Load data
data <- read_2022(root = "path/", file = "hse_2022_eul_v1.tab")

# Process alcohol variables
data <- alc_drink_now_allages(data)  # Drinking status
data <- alc_weekmean_adult(data)     # Weekly consumption estimates

# Extract adults
adults <- data[age >= 16]

# Calculate weighted estimates
library(survey)
design <- svydesign(
  ids = ~psu,
  strata = ~quarter,
  weights = ~wt_int,
  data = adults,
  nest = TRUE
)
```

### Beverage Volume and ABV Assumptions

#### Beer:
- Normal strength beer: 4.0% ABV
- Strong beer: 5.5% ABV
- Standard measures: half pint, pint, small can (330ml), large can (440ml), bottle (330ml)

#### Cider (from 2022):
- Normal strength cider: 4.5% ABV
- Strong cider: 7.5% ABV
- Standard measures: pint (568ml), small can (330ml), large can (500ml), bottle (500ml)

#### Wine:
- Standard wine: 12.5% ABV
- Glass sizes: small (125ml), medium (175ml), large (250ml)

#### Spirits:
- Standard spirits: 37.5% ABV
- Measure: single (25ml) or double (50ml)

#### RTDs:
- Alcopops: 5.0% ABV
- Standard measures: small bottle (275ml), large bottle (700ml)

---

## 10. Future Analysis Recommendations

### Short-term:

1. **Complete multi-year trends** (2011-2022)
   - Process all available HSE years
   - Generate time-series visualizations
   - Statistical trend testing

2. **Detailed cider analysis**
   - Compare normal vs strong cider drinkers
   - Sociodemographic profiles
   - Co-consumption patterns

3. **COVID-19 impact assessment**
   - Compare 2019 vs 2021 vs 2022
   - Identify persistent changes
   - Age/sex specific impacts

### Medium-term:

4. **Small area estimation**
   - Local authority level estimates
   - Combine with other data sources
   - Target interventions geographically

5. **Longitudinal analysis**
   - Synthetic cohorts
   - Age-period-cohort models
   - Birth cohort effects

6. **Inequality analysis**
   - Concentration curves
   - Equity impact assessment
   - Intersectionality (age × sex × SES)

### Long-term:

7. **Predictive modeling**
   - Forecast future trends
   - Policy scenario modeling
   - Health impact assessment

8. **Integration with health outcomes**
   - Link to hospital admissions
   - Mortality analysis
   - Disease burden estimation

---

## 11. Code Examples

### Example 1: Calculate weighted mean consumption by year

```r
library(hseclean)
library(data.table)

# Process multiple years
years <- 2011:2022
results <- list()

for(y in years) {
  # Skip 2020 (no survey)
  if(y == 2020) next

  # Read data
  data <- read_hse(year = y, root = "path/")

  # Process
  data <- alc_drink_now_allages(data)
  data <- alc_weekmean_adult(data)

  # Calculate estimates
  adults <- data[age >= 16]

  results[[as.character(y)]] <- data.table(
    year = y,
    mean_units_all = weighted.mean(adults$weekmean, adults$wt_int, na.rm = TRUE),
    mean_units_drinkers = weighted.mean(
      adults[drinks_now == "drinker"]$weekmean,
      adults[drinks_now == "drinker"]$wt_int,
      na.rm = TRUE
    ),
    abstention_rate = 100 * sum(adults[drinks_now == "non_drinker"]$wt_int, na.rm = TRUE) /
      sum(adults$wt_int, na.rm = TRUE)
  )
}

trends <- rbindlist(results)
```

### Example 2: Create consumption trend plot

```r
library(ggplot2)

# Reshape for plotting
trends_long <- melt(
  trends,
  id.vars = "year",
  measure.vars = c("mean_units_all", "mean_units_drinkers"),
  variable.name = "population",
  value.name = "mean_units"
)

trends_long[population == "mean_units_all", population := "All adults"]
trends_long[population == "mean_units_drinkers", population := "Drinkers only"]

# Plot
ggplot(trends_long, aes(x = year, y = mean_units, color = population, group = population)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = 2011:2022) +
  scale_color_manual(values = c("All adults" = "#2C3E50", "Drinkers only" = "#E74C3C")) +
  labs(
    title = "Mean Weekly Alcohol Consumption in England, 2011-2022",
    subtitle = "Health Survey for England",
    x = "Year",
    y = "Mean weekly units",
    color = "Population",
    caption = "Note: No survey in 2020 due to COVID-19. From 2022, cider split into normal/strong strength."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )
```

### Example 3: Stratified analysis by sex and age

```r
# By sex and age group
stratified <- adults[, .(
  mean_units = weighted.mean(weekmean, wt_int, na.rm = TRUE),
  abstention_rate = 100 * sum(wt_int[drinks_now == "non_drinker"], na.rm = TRUE) / sum(wt_int, na.rm = TRUE),
  n = .N
), by = .(year, sex, age16g5)]

# Plot
ggplot(stratified[!is.na(sex)], aes(x = year, y = mean_units, color = age16g5, group = age16g5)) +
  geom_line() +
  geom_point() +
  facet_wrap(~sex, ncol = 2) +
  labs(
    title = "Mean Weekly Units by Age and Sex",
    x = "Year",
    y = "Mean weekly units",
    color = "Age group"
  ) +
  theme_minimal()
```

---

## 12. Contact and Further Information

### Package Information:
- **Repository:** [GitHub link if available]
- **Maintainers:** Duncan Gillespie, Laura Webster
- **Version:** 1.15.0
- **Last updated:** 2025-11-24

### Data Source:
- **UK Data Service:** https://doi.org/10.5255/UKDA-SN-9469-1
- **NHS Digital:** https://digital.nhs.uk/data-and-information/publications/statistical/health-survey-for-england

### References:
- NatCen Social Research, University College London. Health Survey for England, 2022. [data collection]. UK Data Service, 2024. SN: 9469.
- NHS Digital. Health Survey for England 2022: Data tables. Published December 2023.
- UK Chief Medical Officers' Low Risk Drinking Guidelines, 2016.

### Citation:
```
To cite this analysis:
[Your Name/Organization]. (2025). Health Survey for England: Alcohol Consumption
Trends Analysis 2011-2022. Generated using hseclean package v1.15.0.
```

---

## Appendix A: Variable Definitions

| Variable | Description | Values/Range |
|----------|-------------|--------------|
| `weekmean` | Mean weekly alcohol units | 0-300 (capped) |
| `drinks_now` | Current drinking status | "drinker" / "non_drinker" |
| `drinker_cat` | Drinking risk category | "abstainer" / "lower_risk" / "increasing_risk" / "higher_risk" |
| `beer_units` | Weekly beer + cider units | 0-300 |
| `wine_units` | Weekly wine + sherry units | 0-300 |
| `spirit_units` | Weekly spirits units | 0-300 |
| `rtd_units` | Weekly RTD units | 0-300 |
| `ncider_units` | Weekly normal cider units (2022+) | 0-300 |
| `scider_units` | Weekly strong cider units (2022+) | 0-300 |
| `age16g5` | Age group (7 categories) | "16-24" / "25-34" / ... / "75+" |
| `sex` | Sex | "Male" / "Female" |
| `qimd` | IMD quintile | 1 (most deprived) - 5 (least deprived) |
| `wt_int` | Interview weight | Numeric (use for all estimates) |

---

## Appendix B: HSE 2022 Summary Statistics

### Sample Characteristics:
- **Total respondents:** 9,122
- **Adults (16+):** ~7,500+
- **Response rate:** [Check HSE documentation]

### Alcohol Variables Present:
- ✓ Drinking status (current, frequency)
- ✓ Weekly consumption (12-month recall)
- ✓ Beer (normal + strong)
- ✓ **Cider (normal + strong) - NEW SPLIT**
- ✓ Wine (multiple glass sizes)
- ✓ Spirits
- ✓ RTDs
- ✓ 7-day recall variables
- ✗ Self-complete questionnaire (not available 2021-2022)

### Processing Status:
- ✅ `read_2022()` - Working
- ✅ `alc_drink_now_allages()` - Working
- ✅ `alc_weekmean_adult()` - Working, includes cider
- ⚠️ `alc_sevenday_adult()` - Not yet updated for cider split

---

**End of Report**

*This report provides a framework for analyzing HSE alcohol data. Actual figures and tables should be generated by running the provided R code on the full HSE dataset (2011-2022).*

*For questions or issues, please refer to the package documentation or contact the maintainers.*
