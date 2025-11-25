# IMPORTANT: Run This First!

Before running the HSE 2022 test pipeline or generating figures, you need to create the 2022-specific ABV data file.

## Step 1: Create the 2022 ABV Data

Run this command in R:

```r
source("create_2022_abv.R")
```

This will:
- Create `data/abv_data_2022.rda` with the updated ABV values
- Print confirmation of the values

**Expected Output:**
```
HSE 2022 ABV data created successfully

ABV values for HSE 2022:
      beverage  abv
1:   nbeerabv  4.4
2:   sbeerabv  7.6
3:  nciderabv  4.6
4:  sciderabv  7.4
5:    wineabv 12.5
6:  sherryabv 17.5
7: spiritsabv 37.5
8:    popsabv  5.0

Changes from standard ABV assumptions:
- Normal beer: 4.0% -> 4.4% (+0.4%)
- Strong beer: 5.5% -> 7.6% (+2.1%)
- Normal cider: 4.5% -> 4.6% (NEW, +0.1% from previous unified cider)
- Strong cider: NEW at 7.4%

File saved to: data/abv_data_2022.rda
```

## Step 2: Run the Test Pipeline

Now you can run the full test:

```r
source("tests/test_hse_2022_full_pipeline.r")
```

The test will automatically detect and use the 2022-specific ABV values.

## Step 3: Generate Figures (Optional)

To create visualizations:

```r
source("HSE_2022_Generate_Figures.R")
```

---

## What If I Skip Step 1?

If you run the test without creating the 2022 ABV data first:
- **In non-package mode:** The test will use standard ABV values and print a warning
- **In package mode:** The functions will silently fall back to standard ABV values

To get the correct 2022-specific calculations, **always run Step 1 first**.

---

## For Package Development

If you're building the hseclean package:

1. First run: `source("create_2022_abv.R")`
2. Then rebuild:
   ```r
   devtools::document()
   devtools::install()
   ```
3. The 2022 ABV data will be included in the package

After rebuilding, the package will automatically use 2022 ABV values when processing HSE 2022 data.
