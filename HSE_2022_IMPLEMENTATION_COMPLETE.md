# HSE 2022 Integration - Complete Implementation Summary

## Overview

This document summarizes the complete implementation of HSE 2022 support in the hseclean package, including fixes for the 7-day cider recall calculations.

## Changes Made

### 1. R/alc_sevenday_adult.R

#### Auto-Detection of HSE 2022 Volume Data (Lines 86-100)

Added automatic detection and loading of `alc_volume_data_2022` when HSE 2022 is detected:

```r
# Auto-detect and load HSE 2022 volume data if needed
if(is_hse_2022) {
  tryCatch({
    if("alc_volume_data_2022" %in% getNamespaceExports("hseclean")) {
      alc_volume_data <- hseclean::alc_volume_data_2022
      message("Auto-detected HSE 2022: Using 2022-specific volume assumptions...")
    } else if(exists("alc_volume_data_2022", envir = .GlobalEnv)) {
      alc_volume_data <- get("alc_volume_data_2022", envir = .GlobalEnv)
      message("Auto-detected HSE 2022: Using 2022-specific volume assumptions from global environment...")
    }
  }, error = function(e) {
    message("Error loading 2022 volume data: ", e$message, ". Using default volume assumptions.")
  })
}
```

This mirrors the existing auto-detection for ABV data (lines 70-84).

#### Normal Cider Processing (Lines 200-233)

**Key Changes:**

1. **HSE 2022 Detection** (Line 103):
   ```r
   is_hse_2022 <- "d7typ3" %in% names(data) && year >= 2022
   ```

2. **Critical NA Handling Fix** (Lines 211-217):
   ```r
   # CRITICAL: Replace NAs with zeros for all respondents
   # Container types not used by a respondent are recorded as NA in the data
   # If we don't replace NA with 0, any NA * volume = NA, causing the entire calculation to fail
   data[is.na(ncidqpt7), ncidqpt7 := 0]
   data[is.na(ncidsca7), ncidsca7 := 0]
   data[is.na(ncidlca7), ncidlca7 := 0]
   data[is.na(ncidbot7), ncidbot7 := 0]
   ```

   **Previous (BROKEN):**
   ```r
   # Set to zero for non-drinkers
   data[drinks_now == "non_drinker" & is.na(ncidqpt7), `:=`(ncidqpt7 = 0)]
   # ... only replaced NAs for non-drinkers
   ```

3. **Volume Calculation** (Lines 218-228):
   ```r
   # Extract volumes before data.table operations to avoid scoping issues
   halfvol <- alc_volume_data[beverage == "nciderhalfvol", volume]
   scanvol <- alc_volume_data[beverage == "nciderscanvol", volume]
   lcanvol <- alc_volume_data[beverage == "nciderlcanvol", volume]
   btlvol <- alc_volume_data[beverage == "nciderbtlvol", volume]

   # Calculate volume for each container type
   data[d7typ3 == 1, d7vol_ncider := ncidqpt7 * halfvol * 2]  # Pints (using half-pint volume * 2)
   data[d7typ3 == 1, d7vol_ncider := d7vol_ncider + ncidsca7 * scanvol]  # Small cans
   data[d7typ3 == 1, d7vol_ncider := d7vol_ncider + ncidlca7 * lcanvol]  # Large cans
   data[d7typ3 == 1, d7vol_ncider := d7vol_ncider + ncidbot7 * btlvol]  # Bottles
   ```

#### Strong Cider Processing (Lines 237-271)

Same pattern as normal cider:
- NA handling for all container types (scidqpt7, scidsca7, scidlca7, scidbot7)
- Volume extraction to avoid scoping issues
- Volume calculation for d7typ4 == 1 (strong cider drinkers)

#### Cider Units Calculation (Lines 457-462)

```r
# HSE 2022+: Calculate cider units separately for normal and strong cider
# Normal cider uses nciderabv (~4.5%), strong cider uses sciderabv (~7.5%)
if(is_hse_2022) {
  data[age >= 16, ncider_units7 := d7vol_ncider * abv_data[beverage == "nciderabv", abv] / 1000]
  data[age >= 16, scider_units7 := d7vol_scider * abv_data[beverage == "sciderabv", abv] / 1000]
}
```

#### Peakday Calculation (Lines 477-484)

```r
if(is_hse_2022) {
  # Include cider for HSE 2022+
  data[ , peakday := nbeer_units7 + sbeer_units7 + ncider_units7 + scider_units7 +
          spirits_units7 + sherry_units7 + wine_units7 + pops_units7]
} else {
  # Pre-2022: no separate cider (cider included in beer)
  data[ , peakday := nbeer_units7 + sbeer_units7 + spirits_units7 + sherry_units7 + wine_units7 + pops_units7]
}
```

### 2. R/read_2022.R

**No changes needed** - Variable renaming was already implemented correctly:

- Lines 82-91: old_names includes `ncidpt7`, `ncidsm7`, `ncidlg7`, `ncidbt7`, `scidpt7`, `scidsm7`, `scidlg7`, `scidbt7`
- Lines 104-113: new_names maps them to `ncidqpt7`, `ncidsca7`, `ncidlca7`, `ncidbot7`, `scidqpt7`, `scidsca7`, `scidlca7`, `scidbot7`

## Root Cause of Bug

### The Problem

7-day cider calculations were producing zero units even though:
- Weekly mean showed 1,789 normal cider and 226 strong cider drinkers
- Raw data had 267 with d7typ3=1 and 37 with d7typ4=1

### Why It Happened

When respondents report drinking cider in the 7-day recall, they specify which container types they used. Container types they **didn't use** are recorded as `NA` in the data.

For example, someone who drank 3 pints of cider but no cans or bottles would have:
- `ncidqpt7 = 3`
- `ncidsca7 = NA`
- `ncidlca7 = NA`
- `ncidbot7 = NA`

The calculation was:
```r
d7vol_ncider = ncidqpt7 * 284 * 2  # = 1704
d7vol_ncider = d7vol_ncider + ncidsca7 * 330  # = 1704 + NA = NA
# Result: NA, not 1704
```

When `d7vol_ncider = NA`, the check `d7vol_ncider > 0` returns `FALSE`, so zero cider consumers were identified.

### The Fix

Replace **all** `NA` values with `0` before calculations, not just for non-drinkers:

```r
# Before (BROKEN)
data[drinks_now == "non_drinker" & is.na(ncidqpt7), `:=`(ncidqpt7 = 0)]

# After (FIXED)
data[is.na(ncidqpt7), ncidqpt7 := 0]
```

## Results After Fix

✅ **266 people** with non-zero normal cider units (expected ~267)
✅ **37 people** with non-zero strong cider units (exactly as expected)
✅ **Cider correctly included in `peakday`** calculations
✅ **All volume and ABV lookups working** correctly

### Example Output

```
Sample of people with cider in 7-day recall:
   ncider_units7  peakday
1:        1.5180   1.5180
2:       12.1440  19.6440  (includes 7.5 spirits)
3:        7.8384   7.8384
4:        3.0360   3.0360
5:        1.5180   1.5180
```

## HSE 2022 Cider Categorization

### Normal Cider (d7typ3)
- **Definition**: Cider with ABV < 6%
- **Examples**: Strongbow, Magners, Bulmers
- **ABV Assumption**: 4.5% (from abv_data_2022)
- **Container Types**:
  - Pints (ncidqpt7): 568ml (half-pint volume × 2)
  - Small cans (ncidsca7): 330ml
  - Large cans (ncidlca7): 440ml
  - Bottles (ncidbot7): 500ml

### Strong Cider (d7typ4)
- **Definition**: Cider with ABV ≥ 6%
- **Examples**: Frosty Jack's, White Lightning
- **ABV Assumption**: 7.5% (from abv_data_2022)
- **Container Types**: Same as normal cider

## Backward Compatibility

All changes are isolated within `if(is_hse_2022)` blocks, ensuring:
- ✅ Pre-2022 data continues to work as before
- ✅ Cider is included in beer for pre-2022 years (as per historical HSE convention)
- ✅ No changes to existing variable names or calculations for other beverage types

## Testing

### Test Suite
Comprehensive test suite created in `test_2022_weekmean_sevenday.R`:
- Tests both `alc_weekmean_adult()` and `alc_sevenday_adult()`
- Validates cider statistics match raw data
- Checks auto-detection of 2022-specific data
- Verifies volume and ABV lookups

### Quick Diagnostic
Alternative diagnostic script: `diagnose_is_hse_2022.R`

## Code Quality Improvements

1. **Debug messages removed** from production code
2. **Inline documentation added** explaining:
   - HSE 2022 cider split rationale
   - Critical importance of NA handling
   - Container type definitions
   - ABV assumptions
3. **Volume extraction** performed before data.table operations to avoid scoping issues
4. **Clear comments** explaining each calculation step

## Files Modified

### Production Code
- [R/alc_sevenday_adult.R](R/alc_sevenday_adult.R)
  - Lines 86-100: Volume data auto-detection
  - Lines 103: HSE 2022 detection flag
  - Lines 200-233: Normal cider processing
  - Lines 237-271: Strong cider processing
  - Lines 457-462: Cider units calculation
  - Lines 477-484: Peakday calculation with cider

### Testing/Documentation Files Created
- `test_2022_weekmean_sevenday.R`: Comprehensive test suite
- `diagnose_is_hse_2022.R`: Diagnostic script
- `diagnose_cider_renaming.R`: Variable renaming diagnostic
- `HSE_2022_CIDER_FIX_SUMMARY.md`: Initial bug fix summary
- `DEBUG_is_hse_2022_FLAG.md`: Debugging notes
- `HSE_2022_IMPLEMENTATION_COMPLETE.md`: This document

## Next Steps for Review

1. ✅ All DEBUG messages removed
2. ✅ Inline documentation added
3. ✅ Backward compatibility verified
4. ⏳ Clean up temporary diagnostic files (optional - keep for reference)
5. ⏳ Run final comprehensive test
6. ⏳ Ready for code review and merge

## Technical Notes

### Why Extract Volumes Before data.table Operations?

```r
# Good practice
halfvol <- alc_volume_data[beverage == "nciderhalfvol", volume]
data[d7typ3 == 1, d7vol_ncider := ncidqpt7 * halfvol * 2]

# Potentially problematic
data[d7typ3 == 1, d7vol_ncider := ncidqpt7 * alc_volume_data[beverage == "nciderhalfvol", volume] * 2]
```

Extracting volumes first prevents data.table from potentially looking for "beverage" and "volume" columns in the wrong scope.

### Why Half-Pint Volume × 2 for Pints?

The volume data contains half-pint volumes (284ml), so we multiply by 2 to get the pint volume (568ml). This maintains consistency with how volume assumptions are stored in the `alc_volume_data` dataset.

## References

- HSE 2022 User Guide: Documents the split of cider into normal and strong categories
- HSE 2022 data dictionary: Columns 1005-1006 (d7typ3, d7typ4) and related quantity variables
- Previous HSE years: Cider included in beer category (no separate d7typ for cider)
