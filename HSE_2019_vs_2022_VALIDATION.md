# HSE 2019 vs 2022 Validation Guide

## Purpose

This document explains how to validate that HSE 2022 processing is working correctly by comparing results with HSE 2019.

## Key Question: What Do the Statistics Include?

### Understanding "All Adults" vs "Drinkers Only"

**"Mean units (all adults)"**
- Includes **abstainers** who consume 0 units
- This is the **population-level mean**
- Used for public health reporting
- Will be substantially lower than "drinkers only"

**"Mean units (drinkers only)"**
- Excludes abstainers
- Only includes people who currently drink
- Shows actual consumption levels among drinkers
- More useful for comparing drinking intensity

### Example:
```
Population of 100 people:
- 20 abstainers (0 units)
- 80 drinkers (average 15 units each)

Mean (all adults) = (20×0 + 80×15) / 100 = 12 units
Mean (drinkers) = (80×15) / 80 = 15 units
```

---

## Running the Comparison

```r
source("HSE_2019_vs_2022_Comparison.R")
```

This script:
1. Loads and processes both HSE 2019 and HSE 2022
2. Uses appropriate ABV values for each year
3. Compares key statistics across multiple dimensions
4. Flags potentially unusual patterns

---

## What to Expect

### 1. Overall Consumption

**Expected pattern:**
- Slight **decrease** in mean consumption from 2019 to 2022
- COVID-19 pandemic effect (lockdowns, pub closures)
- Typical change: -5% to -15%

**Check:**
- Mean units (all): 2019 → 2022
- Mean units (drinkers): 2019 → 2022
- Both should show decrease

**Red flags:**
- ❌ Large increase (>10%)
- ❌ Dramatic decrease (>30%)

---

### 2. Abstention Rates

**Expected pattern:**
- **Increase** in abstention from 2019 to 2022
- Driven by health consciousness and COVID effects
- Typical change: +2 to +5 percentage points

**Check:**
- % Abstainers: 2019 → 2022
- Should increase across most demographic groups

**Red flags:**
- ❌ Decrease in abstention
- ❌ Implausibly high abstention (>40%)

---

### 3. Sex Differences

**Expected pattern:**
- Males drink **more** than females in both years
- Ratio typically 1.5:1 to 2:1 (male:female)
- Pattern should be consistent across years

**Check:**
- Male mean vs Female mean in both years
- Ratio should be similar across years

**Red flags:**
- ❌ Females drinking more than males
- ❌ Ratio changes dramatically (e.g., 2:1 → 1:1)

---

### 4. Age Patterns

**Expected pattern:**
- **Lowest consumption:** Youngest (16-19) and oldest (80+)
- **Peak consumption:** Middle age (40-60)
- **Highest abstention:** Youngest and oldest groups
- U-shaped or inverted-U pattern

**Check:**
- Mean consumption by age group
- Abstention rates by age group
- Pattern should be similar across years

**Red flags:**
- ❌ Peak consumption in youngest group
- ❌ Flat pattern across all ages
- ❌ Highest abstention in middle age

---

### 5. Deprivation (IMD) - ⚠️ CHECK CAREFULLY

**Expected pattern:**
- **More deprived areas:** Higher abstention, but also more heavy drinking among those who drink (polarization)
- **Less deprived areas:** Lower abstention, more moderate drinking
- Relationship can be complex

**Check:**
- Abstention rates by IMD quintile
- Mean consumption by IMD
- Look for gradient or U-shape

**⚠️ KNOWN ISSUE:**
User reported: *"Abstention percentage across IMD quintiles looks pretty wild"*

**Possible explanations:**
1. **Data issue** - Miscoded IMD values
2. **Weighting needed** - Unweighted data not representative
3. **Sample size** - Small cells producing unstable estimates
4. **Real pattern** - 2022 genuinely different due to COVID effects varying by deprivation

**What to check:**
- Sample sizes in each IMD category
- Whether pattern is consistent with 2019
- Whether weighted estimates differ from unweighted

**Note:** Both HSE 2019 and HSE 2022 use `qimd` (5 quintiles). HSE 2019 uses 2015 boundaries, HSE 2022 uses 2019 boundaries (originally `qimd19` but renamed to `qimd` during processing). Both are directly comparable as they use the same quintile structure.

---

### 6. Beverage-Specific Consumption

**Expected pattern:**
- Wine and beer typically most common
- Spirits third
- RTDs lowest (mainly young adults)
- Small changes year-to-year

**Check:**
- Beer, Wine, Spirits, RTDs mean units
- Changes should be modest (<20%)

**Special case - Cider:**
- 2019: Combined cider (all strengths)
- 2022: Split into normal (<6%) and strong (≥6%)
- Can't directly compare, but can check if split adds up sensibly

**Red flags:**
- ❌ Massive shifts (e.g., beer drops 50%)
- ❌ Negative values

---

### 7. ABV Assumptions

**Important context:**
- HSE 2019 uses **standard ABV** values
- HSE 2022 uses **2022-specific ABV** values (higher for beer and cider)

**Effect:**
- 2022 ABV assumptions will **slightly increase** unit calculations
- Same raw consumption → more units in 2022
- Typical effect: +2% to +5% on beer/cider units

**Example:**
```
Person drinks 5 pints of normal beer:

2019: 5 pints × 2 units/pint (4.0% ABV) = 10 units
2022: 5 pints × 2.2 units/pint (4.4% ABV) = 11 units

+10% increase in units from ABV change alone
```

**What this means:**
- Even if **raw consumption stayed the same**, 2022 would show **higher units**
- Actual decrease in consumption may be **larger than it appears**
- If 2022 shows -5% decline in units, actual raw consumption may have declined -10%

---

## Comparison Script Output

The script produces six sections:

### Section 1: Overall Statistics
- Sample sizes
- Mean/median consumption
- Abstention rates
- Risk categories
- Shows absolute difference and % change

### Section 2: By Sex
- Stratified by Male/Female
- Mean consumption (all and drinkers only)
- Abstention rates
- Both years side-by-side

### Section 3: By Age Group
- Uses 8 broad age bands (16-19, 20-29, ..., 80+)
- Mean consumption and abstention
- Both years side-by-side

### Section 4: By IMD
- ⚠️ Note different categorizations
- Flags potentially wild patterns
- Abstention by deprivation level

### Section 5: Beverage-Specific
- Beer, Wine, Spirits, RTDs, Cider
- Shows change in each beverage type
- Highlights cider split

### Section 6: Validation Summary
- Automated checks with expectations
- Flags items needing review
- Summary of key findings

---

## Interpreting Results

### Green Flags ✅
- Small to moderate decrease in consumption (-5% to -15%)
- Increase in abstention (+2 to +5pp)
- Males drink more than females
- Peak consumption in middle age
- Consistent patterns across years

### Yellow Flags ⚠️
- Large changes (>20%) but explainable by COVID
- Unusual IMD patterns but consistent with weighting issues
- Beverage shifts due to pub closures

### Red Flags ❌
- Increase in consumption during pandemic
- Decrease in abstention
- Females drinking more than males
- Peak consumption in oldest groups
- Negative consumption values
- Massive shifts in beverage types

---

## Common Issues and Solutions

### Issue 1: "Mean units seem too low"
**Likely cause:** Including abstainers
**Solution:** Look at "drinkers only" statistics instead

### Issue 2: "2022 consumption higher than 2019"
**Possible causes:**
1. ABV effect (2022 uses higher ABV assumptions)
2. Data quality issue
3. Sample composition difference

**Solution:** Check raw consumption frequencies, compare drinker prevalence

### Issue 3: "IMD pattern looks wild"
**Possible causes:**
1. Unweighted data
2. Small sample sizes
3. Genuine COVID effect varying by deprivation

**Solution:**
- Check sample sizes (n) in each category
- Run with survey weights if available
- Compare with 2019 pattern

### Issue 4: "Abstention rates implausibly high"
**Possible causes:**
1. Definition issue (drinks_now variable)
2. Including children or very old adults
3. Coding error

**Solution:**
- Check age filter (should be 16+)
- Verify drinks_now variable creation
- Compare with published HSE reports

---

## Published HSE Reports

For validation, compare with official HSE publications:

**HSE 2019:**
- Published report should show adult consumption patterns
- Use as benchmark for what's reasonable

**HSE 2022:**
- When published report available, compare with your results
- Should match within ~5% (survey weights may differ)

---

## Next Steps After Comparison

1. **If results look reasonable:**
   - ✅ HSE 2022 processing working correctly
   - ✅ Ready to proceed with package building
   - ✅ Document any unusual but explainable patterns

2. **If issues identified:**
   - 🔍 Investigate specific problem areas
   - 🔧 Fix data processing issues
   - 🔄 Re-run comparison
   - 📋 Document changes made

3. **If IMD pattern concerning:**
   - 📊 Check with survey weights
   - 📈 Compare cell sizes
   - 📖 Review HSE documentation on IMD changes
   - 💬 Consider contacting HSE team if pattern persists

---

## Summary

This comparison script helps you:
- ✅ Validate HSE 2022 processing is correct
- ✅ Understand population vs drinker statistics
- ✅ Identify data quality issues
- ✅ Check for implausible patterns
- ✅ Compare across multiple dimensions
- ✅ Flag areas needing investigation

**Remember:**
- "All adults" includes abstainers (0 units)
- "Drinkers only" excludes abstainers
- 2022 should show decrease vs 2019 (COVID effect)
- Abstention should increase
- IMD pattern needs careful checking
- ABV assumptions differ between years
