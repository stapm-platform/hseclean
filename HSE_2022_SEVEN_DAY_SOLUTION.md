# HSE 2022 Seven-Day Recall Solution

## The Problem

HSE 2022 changed its 7-day alcohol recall methodology:
- **Previous years (2011-2021)**: Collected raw quantities (half pints, small cans, etc.)
- **HSE 2022+**: Provides pre-calculated units directly

The existing `alc_sevenday_adult()` function cannot process 2022 data because it expects raw quantities.

---

## The Solution

Created a new function: **`alc_sevenday_precalculated()`**

### What It Does

Processes 7-day recall for surveys that provide pre-calculated units:

**Input Variables (HSE 2022):**
- `d7day` - Did you drink in last 7 days?
- `d7many` - How many days did you drink?
- `d7beeru` - Beer units on heaviest day
- `d7sbu` - Strong beer units
- `d7cidu` - Normal cider units
- `d7stcidu` - Strong cider units
- `d7wineu` - Wine units
- `d7spiritu` - Spirits units
- `d7sherryu` - Sherry units
- `d7popsu` - Alcopops/RTD units

**Output Variables:**
- `n_days_drink` - Number of days drank in last 7
- `peakday` - Total units on heaviest day
- `nbeer_units7`, `sbeer_units7`, `ncider_units7`, `scider_units7`
- `wine_units7`, `spirits_units7`, `sherry_units7`, `pops_units7`
- `binge_cat` - Binge drinking category (non-drinker/below_threshold/binge)

### Usage

```r
# Load data
data_2022 <- read_2022(...)
data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)

# Process 7-day recall for HSE 2022
data_2022 <- alc_sevenday_precalculated(data_2022)

# Check output
summary(data_2022[, .(n_days_drink, peakday, binge_cat)])
```

---

## When to Use Which Function

### `alc_sevenday_adult()` ✓
**For: HSE 2011-2021 (and other surveys with raw quantities)**
- Expects: `nberqhp7`, `nberqsm7`, etc. (raw quantities)
- Calculates: Units from raw quantities using ABV/volume assumptions
- Includes: Full cider support (normal + strong)

### `alc_sevenday_precalculated()` ✓
**For: HSE 2022+ (surveys with pre-calculated units)**
- Expects: `d7beeru`, `d7cidu`, `d7stcidu`, etc. (pre-calculated units)
- Uses: Units directly from survey
- Includes: Full cider support (normal + strong)

---

## Auto-Detection Pattern

For multi-year analysis, use this pattern:

```r
for(year in 2011:2022) {
  data <- read_hse(year = year, ...)
  data <- clean_age(data)
  data <- alc_drink_now_allages(data)
  data <- alc_weekmean_adult(data)

  # Auto-detect which 7-day function to use
  if("nberqhp7" %in% names(data)) {
    # Raw quantities available - use traditional function
    data <- alc_sevenday_adult(data)
    cat(year, ": Processed 7-day recall from raw quantities\n")
  } else if("d7beeru" %in% names(data)) {
    # Pre-calculated units available - use new function
    data <- alc_sevenday_precalculated(data)
    cat(year, ": Processed 7-day recall from pre-calculated units\n")
  } else {
    cat(year, ": No 7-day recall data available\n")
  }

  # Continue with analysis...
}
```

---

## Methodology Differences

### Important Note on Comparability

The two approaches may produce **slightly different results** even for the same data because:

1. **ABV assumptions**: `alc_sevenday_adult()` uses hseclean's ABV assumptions, while pre-calculated units use survey's ABV assumptions
2. **Volume assumptions**: Raw quantity conversion uses hseclean's volume assumptions
3. **Rounding**: Pre-calculated units may have different rounding

**For trend analysis across 2011-2022**: Consider this a methodology break. Document it clearly in your analysis.

---

## Testing

To test the new function with HSE 2022:

```r
source("R/alc_sevenday_precalculated.R")

data_2022 <- read_2022(...)
data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)
data_2022 <- alc_sevenday_precalculated(data_2022)

# Check output
table(data_2022[age >= 16]$binge_cat)
summary(data_2022[age >= 16]$peakday)
```

---

## Package Integration

To include in the hseclean package:

1. **Add function**: Already created at `R/alc_sevenday_precalculated.R`
2. **Document**: Add roxygen2 documentation ✓ (already included)
3. **Export**: Add `@export` tag ✓ (already included)
4. **Update test script**: Modify to use auto-detection pattern
5. **Rebuild package**:
   ```r
   devtools::document()
   devtools::install()
   ```

---

## Summary

✅ **Created** `alc_sevenday_precalculated()` for HSE 2022+
✅ **Maintains** backward compatibility with `alc_sevenday_adult()`
✅ **Supports** full cider split (normal + strong)
✅ **Includes** auto-detection pattern for multi-year analysis
✅ **Ready** to integrate into package

The 7-day recall functionality is now complete for both old and new HSE methodologies!
