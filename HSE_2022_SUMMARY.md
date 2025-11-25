# HSE 2022 Implementation Summary

**Date:** 2025-11-18 **Package:** hseclean v1.15.0 **Status:** Phase 3 Complete - Ready for Testing

------------------------------------------------------------------------

## What We've Accomplished

### ✅ Phase 1: Basic Infrastructure

1.  **Created `read_2022.R`** - Reads HSE 2022 data with proper column ranges and variable handling
2.  **Updated `read_hse.R`** - Added support for years 2019, 2021, and 2022
3.  **Fixed cluster variable** - Changed from `cluster214` (2021) to `cluster302` (2022)
4.  **Updated package version** - DESCRIPTION now shows v1.15.0

### ✅ Phase 2: Data Assumptions

1.  **Updated `alc_abv.R`**:
    -   Added `nciderabv = 4.6%` (normal cider \< 6% ABV)
    -   Added `sciderabv = 7.4%` (strong cider ≥ 6% ABV)
    -   Added new 2022 abv table with updated beer variables to `nbeerabv = 4.4%` and `sbeerabv = 7.6%`
2.  **Updated `alc_volume.R`**:
    -   Added 8 cider volume types (4 for normal, 4 for strong)
    -   Container types: pint (568ml), small can (330ml), large can (440-500ml), bottle (500ml)

### ✅ Phase 3: Alcohol Processing

1.  **Updated `alc_weekmean_adult.R`** with complete cider support:
    -   Frequency conversion for ncider/scider
    -   Volume calculations for all container types
    -   Units conversion using ABV assumptions
    -   **Cider combined with beer** into `beer_units` category

------------------------------------------------------------------------

## Key Design Decisions

### 1. Cider Categorization

**Decision:** Combine cider with beer in the 4-category output structure

**Rationale:** - Maintains backward compatibility - Output structure unchanged: beer, wine, spirits, RTDs - `beer_units` in 2022+ includes: nbeer + sbeer + ncider + scider - Users analyzing by beverage type can still access individual components

**Alternative considered:** Create 5th category for cider - rejected due to breaking change

### 2. Year-Conditional Logic

**Implementation:** All cider processing wrapped in `if(year >= 2022)` checks

**Benefit:** - Seamless handling of pre-2022 data (no cider split) - No errors when processing older surveys - Future-proof for potential methodology changes

### 3. Variable Naming Convention

**Pattern:** After suffix removal (`_22` → `""`): - `ncider`, `scider` - frequencies - `ncidm221-4`, `scidm221-4` - container types consumed - `ncid22a-d`, `scid22a-d` - quantities - `ncider_units`, `scider_units` - calculated units

------------------------------------------------------------------------

## Files Modified

### Core Functions

-   ✅ `R/read_2022.R` - **NEW**
-   ✅ `R/read_hse.R` - Added 2019, 2021, 2022
-   ✅ `R/alc_weekmean_adult.R` - Full cider support

### Data Assumptions

-   ✅ `data-raw/Alcoholic beverage assumptions/alc_abv.R`
-   ✅ `data-raw/Alcoholic beverage assumptions/alc_volume.R`

### Package Metadata

-   ✅ `DESCRIPTION` - Version 1.15.0

### Documentation

-   ✅ `HSE_2022_IMPLEMENTATION_LOG.md` - Detailed technical log
-   ✅ `HSE_2022_SUMMARY.md` - This file
-   ✅ `rebuild_data.R` - Data rebuild script

------------------------------------------------------------------------

## What Still Needs to Be Done

### Immediate (Before First Use)

1.  **Rebuild package data** - Run `source("rebuild_data.R")` in R
2.  **Test read_2022()** - Verify data loads correctly
3.  **Document package** - Run `devtools::document()` to update Rd files

### High Priority

4.  **Check `alc_sevenday_adult.R`** - May need cider updates
5.  **Verify distributions** - Check beer/cider consumption patterns look reasonable
6.  **Test full pipeline** - Run complete cleaning workflow on 2022 data

### Medium Priority

7.  **Vaping variables** - Decide on processing approach
8.  **Update vignettes** - Document 2022 methodology changes
9.  **Add unit tests** - Test cider processing logic

### Low Priority

10. **Update README** - Add 2022 to supported years
11. **Create migration guide** - Help users transition
12. **Benchmark performance** - Ensure no slowdowns

------------------------------------------------------------------------

## How to Use (Quick Start)

### 1. Rebuild Data Files

``` r
source("rebuild_data.R")
```

### 2. Reload Package

``` r
devtools::load_all()
# OR
library(hseclean)
```

### 3. Read 2022 Data

``` r
data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)
```

### 4. Process Alcohol Data

``` r
# Load required functions
data_2022 <- clean_age(data_2022)
data_2022 <- clean_demographic(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)
data_2022 <- alc_weekmean_adult(data_2022)

# Check cider variables are present
names(data_2022)[grepl("cider", names(data_2022), ignore.case = TRUE)]

# Verify beer_units includes cider
summary(data_2022$beer_units)
```

------------------------------------------------------------------------

## Known Issues / Limitations

### Current Implementation

1.  **Self-complete questionnaire:** Cider processing only added for interview questions, not self-complete (may not be needed for 2022)
2.  **Wales/Scotland:** No cider for these countries yet (England only)
3.  **Pre-2022 unified cider:** No backward processing for older surveys that had unified cider

### Testing Gaps

1.  No unit tests yet
2.  Not tested with actual 2022 data end-to-end
3.  Distribution validation pending

------------------------------------------------------------------------

## Methodological Notes

### Cider Split Background

From HSE 2022 onwards, cider questions were restructured to match beer: - **Normal strength cider:** \< 6% ABV (typical brands: Strongbow, Bulmers, Kopparberg) - **Strong cider:** ≥ 6% ABV (typical brands: Frosty Jack's, White Lightning, strong artisan ciders)

This change affects: - Questionnaire structure - Variable naming - Processing logic - Unit conversion factors

### ABV Assumptions

Our assumptions (can be adjusted if needed): - **Normal cider:** 4.6% ABV - based on Kantar pooled data from 2018-2024, mean for off-trade sales. - **Strong cider:** 7.4% ABV - based on Kantar pooled data from 2018-2024, mean for off-trade sales.

### Volume Assumptions

Standard UK serving sizes: - **Pint:** 568ml (1 UK pint) - **Small can:** 330ml (standard) - **Large can:** 440-500ml (varies - normal=440ml, strong=500ml for higher ABV) - **Bottle:** 500ml (standard cider bottle)

------------------------------------------------------------------------

## Testing Checklist

Before considering this complete, verify:

-   [ ] `rebuild_data.R` runs without errors
-   [ ] `read_2022()` loads 2022 data successfully
-   [ ] Cider variables present in output (ncider, scider, etc.)
-   [ ] `alc_weekmean_adult()` runs on 2022 data
-   [ ] `beer_units` values are reasonable (not all zero/NA)
-   [ ] Normal cider units \< strong cider units (on average)
-   [ ] Total units comparable to 2021 levels
-   [ ] No errors with 2021 data (backward compatibility)
-   [ ] Package builds without warnings: `devtools::check()`

------------------------------------------------------------------------

## Questions to Resolve

1.  **Do we need cider in self-complete processing?** (Check if 2022 has self-complete cider questions)
2.  **Should we create separate `cider_units` output?** (Currently combined with beer)
3.  **What about `alc_sevenday_adult.R`?** (Different calculation method - needs review)
4.  **Vaping integration strategy?** (Separate function vs. integrated with smoking)

------------------------------------------------------------------------

## Contact / Maintainer Notes

This implementation follows the existing package patterns: - Year-conditional logic for new features - Backward compatibility maintained - 4-category beverage structure preserved - Clear documentation of assumptions

For questions or issues, refer to: - `HSE_2022_IMPLEMENTATION_LOG.md` - Detailed technical decisions - GitHub issues - Report bugs/feature requests - Package maintainers - Duncan Gillespie, Laura Webster

------------------------------------------------------------------------

**Status:** Ready for user testing and validation

**Last Updated:** 2025-11-24 11:30
