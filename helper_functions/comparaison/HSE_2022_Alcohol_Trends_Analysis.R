# HSE 2022 Alcohol Consumption Trends Analysis
# ==============================================================================
# This script processes HSE data to generate population-level alcohol trends
# Author: Generated for hseclean package
# Date: 2025-11-24
# ==============================================================================

library(data.table)
library(ggplot2)
library(dplyr)

# Setup paths - MODIFY THESE FOR YOUR SYSTEM
root_path <- "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/"
output_path <- paste0(root_path, "analysis_outputs/")
dir.create(output_path, showWarnings = FALSE, recursive = TRUE)

# Load hseclean package
library(hseclean)

cat("===========================================\n")
cat("HSE ALCOHOL TRENDS ANALYSIS\n")
cat("===========================================\n\n")

# ==============================================================================
# STEP 1: Load and Process HSE 2022 Data
# ==============================================================================

cat("STEP 1: Loading HSE 2022 data...\n")

data_2022 <- read_2022(
  root = root_path,
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)

cat("  Data loaded:", nrow(data_2022), "rows\n")
cat("  Processing pipeline...\n")

# IMPORTANT: Clean age variables first
data_2022 <- clean_age(data_2022)

# Process through the alcohol pipeline
data_2022 <- alc_drink_now_allages(data_2022)
data_2022 <- alc_weekmean_adult(data_2022)

cat(" HSE 2022 processing complete\n\n")

# ==============================================================================
# STEP 2: Calculate Key Population Statistics for 2022
# ==============================================================================

cat("STEP 2: Calculating population statistics...\n")

# Filter to adults (16+)
adults_2022 <- data_2022[age >= 16]

# Calculate weighted statistics (using survey weights)
results_2022 <- list(
  year = 2022,

  # Mean weekly consumption
  mean_units_all_adults = weighted.mean(adults_2022$weekmean, adults_2022$wt_int, na.rm = TRUE),
  mean_units_drinkers = weighted.mean(
    adults_2022[drinks_now == "drinker"]$weekmean,
    adults_2022[drinks_now == "drinker"]$wt_int,
    na.rm = TRUE
  ),

  # Abstention rate
  abstention_rate = 100 * sum(adults_2022[drinks_now == "non_drinker"]$wt_int, na.rm = TRUE) /
    sum(adults_2022$wt_int, na.rm = TRUE),

  # Drinker categories (proportion of population)
  prop_abstainer = 100 * sum(adults_2022[drinker_cat == "abstainer"]$wt_int, na.rm = TRUE) /
    sum(adults_2022$wt_int, na.rm = TRUE),
  prop_lower_risk = 100 * sum(adults_2022[drinker_cat == "lower_risk"]$wt_int, na.rm = TRUE) /
    sum(adults_2022$wt_int, na.rm = TRUE),
  prop_increasing_risk = 100 * sum(adults_2022[drinker_cat == "increasing_risk"]$wt_int, na.rm = TRUE) /
    sum(adults_2022$wt_int, na.rm = TRUE),
  prop_higher_risk = 100 * sum(adults_2022[drinker_cat == "higher_risk"]$wt_int, na.rm = TRUE) /
    sum(adults_2022$wt_int, na.rm = TRUE),

  # Beverage-specific consumption (among all adults)
  mean_beer_units = weighted.mean(adults_2022$beer_units, adults_2022$wt_int, na.rm = TRUE),
  mean_wine_units = weighted.mean(adults_2022$wine_units, adults_2022$wt_int, na.rm = TRUE),
  mean_spirit_units = weighted.mean(adults_2022$spirit_units, adults_2022$wt_int, na.rm = TRUE),
  mean_rtd_units = weighted.mean(adults_2022$rtd_units, adults_2022$wt_int, na.rm = TRUE)
)

# Print results
cat("\n--- HSE 2022 Key Statistics ---\n")
cat(sprintf("Mean weekly units (all adults): %.2f units\n", results_2022$mean_units_all_adults))
cat(sprintf("Mean weekly units (drinkers only): %.2f units\n", results_2022$mean_units_drinkers))
cat(sprintf("Abstention rate: %.1f%%\n", results_2022$abstention_rate))
cat(sprintf("\nDrinker categories:\n"))
cat(sprintf("  Abstainer: %.1f%%\n", results_2022$prop_abstainer))
cat(sprintf("  Lower risk: %.1f%%\n", results_2022$prop_lower_risk))
cat(sprintf("  Increasing risk: %.1f%%\n", results_2022$prop_increasing_risk))
cat(sprintf("  Higher risk: %.1f%%\n", results_2022$prop_higher_risk))
cat(sprintf("\nBeverage-specific consumption (all adults):\n"))
cat(sprintf("  Beer (incl. cider): %.2f units\n", results_2022$mean_beer_units))
cat(sprintf("  Wine: %.2f units\n", results_2022$mean_wine_units))
cat(sprintf("  Spirits: %.2f units\n", results_2022$mean_spirit_units))
cat(sprintf("  RTDs: %.2f units\n", results_2022$mean_rtd_units))

# ==============================================================================
# STEP 3: Stratified Analysis by Demographics
# ==============================================================================

cat("\n\nSTEP 3: Stratified analyses...\n")

# By sex
by_sex <- adults_2022[, .(
  mean_units_all = weighted.mean(weekmean, wt_int, na.rm = TRUE),
  mean_units_drinkers = weighted.mean(weekmean[drinks_now == "drinker"],
                                       wt_int[drinks_now == "drinker"], na.rm = TRUE),
  abstention_rate = 100 * sum(wt_int[drinks_now == "non_drinker"], na.rm = TRUE) / sum(wt_int, na.rm = TRUE),
  mean_beer = weighted.mean(beer_units, wt_int, na.rm = TRUE),
  mean_wine = weighted.mean(wine_units, wt_int, na.rm = TRUE),
  mean_spirits = weighted.mean(spirit_units, wt_int, na.rm = TRUE),
  mean_rtd = weighted.mean(rtd_units, wt_int, na.rm = TRUE)
), by = sex]

cat("\n--- By Sex ---\n")
print(by_sex)

# By age group
# Use age_cat which is created by clean_age()
by_age <- adults_2022[, .(
  mean_units_all = weighted.mean(weekmean, wt_int, na.rm = TRUE),
  mean_units_drinkers = weighted.mean(weekmean[drinks_now == "drinker"],
                                       wt_int[drinks_now == "drinker"], na.rm = TRUE),
  abstention_rate = 100 * sum(wt_int[drinks_now == "non_drinker"], na.rm = TRUE) / sum(wt_int, na.rm = TRUE),
  n = .N
), by = age_cat]

cat("\n--- By Age Group ---\n")
print(by_age)

# By IMD
# HSE 2022 has qimd19 (5 quintiles, 2019 boundaries) rather than qimd (2015 boundaries)
if("qimd" %in% names(adults_2022)) {
  by_imd <- adults_2022[!is.na(qimd), .(
    mean_units_all = weighted.mean(weekmean, wt_int, na.rm = TRUE),
    mean_units_drinkers = weighted.mean(weekmean[drinks_now == "drinker"],
                                         wt_int[drinks_now == "drinker"], na.rm = TRUE),
    abstention_rate = 100 * sum(wt_int[drinks_now == "non_drinker"], na.rm = TRUE) / sum(wt_int, na.rm = TRUE),
    mean_beer = weighted.mean(beer_units, wt_int, na.rm = TRUE),
    mean_wine = weighted.mean(wine_units, wt_int, na.rm = TRUE),
    mean_spirits = weighted.mean(spirit_units, wt_int, na.rm = TRUE)
  ), by = qimd]
  cat("\n--- By IMD Quintile (2015 boundaries) ---\n")
} else if("qimd19" %in% names(adults_2022)) {
  by_imd <- adults_2022[!is.na(qimd19), .(
    mean_units_all = weighted.mean(weekmean, wt_int, na.rm = TRUE),
    mean_units_drinkers = weighted.mean(weekmean[drinks_now == "drinker"],
                                         wt_int[drinks_now == "drinker"], na.rm = TRUE),
    abstention_rate = 100 * sum(wt_int[drinks_now == "non_drinker"], na.rm = TRUE) / sum(wt_int, na.rm = TRUE),
    mean_beer = weighted.mean(beer_units, wt_int, na.rm = TRUE),
    mean_wine = weighted.mean(wine_units, wt_int, na.rm = TRUE),
    mean_spirits = weighted.mean(spirit_units, wt_int, na.rm = TRUE)
  ), by = qimd19]
  cat("\n--- By IMD Quintile (2019 boundaries) ---\n")
} else {
  cat("\n--- By IMD ---\n")
  cat("  No IMD variable found\n")
  by_imd <- NULL
}

if(!is.null(by_imd)) {
  print(by_imd)
}

# By drinker category (beverage preferences)
by_drinker_cat <- adults_2022[drinker_cat != "abstainer", .(
  mean_beer = weighted.mean(beer_units, wt_int, na.rm = TRUE),
  mean_wine = weighted.mean(wine_units, wt_int, na.rm = TRUE),
  mean_spirits = weighted.mean(spirit_units, wt_int, na.rm = TRUE),
  mean_rtd = weighted.mean(rtd_units, wt_int, na.rm = TRUE),
  total_units = weighted.mean(weekmean, wt_int, na.rm = TRUE)
), by = drinker_cat]

cat("\n--- By Drinker Category ---\n")
print(by_drinker_cat)

cat("\n\n===========================================\n")
cat("ANALYSIS COMPLETE\n")
cat("===========================================\n")
cat("\nNote: For full trend analysis across multiple years, you would need to:\n")
cat("1. Load and process data from previous HSE years (2011-2021)\n")
cat("2. Combine results into a single trends dataset\n")
cat("3. Generate time-series visualizations\n")
cat("\nSee HSE_2022_Alcohol_Trends_Report.md for more details.\n")
