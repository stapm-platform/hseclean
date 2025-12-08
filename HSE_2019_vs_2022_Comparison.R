# HSE 2019 vs 2022 Comparison Script
# ==============================================================================
# Compare alcohol consumption patterns between HSE 2019 and 2022 to validate
# that 2022 processing is working correctly
# ==============================================================================
#
# IMPORTANT: Update file paths below (lines 54-57 and 76-79) to point to your
# HSE 2019 and HSE 2022 data files before running this script
#
# ==============================================================================

library(data.table)

cat("==========================================\n")
cat("HSE 2019 vs 2022 COMPARISON\n")
cat("==========================================\n\n")

# Determine if using package mode
USE_PACKAGE_MODE <- FALSE

if (USE_PACKAGE_MODE && requireNamespace("hseclean", quietly = TRUE)) {
  cat("Using installed hseclean package\n\n")
  library(hseclean)
  USE_PACKAGE <- TRUE
} else {
  cat("Using local functions\n\n")
  USE_PACKAGE <- FALSE

  # Load standard ABV data for 2019
  load("data/abv_data.rda")
  abv_data_2019 <- abv_data

  # Load 2022-specific ABV data
  if(file.exists("data/abv_data_2022.rda")) {
    load("data/abv_data_2022.rda")
    cat("  ✓ 2022-specific ABV data loaded\n")
  } else {
    cat("  ⚠ Warning: 2022-specific ABV data not found\n")
    cat("  Run source('create_2022_abv.R') first\n\n")
    stop("Missing 2022 ABV data")
  }

  load("data/alc_volume_data.rda")
  source("R/alc_drink_freq.R")
  source("R/read_2019.R")
  source("R/read_2022.R")
  source("R/clean_age.R")
  source("R/alc_drink_now_allages.R")
  source("R/alc_weekmean_adult.R")
}

# ==============================================================================
# Load and Process HSE 2019
# ==============================================================================

cat("Loading HSE 2019...\n")
# NOTE: Update this path to point to your HSE 2019 data file
# For now, using same root as 2022 data - user should update if different
data_2019 <- read_2019(
root = c("X:/", "/Volumes/Shared/")[1],
    file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2019/hse_2019_eul_20211006.tab"
)

cat("  Processing HSE 2019...\n")
data_2019 <- clean_age(data_2019)
data_2019 <- alc_drink_now_allages(data_2019)

if (!USE_PACKAGE) {
  data_2019 <- alc_weekmean_adult(data_2019, abv_data = abv_data_2019,
                                   volume_data = alc_volume_data)
} else {
  data_2019 <- alc_weekmean_adult(data_2019)
}

adults_2019 <- data_2019[age >= 16]
cat("  ✓ Processed:", nrow(adults_2019), "adults\n\n")

# ==============================================================================
# Load and Process HSE 2022
# ==============================================================================

cat("Loading HSE 2022...\n")
data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)

cat("  Processing HSE 2022...\n")
data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)

if (!USE_PACKAGE) {
  data_2022 <- alc_weekmean_adult(data_2022, abv_data = abv_data_2022,
                                   volume_data = alc_volume_data)
} else {
  data_2022 <- alc_weekmean_adult(data_2022)
}

adults_2022 <- data_2022[age >= 16]
cat("  ✓ Processed:", nrow(adults_2022), "adults\n\n")

# ==============================================================================
# COMPARISON 1: Overall Statistics
# ==============================================================================

cat("==========================================\n")
cat("OVERALL STATISTICS COMPARISON\n")
cat("==========================================\n\n")

comparison_overall <- data.table(
  Metric = c(
    "Sample size (adults 16+)",
    "Mean weekly units (all)",
    "Mean weekly units (drinkers)",
    "Median weekly units (all)",
    "Median weekly units (drinkers)",
    "% Abstainers",
    "% Exceeding 14 units/week",
    "% Higher risk (≥35F/50M)"
  ),
  HSE_2019 = c(
    nrow(adults_2019),
    round(mean(adults_2019$weekmean, na.rm = TRUE), 2),
    round(mean(adults_2019[drinks_now == "drinker"]$weekmean, na.rm = TRUE), 2),
    round(median(adults_2019$weekmean, na.rm = TRUE), 2),
    round(median(adults_2019[drinks_now == "drinker" & weekmean > 0]$weekmean, na.rm = TRUE), 2),
    round(100 * sum(adults_2019$drinks_now == "non_drinker", na.rm = TRUE) / sum(!is.na(adults_2019$drinks_now)), 1),
    round(100 * sum(adults_2019$weekmean > 14, na.rm = TRUE) / nrow(adults_2019), 1),
    round(100 * sum(adults_2019$drinker_cat == "higher_risk", na.rm = TRUE) / nrow(adults_2019), 1)
  ),
  HSE_2022 = c(
    nrow(adults_2022),
    round(mean(adults_2022$weekmean, na.rm = TRUE), 2),
    round(mean(adults_2022[drinks_now == "drinker"]$weekmean, na.rm = TRUE), 2),
    round(median(adults_2022$weekmean, na.rm = TRUE), 2),
    round(median(adults_2022[drinks_now == "drinker" & weekmean > 0]$weekmean, na.rm = TRUE), 2),
    round(100 * sum(adults_2022$drinks_now == "non_drinker", na.rm = TRUE) / sum(!is.na(adults_2022$drinks_now)), 1),
    round(100 * sum(adults_2022$weekmean > 14, na.rm = TRUE) / nrow(adults_2022), 1),
    round(100 * sum(adults_2022$drinker_cat == "higher_risk", na.rm = TRUE) / nrow(adults_2022), 1)
  )
)

comparison_overall[, Difference := HSE_2022 - HSE_2019]
comparison_overall[, Pct_Change := round(100 * (HSE_2022 - HSE_2019) / HSE_2019, 1)]

print(comparison_overall)
cat("\n")

# ==============================================================================
# COMPARISON 2: By Sex
# ==============================================================================

cat("==========================================\n")
cat("BY SEX COMPARISON\n")
cat("==========================================\n\n")

by_sex_2019 <- adults_2019[!is.na(sex) & !is.na(drinks_now), .(
  n = .N,
  mean_all = mean(weekmean, na.rm = TRUE),
  mean_drinkers = mean(weekmean[drinks_now == "drinker"], na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
), by = sex]
by_sex_2019[, year := 2019]

by_sex_2022 <- adults_2022[!is.na(sex) & !is.na(drinks_now), .(
  n = .N,
  mean_all = mean(weekmean, na.rm = TRUE),
  mean_drinkers = mean(weekmean[drinks_now == "drinker"], na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
), by = sex]
by_sex_2022[, year := 2022]

by_sex_combined <- rbind(by_sex_2019, by_sex_2022)

cat("HSE 2019:\n")
print(by_sex_2019[, .(sex, n, mean_all, mean_drinkers, abstention_pct)])
cat("\nHSE 2022:\n")
print(by_sex_2022[, .(sex, n, mean_all, mean_drinkers, abstention_pct)])

# Calculate changes
cat("\nChanges (2022 vs 2019):\n")
for(s in c("Male", "Female")) {
  v2019 <- by_sex_2019[sex == s]$mean_all
  v2022 <- by_sex_2022[sex == s]$mean_all
  abs2019 <- by_sex_2019[sex == s]$abstention_pct
  abs2022 <- by_sex_2022[sex == s]$abstention_pct

  cat(sprintf("  %s: %.2f → %.2f units (%.1f%% change) | Abstention: %.1f%% → %.1f%%\n",
              s, v2019, v2022, 100*(v2022-v2019)/v2019, abs2019, abs2022))
}
cat("\n")

# ==============================================================================
# COMPARISON 3: By Age Group
# ==============================================================================

cat("==========================================\n")
cat("BY AGE GROUP COMPARISON\n")
cat("==========================================\n\n")

# Use broader age bands for comparison
adults_2019[, age_broad := fcase(
  age_cat %in% c("16-17", "18-19"), "16-19",
  age_cat %in% c("20-24", "25-29"), "20-29",
  age_cat %in% c("30-34", "35-39"), "30-39",
  age_cat %in% c("40-44", "45-49"), "40-49",
  age_cat %in% c("50-54", "55-59"), "50-59",
  age_cat %in% c("60-64", "65-69"), "60-69",
  age_cat %in% c("70-74", "75-79"), "70-79",
  age_cat %in% c("80-84", "85-89"), "80+"
)]

adults_2022[, age_broad := fcase(
  age_cat %in% c("16-17", "18-19"), "16-19",
  age_cat %in% c("20-24", "25-29"), "20-29",
  age_cat %in% c("30-34", "35-39"), "30-39",
  age_cat %in% c("40-44", "45-49"), "40-49",
  age_cat %in% c("50-54", "55-59"), "50-59",
  age_cat %in% c("60-64", "65-69"), "60-69",
  age_cat %in% c("70-74", "75-79"), "70-79",
  age_cat %in% c("80-84", "85-89"), "80+"
)]

by_age_2019 <- adults_2019[!is.na(age_broad) & !is.na(drinks_now), .(
  n = .N,
  mean_all = mean(weekmean, na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
), by = age_broad]
by_age_2019[, year := 2019]

by_age_2022 <- adults_2022[!is.na(age_broad) & !is.na(drinks_now), .(
  n = .N,
  mean_all = mean(weekmean, na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
), by = age_broad]
by_age_2022[, year := 2022]

age_broad_levels <- c("16-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
by_age_2019[, age_broad := factor(age_broad, levels = age_broad_levels)]
by_age_2022[, age_broad := factor(age_broad, levels = age_broad_levels)]

setorder(by_age_2019, age_broad)
setorder(by_age_2022, age_broad)

cat("HSE 2019:\n")
print(by_age_2019[, .(age_broad, n, mean_all, abstention_pct)])
cat("\nHSE 2022:\n")
print(by_age_2022[, .(age_broad, n, mean_all, abstention_pct)])
cat("\n")

# ==============================================================================
# COMPARISON 4: By IMD (Deprivation)
# ==============================================================================

cat("==========================================\n")
cat("BY IMD COMPARISON\n")
cat("==========================================\n\n")

# Note: Different IMD categorizations between years
cat("NOTE: HSE 2019 uses qimd (5 quintiles, 2015 boundaries)\n")
cat("      HSE 2022 uses qim4 (4 quartiles)\n")
cat("      ⚠️  Different categorizations make direct comparison difficult\n\n")

# Debug: Check what IMD variables exist
cat("DEBUG: IMD variables in adults_2019:", paste(grep("imd|qim", names(adults_2019), value=TRUE, ignore.case=TRUE), collapse=", "), "\n")
cat("DEBUG: IMD variables in adults_2022:", paste(grep("imd|qim", names(adults_2022), value=TRUE, ignore.case=TRUE), collapse=", "), "\n\n")

if("qimd" %in% names(adults_2019)) {
  by_imd_2019 <- adults_2019[!is.na(qimd) & !is.na(drinks_now), .(
    n = .N,
    mean_all = mean(weekmean, na.rm = TRUE),
    abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
  ), by = qimd]
  setorder(by_imd_2019, qimd)

  cat("HSE 2019 (IMD 2015 quintiles - 1=most deprived):\n")
  print(by_imd_2019)
  cat("\n")
}

if("qim4" %in% names(adults_2022)) {
  by_imd_2022 <- adults_2022[!is.na(qim4) & !is.na(drinks_now), .(
    n = .N,
    mean_all = mean(weekmean, na.rm = TRUE),
    abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
  ), by = qim4]
  setorder(by_imd_2022, qim4)

  cat("HSE 2022 (IMD quartiles - 1=most deprived, 4=least deprived):\n")
  print(by_imd_2022)
  cat("\n")

  cat("NOTE: HSE 2022 uses 4 IMD quartiles, HSE 2019 uses 5 quintiles\n")
  cat("      Direct comparison is difficult due to different categorizations\n")
  cat("      Check abstention pattern: expect higher in more deprived areas (Q1)\n\n")
} else if("qimd" %in% names(adults_2022)) {
  # Fallback if qimd exists (e.g., if qimd19 was renamed to qimd)
  by_imd_2022 <- adults_2022[!is.na(qimd) & !is.na(drinks_now), .(
    n = .N,
    mean_all = mean(weekmean, na.rm = TRUE),
    abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N
  ), by = qimd]
  setorder(by_imd_2022, qimd)

  cat("HSE 2022 (IMD quintiles - 1=most deprived):\n")
  print(by_imd_2022)
  cat("\n")

  cat("NOTE: Check abstention pattern by IMD quintile\n")
  cat("      Expect: More deprived areas (Q1) typically have higher abstention rates\n\n")
}

# ==============================================================================
# COMPARISON 5: Beverage-Specific Consumption
# ==============================================================================

cat("==========================================\n")
cat("BEVERAGE-SPECIFIC CONSUMPTION\n")
cat("==========================================\n\n")

cat("NOTE: In HSE 2019 and earlier, cider was included in the 'beer_units' variable\n")
cat("      HSE 2022 is the first year to split normal (<6% ABV) and strong (≥6% ABV) cider\n")
cat("      For fair comparison, we show beer+cider combined for both years\n\n")

beverage_comparison <- data.table(
  Beverage = c("Beer+Cider (combined)", "Wine", "Spirits", "RTDs", "Normal Cider (<6%)", "Strong Cider (≥6%)"),
  HSE_2019 = c(
    round(mean(adults_2019$beer_units, na.rm = TRUE), 2),  # Includes cider
    round(mean(adults_2019$wine_units, na.rm = TRUE), 2),
    round(mean(adults_2019$spirit_units, na.rm = TRUE), 2),
    round(mean(adults_2019$rtd_units, na.rm = TRUE), 2),
    NA_real_,  # Not split in 2019
    NA_real_   # Not split in 2019
  ),
  HSE_2022 = c(
    round(mean(adults_2022$beer_units, na.rm = TRUE), 2),  # Also includes cider
    round(mean(adults_2022$wine_units, na.rm = TRUE), 2),
    round(mean(adults_2022$spirit_units, na.rm = TRUE), 2),
    round(mean(adults_2022$rtd_units, na.rm = TRUE), 2),
    round(mean(adults_2022$ncider_units, na.rm = TRUE), 2),  # Only in 2022+
    round(mean(adults_2022$scider_units, na.rm = TRUE), 2)   # Only in 2022+
  )
)

beverage_comparison[!is.na(HSE_2019), Difference := HSE_2022 - HSE_2019]
beverage_comparison[!is.na(HSE_2019), Pct_Change := round(100 * (HSE_2022 - HSE_2019) / HSE_2019, 1)]

print(beverage_comparison)
cat("\n")

# ==============================================================================
# COMPARISON 6: Cider Analysis
# ==============================================================================

cat("==========================================\n")
cat("CIDER CONSUMPTION ANALYSIS\n")
cat("==========================================\n\n")

cat("NOTE: HSE 2019 included cider in beer_units (no separate cider variable)\n")
cat("      HSE 2022 is first year with separate normal/strong cider tracking\n\n")

cat("HSE 2022 (split by strength):\n")
cat(sprintf("  Normal cider drinkers: %d (%.1f%%)\n",
            sum(adults_2022$ncider_units > 0, na.rm = TRUE),
            100 * sum(adults_2022$ncider_units > 0, na.rm = TRUE) / nrow(adults_2022)))
if(sum(adults_2022$ncider_units > 0, na.rm = TRUE) > 0) {
  cat(sprintf("    Mean units (among drinkers): %.2f\n",
              mean(adults_2022[ncider_units > 0]$ncider_units, na.rm = TRUE)))
}

cat(sprintf("  Strong cider drinkers: %d (%.1f%%)\n",
            sum(adults_2022$scider_units > 0, na.rm = TRUE),
            100 * sum(adults_2022$scider_units > 0, na.rm = TRUE) / nrow(adults_2022)))
if(sum(adults_2022$scider_units > 0, na.rm = TRUE) > 0) {
  cat(sprintf("    Mean units (among drinkers): %.2f\n",
              mean(adults_2022[scider_units > 0]$scider_units, na.rm = TRUE)))
}

cat("\n")

# ==============================================================================
# Summary and Validation
# ==============================================================================

cat("==========================================\n")
cat("VALIDATION SUMMARY\n")
cat("==========================================\n\n")

cat("✓ CHECKS TO PERFORM:\n\n")

cat("1. Overall mean consumption:\n")
cat("   - Expect slight decrease from 2019 to 2022 (COVID effect)\n")
cat(sprintf("   - Current: %.2f → %.2f units (%.1f%% change)\n",
    mean(adults_2019$weekmean, na.rm = TRUE),
    mean(adults_2022$weekmean, na.rm = TRUE),
    100 * (mean(adults_2022$weekmean, na.rm = TRUE) - mean(adults_2019$weekmean, na.rm = TRUE)) /
      mean(adults_2019$weekmean, na.rm = TRUE)))

cat("\n2. Abstention rates:\n")
cat("   - Expect increase from 2019 to 2022\n")
abstain_2019 <- 100 * sum(adults_2019$drinks_now == "non_drinker", na.rm = TRUE) / sum(!is.na(adults_2019$drinks_now))
abstain_2022 <- 100 * sum(adults_2022$drinks_now == "non_drinker", na.rm = TRUE) / sum(!is.na(adults_2022$drinks_now))
cat(sprintf("   - Current: %.1f%% → %.1f%% (%.1f pp change)\n",
            abstain_2019, abstain_2022, abstain_2022 - abstain_2019))

cat("\n3. Sex differences:\n")
cat("   - Males should drink more than females in both years\n")
cat(sprintf("   - 2019: M=%.2f, F=%.2f (ratio: %.2f)\n",
    by_sex_2019[sex == 1]$mean_all,
    by_sex_2019[sex == 2]$mean_all,
    by_sex_2019[sex == 1]$mean_all / by_sex_2019[sex == 2]$mean_all))
cat(sprintf("   - 2022: M=%.2f, F=%.2f (ratio: %.2f)\n",
    by_sex_2022[sex == 1]$mean_all,
    by_sex_2022[sex == 2]$mean_all,
    by_sex_2022[sex == 1]$mean_all / by_sex_2022[sex == 2]$mean_all))

cat("\n4. Age patterns:\n")
cat("   - Peak consumption typically in middle age (40-60)\n")
cat("   - Highest abstention in youngest (16-19) and oldest (80+) groups\n")
cat("   - Check age-specific tables above for patterns\n")

cat("\n5. IMD/Deprivation:\n")
cat("   - ⚠ CHECK: Abstention pattern by deprivation looks unusual\n")
cat("   - Expected: Higher deprivation → Higher abstention\n")
cat("   - Review IMD tables above carefully\n")

cat("\n6. ABV assumptions:\n")
cat("   - 2019 uses standard ABV values\n")
cat("   - 2022 uses 2022-specific ABV values (higher beer/cider ABVs)\n")
cat("   - This should slightly increase 2022 unit calculations (all else equal)\n")

cat("\n==========================================\n")
cat("COMPARISON COMPLETE\n")
cat("==========================================\n\n")
