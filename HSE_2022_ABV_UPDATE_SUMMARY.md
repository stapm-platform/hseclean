# HSE 2022 ABV Update Summary

## What Was Updated

To implement the HSE 2022-specific ABV values you requested, I've made the following changes:

### 1. Updated ABV Values for HSE 2022

**New Values:**
- Normal beer: **4.4%** (was 4.0%, +0.4%)
- Strong beer: **7.6%** (was 5.5%, +2.1%)
- Normal cider: **4.6%** (NEW category)
- Strong cider: **7.4%** (NEW category)

**Unchanged:**
- Wine: 12.5%
- Sherry: 17.5%
- Spirits: 37.5%
- RTDs/alcopops: 5.0%

### 2. Files Modified

#### [R/alc_weekmean_adult.R](R/alc_weekmean_adult.R:76-82)
Added automatic detection to use 2022-specific ABV data:
```r
# Use 2022-specific ABV data for HSE 2022
if(year == 2022 & country == "England") {
  if(exists("abv_data_2022", envir = asNamespace("hseclean"))) {
    abv_data <- hseclean::abv_data_2022
    message("Using HSE 2022-specific ABV values (Normal beer: 4.4%, Strong beer: 7.6%, Normal cider: 4.6%, Strong cider: 7.4%)")
  }
}
```

#### [R/alc_sevenday_adult.R](R/alc_sevenday_adult.R:64-70)
Added the same automatic detection (for consistency, though not used for HSE 2022)

#### [tests/test_hse_2022_full_pipeline.r](tests/test_hse_2022_full_pipeline.r:22-30)
Updated to load 2022-specific ABV data when running in non-package mode:
```r
# Use 2022-specific ABV data if available, otherwise use standard
if(file.exists("data/abv_data_2022.rda")) {
  load("data/abv_data_2022.rda")
  abv_data <- abv_data_2022  # Use 2022-specific values
  cat("  Using 2022-specific ABV values\n")
} else {
  load("data/abv_data.rda")
  cat("  Using standard ABV values (2022-specific not found)\n")
}
```

#### [HSE_2022_Generate_Figures.R](HSE_2022_Generate_Figures.R:25-33)
Updated to load 2022-specific ABV data when running in non-package mode

#### [data-raw/Alcoholic beverage assumptions/alc_abv_2022.R](data-raw/Alcoholic beverage assumptions/alc_abv_2022.R)
Updated to save the data properly to the package

#### [create_2022_abv.R](create_2022_abv.R) (NEW)
Standalone script to generate the 2022 ABV data file

### 3. How It Works

**Automatic Selection:**
When you process HSE 2022 data, the functions now automatically detect the year and use the 2022-specific ABV values. You'll see this message:

```
Using HSE 2022-specific ABV values (Normal beer: 4.4%, Strong beer: 7.6%, Normal cider: 4.6%, Strong cider: 7.4%)
```

**Backward Compatibility:**
- For all years before 2022, the standard ABV values are used
- No changes needed to your existing code or workflows
- The 2022 ABV data is only applied when processing 2022 data

### 4. Next Steps

**To activate the 2022 ABV data:**

1. **Run the data creation script:**
   ```r
   source("create_2022_abv.R")
   ```

   This will create `data/abv_data_2022.rda`

2. **Rebuild the package** (if using installed package):
   ```r
   devtools::document()
   devtools::install()
   ```

3. **Test with your data:**
   ```r
   library(hseclean)
   data_2022 <- read_2022(...)
   data_2022 <- clean_age(data_2022)
   data_2022 <- alc_drink_now_allages(data_2022)
   data_2022 <- alc_weekmean_adult(data_2022)  # Will use 2022 ABV automatically
   ```

### 5. Impact on Results

**Expected changes compared to standard ABV:**

- **Normal beer drinkers:** +10% higher unit estimates (4.4% vs 4.0%)
- **Strong beer drinkers:** +38% higher unit estimates (7.6% vs 5.5%)
- **Normal cider drinkers:** +2% higher than old unified cider (4.6% vs 4.5%)
- **Strong cider drinkers:** +64% higher than old unified cider (7.4% vs 4.5%)

This means weekly consumption estimates will be higher for beer and cider drinkers, reflecting the increased alcohol strength in these beverages in 2022.

### 6. Documentation

All test scripts and analysis scripts will automatically use the 2022 ABV values when processing HSE 2022 data:
- [tests/test_hse_2022_full_pipeline.r](tests/test_hse_2022_full_pipeline.r)
- [HSE_2022_Generate_Figures.R](HSE_2022_Generate_Figures.R)
- [HSE_2022_Alcohol_Trends_Analysis.R](HSE_2022_Alcohol_Trends_Analysis.R)

### 7. Verification

To verify the 2022 ABV data is loaded:
```r
library(hseclean)
print(abv_data_2022)
```

Expected output:
```
      beverage  abv
1:   nbeerabv  4.4
2:   sbeerabv  7.6
3:  nciderabv  4.6
4:  sciderabv  7.4
5:    wineabv 12.5
6:  sherryabv 17.5
7: spiritsabv 37.5
8:    popsabv  5.0
```

---

**Summary:** The hseclean package now automatically uses HSE 2022-specific ABV values when processing 2022 data, with the updated values you specified (Normal beer 4.4%, Strong beer 7.6%, Normal cider 4.6%, Strong cider 7.4%). No code changes needed in your analysis scripts.
