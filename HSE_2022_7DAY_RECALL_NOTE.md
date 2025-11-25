# HSE 2022 Seven-Day Recall - Important Note

## Key Finding

**HSE 2022 uses a different methodology for 7-day alcohol recall compared to previous years.**

## The Difference

### Previous Years (2011-2021)
- Collected **raw quantities** of alcohol consumed on heaviest drinking day
- Variables like: `nberqhp7` (half pints), `nberqsm7` (small cans), etc.
- `alc_sevenday_adult()` processes these raw quantities into units

### HSE 2022
- Provides **pre-calculated units** instead of raw quantities
- Variables like: `d7beeru` (beer units), `d7cidu` (cider units), `d7stcidu` (strong cider units)
- Raw quantity variables (`nberqhp7`, etc.) do NOT exist

## Impact on hseclean Package

### What Works
✅ **Weekly consumption (`alc_weekmean_adult`)** - Fully functional for HSE 2022
- Uses 12-month recall questions
- Includes full cider support (normal + strong)
- This is the **primary measure** for population trends

### What Doesn't Work
❌ **7-day recall (`alc_sevenday_adult`)** - Not compatible with HSE 2022
- Expects raw quantities that don't exist in HSE 2022
- Cannot calculate `peakday`, `n_days_drink`, or `binge_cat` variables

## For Your Analysis

### Population Trends Analysis
**Good news:** You don't need 7-day recall for your requested analyses!

Your requirements were:
1. ✅ Mean weekly consumption trends - Uses `weekmean` from `alc_weekmean_adult()`
2. ✅ Abstention rates - Uses `drinks_now` from `alc_drink_now_allages()`
3. ✅ Drinker risk categories - Uses `drinker_cat` from `alc_weekmean_adult()`
4. ✅ Beverage-specific trends - Uses `beer_units`, `wine_units`, etc. from `alc_weekmean_adult()`
5. ✅ Stratified analyses - All based on weekly consumption

**None of these require 7-day recall data!**

### When 7-Day Recall Matters
7-day recall is primarily used for:
- **Binge drinking analysis** (`binge_cat`)
- **Peak day consumption** (`peakday`)
- Short-term drinking patterns

If you need these for HSE 2022, you'll need to:
1. Use the pre-calculated `d7*` variables directly
2. Create a new function to process them
3. Accept that methodology differs from previous years

## Updated Test Script

The `test_hse_2022_full_pipeline.r` script now:
- ✅ Checks if raw 7-day quantities exist
- ✅ Only processes 7-day recall for years that have them
- ✅ Reports which 7-day variables ARE present in HSE 2022
- ✅ Continues successfully without 7-day processing

## Recommendations

### For Multi-Year Trends (2011-2022)

**Option 1: Skip 7-day recall (RECOMMENDED)**
```r
for(year in 2011:2022) {
  data <- read_hse(year = year, ...)
  data <- clean_age(data)
  data <- alc_drink_now_allages(data)
  data <- alc_weekmean_adult(data)
  # Skip alc_sevenday_adult() - not comparable across years anyway
}
```

**Option 2: Process 7-day only for compatible years**
```r
for(year in 2011:2022) {
  data <- read_hse(year = year, ...)
  data <- clean_age(data)
  data <- alc_drink_now_allages(data)
  data <- alc_weekmean_adult(data)

  # Only process 7-day for years with raw quantities
  if(year <= 2021) {
    data <- alc_sevenday_adult(data)
  }
}
```

## Pre-Calculated Units in HSE 2022

If you explore the data, you'll find these 7-day variables already calculated:
- `d7day` - Drank in last 7 days
- `d7many` - Number of days drank
- `d7beeru` - Beer units on heaviest day
- `d7cidu` - Normal cider units (NEW)
- `d7stcidu` - Strong cider units (NEW)
- `d7sbu` - Strong beer units
- `d7wineu` - Wine units
- `d7sherryu` - Sherry units
- `d7spiritu` - Spirits units
- `d7popsu` - RTD/alcopops units

These could be used directly if needed, but methodology differs from previous years.

## Bottom Line

**For your population-level alcohol trends analysis:**
- ✅ Use weekly consumption measures (fully supported for HSE 2022)
- ✅ All your requested analyses can be done without 7-day recall
- ⚠️ 7-day recall has methodology break in 2022
- ✅ Test scripts updated to handle this gracefully

**The hseclean package is fully functional for HSE 2022 weekly consumption analysis, which is what you need for your trends report.**
