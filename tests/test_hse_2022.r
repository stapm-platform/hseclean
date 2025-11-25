# HSE 2022 Testing Script
#
# IMPORTANT: Before running this script, install the package locally:
#   In RStudio: Ctrl+Shift+B (Build & Reload)
#   Or in R console: devtools::load_all() or devtools::install()
#
# If you can't install, this script will try to load functions directly


# Load required libraries
library(data.table)
library(stringr)
library(Hmisc)

# Try to load the hseclean package
if (requireNamespace("hseclean", quietly = TRUE)) {
  cat("Using installed hseclean package\n")
  library(hseclean)
  USE_PACKAGE <- TRUE
} else {
  cat("hseclean package not installed - using local functions\n")
  cat("For best results, install the package with: devtools::install() or devtools::load_all()\n\n")
  USE_PACKAGE <- FALSE

  # Load data manually
  load("data/abv_data.rda")
  load("data/alc_volume_data.rda")

  # Source the functions we need
  source("R/alc_drink_freq.R")
  source("R/read_2022.R")
  source("R/alc_drink_now_allages.R")
  source("R/alc_weekmean_adult.R")
}

cat("==========================================\n")
cat("HSE 2022 TESTING\n")
cat("==========================================\n\n")

# Test 1: Read 2022 data
cat("TEST 1: Reading HSE 2022 data...\n")
data_2022 <- read_2022(
  root = c("X:/", "/Volumes/Shared/")[1],
  file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab",
  select_cols = c("tobalc")
)

cat("✓ Data loaded successfully\n")
cat("  Dimensions:", dim(data_2022)[1], "rows x", dim(data_2022)[2], "columns\n")
cat("  Year:", unique(data_2022$year), "\n")
cat("  Country:", unique(data_2022$country), "\n\n")

# Test 2: Check cider variables present
cat("TEST 2: Checking cider variables...\n")
cider_vars <- names(data_2022)[grepl("cid", names(data_2022), ignore.case = TRUE)]
cat("  Cider variables found:", length(cider_vars), "\n")
cat("  Examples:\n")
print(head(cider_vars, 20))
cat("\n")

# Test 3: Check key demographic variables
cat("TEST 3: Checking key variables...\n")
key_vars <- c("hse_id", "age16g5", "sex", "year", "country", "psu", "cluster", "wt_int")
missing_vars <- key_vars[!key_vars %in% names(data_2022)]
if (length(missing_vars) == 0) {
  cat("✓ All key variables present\n\n")
} else {
  cat("✗ Missing variables:", paste(missing_vars, collapse = ", "), "\n\n")
}

# Test 4: Process the data through the pipeline
cat("TEST 4: Processing alcohol data...\n")
cat("  Running alc_drink_now_allages()...\n")
hse22 <- alc_drink_now_allages(data_2022)
cat("  Running alc_weekmean_adult()...\n")

# If using sourced functions (not installed package), pass data explicitly
if (!USE_PACKAGE) {
  hse22_processed <- alc_weekmean_adult(hse22,
    abv_data = abv_data,
    volume_data = alc_volume_data
  )
} else {
  hse22_processed <- alc_weekmean_adult(hse22)
}
cat("✓ Processing complete\n\n")

# Test 5: Check output variables
cat("TEST 5: Checking output alcohol variables...\n")
alc_vars <- c(
  "nbeer_units", "sbeer_units", "ncider_units", "scider_units",
  "beer_units", "wine_units", "spirits_units", "rtd_units", "weekmean"
)
present_alc <- alc_vars[alc_vars %in% names(hse22_processed)]
cat("  Output variables present:", paste(present_alc, collapse = ", "), "\n")
missing_alc <- alc_vars[!alc_vars %in% names(hse22_processed)]
if (length(missing_alc) > 0) {
  cat("  Missing:", paste(missing_alc, collapse = ", "), "\n")
}
cat("\n")

# Test 6: Check cider distributions
cat("TEST 6: Checking cider distributions...\n")
if ("ncider_units" %in% names(hse22_processed) & "scider_units" %in% names(hse22_processed)) {
  ncider_drinkers <- sum(hse22_processed$ncider_units > 0, na.rm = TRUE)
  scider_drinkers <- sum(hse22_processed$scider_units > 0, na.rm = TRUE)
  cat("  Normal cider drinkers:", ncider_drinkers, "\n")
  cat("  Strong cider drinkers:", scider_drinkers, "\n")
  cat(
    "  Mean normal cider units (among drinkers):",
    round(mean(hse22_processed$ncider_units[hse22_processed$ncider_units > 0], na.rm = TRUE), 2), "\n"
  )
  cat(
    "  Mean strong cider units (among drinkers):",
    round(mean(hse22_processed$scider_units[hse22_processed$scider_units > 0], na.rm = TRUE), 2), "\n"
  )
}
cat("\n")

# Test 7: Check total weekly units
cat("TEST 7: Checking total weekly alcohol consumption...\n")
if ("weekmean" %in% names(hse22_processed)) {
  cat(
    "  Mean weekly units (all respondents):",
    round(mean(hse22_processed$weekmean, na.rm = TRUE), 2), "\n"
  )
  cat(
    "  Median weekly units:",
    round(median(hse22_processed$weekmean, na.rm = TRUE), 2), "\n"
  )
  cat(
    "  Max weekly units:",
    round(max(hse22_processed$weekmean, na.rm = TRUE), 2), "\n"
  )
}
cat("\n")

cat("==========================================\n")
cat("BASIC TESTS COMPLETE\n")
cat("==========================================\n")
