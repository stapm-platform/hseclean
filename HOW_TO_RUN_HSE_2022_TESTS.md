# How to Run HSE 2022 Tests

## The Problem

The installed `hseclean` package doesn't have the updated 2022 ABV code yet. You need to either:
1. Use local functions (recommended for now)
2. Rebuild and reinstall the package

---

## RECOMMENDED: Run Tests with Local Functions

### Step 1: Create the 2022 ABV Data

First, run this in R:
```r
source("create_2022_abv.R")
```

**Expected output:**
```
HSE 2022 ABV data created successfully

ABV values for HSE 2022:
      beverage  abv
1:   nbeerabv  4.4
2:   sbeerabv  7.6
3:  nciderabv  4.6
4:  sciderabv  7.4
...

File saved to: data/abv_data_2022.rda
```

### Step 2: Run the Test

The test script is already configured to use local functions by default:
```r
source("tests/test_hse_2022_full_pipeline.r")
```

You should see:
```
hseclean package not installed - using local functions
  Using 2022-specific ABV values
==========================================
HSE 2022 FULL PIPELINE TEST
==========================================
```

---

## ALTERNATIVE: Rebuild Package (For Permanent Solution)

If you want to use the installed package with 2022 support:

### Step 1: Create 2022 ABV Data
```r
source("create_2022_abv.R")
```

### Step 2: Rebuild Package
```r
devtools::document()
devtools::install()
```

### Step 3: Update Test Script

In [tests/test_hse_2022_full_pipeline.r](tests/test_hse_2022_full_pipeline.r), change line 14:
```r
USE_PACKAGE_MODE <- TRUE  # Changed from FALSE
```

### Step 4: Run Test
```r
source("tests/test_hse_2022_full_pipeline.r")
```

---

## Troubleshooting

### Error: 'abv_data_2022' is not an exported object

**Cause:** You're using the old installed package

**Solution:** Either:
- Set `USE_PACKAGE_MODE <- FALSE` in the test script (line 14)
- OR rebuild the package as described above

### Error: object 'abv_data_2022' not found

**Cause:** You didn't run `source("create_2022_abv.R")` first

**Solution:** Run Step 1 above

### Using standard ABV values instead of 2022 values

**Cause:** The file `data/abv_data_2022.rda` doesn't exist

**Solution:** Run `source("create_2022_abv.R")`

---

## Checking Which ABV Values Are Being Used

Look for these messages in the test output:

**✓ Correct (using 2022 ABV):**
```
  Using 2022-specific ABV values
```

**⚠ Not using 2022 ABV:**
```
  Using standard ABV values (2022-specific not found)
```

---

## Summary

**Quick Start (Recommended):**
1. `source("create_2022_abv.R")`
2. `source("tests/test_hse_2022_full_pipeline.r")`

The test script is already configured to use local functions and 2022 ABV data!
