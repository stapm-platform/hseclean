# Troubleshooting: Age Variable Error

## Error Message
```
Error in .checkTypos(e, names_x) :
  Object 'age' not found.
```

## Cause
The `age` variable is not automatically present in HSE data files. It must be created by running `clean_age()` before any other processing functions.

## Solution

**Always include `clean_age()` in your processing pipeline:**

```r
library(hseclean)

# Read data
data <- read_2022(...)

# ✓ Clean age FIRST (creates 'age' variable)
data <- clean_age(data)

# Now other functions will work
data <- alc_drink_now_allages(data)
data <- alc_weekmean_adult(data)
data <- alc_sevenday_adult(data)
```

## Why This Happens

### HSE 2015+ Data Structure
- From 2015 onwards, HSE no longer provides age in single years (for privacy)
- Instead, they provide age groups: `age16g5`, `age35g`, `age_cat`, etc.
- The `clean_age()` function processes these and creates a consistent `age` variable

### What `clean_age()` Does
1. Creates `age` variable (single years for pre-2015, NA for 2015+)
2. Creates `age_cat` variable (age categories)
3. Standardizes age groupings across different HSE years
4. Creates birth cohort variables

### Functions That Need `age`
Most hseclean functions expect an `age` variable:
- `alc_drink_now_allages()` - filters by age
- `alc_weekmean_adult()` - filters adults (age >= 16)
- `alc_sevenday_adult()` - filters adults
- `alc_sevenday_child()` - filters children
- Various smoking functions

## Standard Processing Pipeline

The correct order is:

```r
# 1. Read data
data <- read_2022(...)  # or read_2021(), read_2019(), etc.

# 2. Clean age (REQUIRED)
data <- clean_age(data)

# 3. Clean demographics (optional but recommended)
data <- clean_demographic(data)

# 4. Process alcohol
data <- alc_drink_now_allages(data)
data <- alc_weekmean_adult(data)
data <- alc_sevenday_adult(data)

# 5. Process smoking (if needed)
data <- smk_status(data)
data <- smk_amount(data)
```

## Test Scripts Updated

Both test scripts have been updated to include `clean_age()`:

1. **`tests/test_hse_2022.r`** - Basic test
   - Now includes TEST 3.5: Clean age variables

2. **`tests/test_hse_2022_full_pipeline.r`** - Comprehensive test
   - Now includes PART 1B: Clean Age Variables

## Multi-Year Processing

When processing multiple years, always include `clean_age()`:

```r
years <- 2011:2022

for(y in years) {
  data <- read_hse(year = y, ...)

  # REQUIRED
  data <- clean_age(data)

  # Process alcohol
  data <- alc_drink_now_allages(data)
  data <- alc_weekmean_adult(data)

  # ... analysis
}
```

## Quick Checklist

Before running alcohol processing functions, ensure:
- [x] Data loaded with `read_2022()` or equivalent
- [x] `clean_age()` has been run
- [ ] Proceed with alcohol functions

If you get "Object 'age' not found" error:
1. Check if `clean_age()` was called
2. Check if it ran successfully
3. Verify: `"age" %in% names(data)` should be TRUE

## Additional Notes

### For Package Users
If using the installed `hseclean` package, no need to source files:
```r
library(hseclean)
data <- read_2022(...)
data <- clean_age(data)  # Function available from package
```

### For Development Mode
If using sourced functions (devtools::load_all()):
```r
source("R/read_2022.R")
source("R/clean_age.R")  # Must source this too!
source("R/alc_drink_now_allages.R")
# etc.
```

---

**Bottom line:** Always run `clean_age()` immediately after reading HSE data, before any other processing.
