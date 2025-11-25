# How to Run the HSE 2019 vs 2022 Comparison

## Purpose

This script validates that HSE 2022 processing is working correctly by comparing results with HSE 2019.

## Before Running

### Step 1: Ensure You Have Both Datasets

You need:
- ✅ HSE 2022 data file (already configured in the script)
- ❓ HSE 2019 data file

### Step 2: Update File Paths

Open [HSE_2019_vs_2022_Comparison.R](HSE_2019_vs_2022_Comparison.R) and update the file paths:

#### HSE 2019 Path (Lines 54-57)

**Current setting:**
```r
data_2019 <- read_2019(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2019/UKDA-8860-tab/tab/hse_2019_eul_20211006.tab"
)
```

**Update to match your setup:**
- If HSE 2019 is in the same parent directory as HSE 2022, keep the `root` as is
- If HSE 2019 is elsewhere, update the full path

**Examples:**

```r
# Example 1: HSE 2019 in same directory structure as HSE 2022
data_2019 <- read_2019(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2019/UKDA-8860-tab/tab/hse_2019_eul_20211006.tab"
)

# Example 2: HSE 2019 on network drive (use forward slashes!)
data_2019 <- read_2019(
  root = "X:/HAR_PR/PR/Consumption_TA/HSE/",
  file = "Health_Survey_for_England_(HSE)/HSE_2019/hse_2019_eul_20211006.tab"
)

# Example 3: HSE 2019 in different local directory
data_2019 <- read_2019(
  root = "C:/Data/HSE/",
  file = "HSE_2019/hse_2019_eul_20211006.tab"
)
```

**Important:**
- Use forward slashes `/` not backslashes `\`
- Avoid spaces in paths if possible (causes issues with fread)
- If path has spaces, use underscores or remove spaces in folder names

#### HSE 2022 Path (Lines 76-79)

**Current setting:**
```r
data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)
```

This is already correct for your setup. Only update if HSE 2022 is in a different location.

---

## Running the Script

### Method 1: From RStudio/R Console

```r
source("HSE_2019_vs_2022_Comparison.R")
```

### Method 2: Step-by-step (for debugging)

```r
# 1. Load libraries and functions
library(data.table)
load("data/abv_data.rda")
load("data/abv_data_2022.rda")
load("data/alc_volume_data.rda")
source("R/read_2019.R")
source("R/read_2022.R")
source("R/clean_age.R")
source("R/alc_drink_now_allages.R")
source("R/alc_weekmean_adult.R")

# 2. Load HSE 2019
data_2019 <- read_2019(
  root = "YOUR_PATH_HERE/",
  file = "HSE_2019/UKDA-8860-tab/tab/hse_2019_eul_20211006.tab"
)

# 3. Continue with rest of script...
```

---

## Expected Output

The script will produce several comparison sections:

### 1. Overall Statistics
```
==========================================
OVERALL STATISTICS COMPARISON
==========================================

   Metric                      HSE_2019  HSE_2022  Difference  Pct_Change
1: Sample size (adults 16+)       7997      7670        -327        -4.1
2: Mean weekly units (all)       11.45     10.82       -0.63        -5.5
3: Mean weekly units (drinkers)  13.56     12.91       -0.65        -4.8
...
```

### 2. By Sex
Shows mean consumption and abstention rates for males and females.

### 3. By Age Group
Shows patterns across 8 age bands (16-19, 20-29, ..., 80+).

### 4. By IMD (Deprivation)
⚠️ Flags potentially unusual patterns in abstention by deprivation level.

### 5. Beverage-Specific
Shows changes in beer, wine, spirits, RTDs, and cider consumption.

### 6. Validation Summary
Automated checks with green/yellow/red flags.

---

## Common Errors and Solutions

### Error 1: "File does not exist"
```
Error in data.table::fread(...) :
  File 'X:/path/to/file.tab' does not exist or is non-readable
```

**Solution:**
- Check that the file path is correct
- Check that you have read permissions for the file
- Try using absolute path instead of relative path

### Error 2: "Spaces in path cause issues"
```
Taking input= as a system command because it contains a space
```

**Solution:**
- Rename folders to remove spaces, OR
- Use `file=` parameter with full absolute path:
  ```r
  data_2019 <- read_2019(
    root = "",
    file = "C:/Full/Path/Without/Spaces/hse_2019.tab"
  )
  ```

### Error 3: "select_cols argument error"
```
Error in read_2019(...) : unused argument (select_cols = ...)
```

**Solution:**
- Remove the `select_cols` parameter (it's optional)
- Or check your version of the read function

### Error 4: "Missing ABV data"
```
⚠ Warning: 2022-specific ABV data not found
Run source('create_2022_abv.R') first
```

**Solution:**
```r
source("create_2022_abv.R")
```

---

## What to Check in Results

After running the script, review the validation summary and check:

### ✅ Expected Patterns:
- Mean consumption decreases slightly (COVID effect: -5% to -15%)
- Abstention increases (+2 to +5 percentage points)
- Males drink ~1.5-2× more than females
- Peak consumption in middle age (40-60)
- U-shaped abstention pattern (high in young and old)

### ⚠️ Red Flags:
- Consumption increases (unexpected during pandemic)
- Abstention decreases
- Females drink more than males
- Unusual IMD pattern (check sample sizes)
- Massive beverage shifts (>50%)

---

## If You Don't Have HSE 2019

If you don't have access to HSE 2019 data, you can:

1. **Skip the comparison** - HSE 2022 test script alone validates basic functionality
2. **Use published HSE reports** - Compare your results with official HSE 2022 statistics when available
3. **Compare with expected ranges** - See [HSE_2019_vs_2022_VALIDATION.md](HSE_2019_vs_2022_VALIDATION.md) for expected values

---

## After Successful Run

If the comparison runs successfully and results look reasonable:

✅ HSE 2022 processing is validated
✅ Ready to proceed with package building
✅ Document any unusual patterns found (e.g., IMD abstention)

If issues are found:
- Review the specific problem areas (sex, age, IMD, etc.)
- Check data processing steps
- Consult [HSE_2019_vs_2022_VALIDATION.md](HSE_2019_vs_2022_VALIDATION.md) for troubleshooting

---

## Quick Start

**Minimum steps to run:**

1. Update line 55-56 with your HSE 2019 path
2. Run: `source("HSE_2019_vs_2022_Comparison.R")`
3. Review output for red flags
4. Check IMD abstention pattern carefully

That's it!
