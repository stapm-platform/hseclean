# Empty Figures - Root Cause and Fix

## Problem

Figures 5-8 in v2 and multiple figures in v3 were appearing empty or showing error:
```
Error: Continuous values supplied to discrete scale.
```

## Root Cause Discovery

Using [debug_figures.R](debug_figures.R), we discovered that:

1. **Sex variable is stored as NUMERIC (1, 2) in HSE data**, not character ("Male", "Female")
2. HSE coding: `1 = Male`, `2 = Female`
3. When attempting to convert with `factor(sex, levels = c("Male", "Female"))`, all values became NA because numeric codes `1` and `2` don't match string levels `"Male"` and `"Female"`

### Debug Output Revealed:
```r
Sex variable class: integer
Sex variable type: integer

Sex value distribution:
   1    2 <NA>
3463 4207    0

# After incorrect factor conversion:
by_sex data:
     sex mean_units     n
   <int>      <num> <int>
1:     2    7.20127  4207  # Still numeric!
2:     1   14.88590  3463

After factor(sex, levels = c("Male", "Female")):
  Male Female   <NA>
     0      0     32  # ALL VALUES BECAME NA!
```

## The Fix

### Step 1: Convert at the Start (CORRECT)

**In both v2 and v3 scripts**, immediately after creating the `adults` dataset:

```r
adults <- data_2022[age >= 16]

# IMPORTANT: Convert numeric sex codes to labeled factors
# HSE coding: 1 = Male, 2 = Female
adults[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]
```

**Key points:**
- `levels = c(1, 2)` - Matches the NUMERIC codes in the data
- `labels = c("Male", "Female")` - Assigns the string labels we want
- This creates a proper factor with levels "Male" and "Female"

### Step 2: Remove Redundant Conversions

After the initial conversion, sex is already a properly labeled factor. **Removed** all subsequent redundant conversions like:

```r
# REMOVED - No longer needed:
# by_sex[, sex := factor(sex, levels = c("Male", "Female"))]
```

## Why Previous Attempts Failed

### Attempt 1: Convert After Aggregation
```r
by_sex <- adults[, .(...), by = sex]  # sex becomes numeric after aggregation
by_sex[, sex := factor(sex, levels = c("Male", "Female"))]  # FAILS - creates NAs
```

**Problem:** Even though sex starts as 1/2, after aggregation it's still numeric. Converting `factor(1:2, levels=c("Male","Female"))` doesn't work because the levels don't match the values.

### Attempt 2: Multiple Conversions
Adding factor conversions after each aggregation was addressing the symptom, not the root cause.

## Files Fixed

### 1. [HSE_2022_Generate_Figures_v3_PUBLICATION.R](HSE_2022_Generate_Figures_v3_PUBLICATION.R)

**Line 63:** Added proper sex conversion
```r
adults[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]
```

**Lines 205, 329:** Removed redundant conversions from:
- `bev_broad` aggregation
- `abstention_broad` aggregation

### 2. [HSE_2022_Generate_Figures_v2.R](HSE_2022_Generate_Figures_v2.R)

**Line 82:** Added proper sex conversion
```r
adults[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]
```

**Lines 237, 277:** Removed redundant conversions from:
- `by_sex` aggregation
- `abstention_sex` aggregation

## Expected Result

After this fix:
- ✅ Sex variable properly labeled as "Male"/"Female" from the start
- ✅ All aggregations preserve factor labels correctly
- ✅ ggplot2 recognizes sex as discrete scale variable
- ✅ Figures render with proper data
- ✅ No more "Continuous values supplied to discrete scale" errors

## Testing

Run both scripts to verify figures are no longer empty:

```r
# Test v3 (RECOMMENDED)
source("HSE_2022_Generate_Figures_v3_PUBLICATION.R")

# Test v2
source("HSE_2022_Generate_Figures_v2.R")
```

Check that:
1. No errors about continuous/discrete scale
2. Figures 5-8 (v2) are no longer empty
3. All v3 figures show proper data
4. Sex labels appear correctly as "Male" and "Female" in legends and axes

## Lesson Learned

When working with survey data:
1. **Check variable types early** - Use `class()`, `typeof()`, and `table()` to inspect raw data
2. **Understand data coding** - HSE uses numeric codes (1/2) not strings ("Male"/"Female")
3. **Convert at source** - Fix variable types immediately after loading, not after each operation
4. **Use proper factor conversion** - Match `levels` to actual values, use `labels` for display names

## Related Files

- [debug_figures.R](debug_figures.R) - Diagnostic script that identified the root cause
- [FIGURE_GENERATION_FIXES.md](FIGURE_GENERATION_FIXES.md) - Technical details of all fixes applied
