# HSE 2022 Alcohol Analysis - Figure Generation
# ==============================================================================
# This script processes HSE 2022 data and generates exploratory figures
# Based on the test pipeline but expanded for comprehensive visualization
# ==============================================================================

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(Hmisc)

# Setup
cat("==========================================\n")
cat("HSE 2022 FIGURE GENERATION\n")
cat("==========================================\n\n")

# Load hseclean or source functions
if (requireNamespace("hseclean", quietly = TRUE)) {
  library(hseclean)
  USE_PACKAGE <- TRUE
} else {
  USE_PACKAGE <- FALSE
  # Use 2022-specific ABV data if available, otherwise use standard
  if(file.exists("data/abv_data_2022.rda")) {
    load("data/abv_data_2022.rda")
    abv_data <- abv_data_2022  # Use 2022-specific values
    cat("  Using 2022-specific ABV values\n")
  } else {
    load("data/abv_data.rda")
    cat("  Using standard ABV values (2022-specific not found)\n")
  }
  load("data/alc_volume_data.rda")
  source("R/alc_drink_freq.R")
  source("R/read_2022.R")
  source("R/clean_age.R")
  source("R/alc_drink_now_allages.R")
  source("R/alc_weekmean_adult.R")
}

# Create output directory
output_dir <- "figures_2022/"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# PART 1: Load and Process Data
# ==============================================================================

cat("PART 1: Loading and processing HSE 2022 data...\n")

data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)

# Process through pipeline
data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)

if (!USE_PACKAGE) {
  data_2022 <- alc_weekmean_adult(data_2022, abv_data = abv_data,
                                   volume_data = alc_volume_data)
} else {
  data_2022 <- alc_weekmean_adult(data_2022)
}

adults <- data_2022[age >= 16]

cat("  ✓ Data processed:", nrow(adults), "adults\n\n")

# ==============================================================================
# PART 2: Distribution Figures
# ==============================================================================

cat("PART 2: Creating distribution figures...\n")

# Figure 1: Distribution of weekly consumption
p1 <- ggplot(adults[weekmean > 0 & weekmean <= 50], aes(x = weekmean)) +
  geom_histogram(binwidth = 2, fill = "#3498db", color = "white", alpha = 0.8) +
  geom_vline(xintercept = 14, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = 16, y = Inf, label = "14 units\n(guideline)",
           vjust = 1.5, color = "red", size = 3.5) +
  labs(
    title = "Distribution of Weekly Alcohol Consumption",
    subtitle = "HSE 2022 - Adults (16+) with non-zero consumption",
    x = "Mean weekly units",
    y = "Number of adults",
    caption = "Red line = UK Chief Medical Officers' low risk guideline (14 units/week)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30")
  )

ggsave(paste0(output_dir, "01_weekly_consumption_distribution.png"),
       p1, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 1: Weekly consumption distribution\n")

# Figure 2: Drinker categories
drinker_data <- adults[, .N, by = drinker_cat][!is.na(drinker_cat)]
drinker_data[, pct := 100 * N / sum(N)]
drinker_data[, drinker_cat := factor(drinker_cat,
  levels = c("abstainer", "lower_risk", "increasing_risk", "higher_risk"))]

p2 <- ggplot(drinker_data, aes(x = drinker_cat, y = pct, fill = drinker_cat)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.1f%%\n(n=%d)", pct, N)),
            vjust = -0.3, size = 4) +
  scale_fill_manual(values = c(
    "abstainer" = "#95a5a6",
    "lower_risk" = "#27ae60",
    "increasing_risk" = "#f39c12",
    "higher_risk" = "#e74c3c"
  )) +
  labs(
    title = "Distribution of Drinker Risk Categories",
    subtitle = "HSE 2022 - Adults (16+)",
    x = "Drinker category",
    y = "Percentage of population",
    fill = "Category"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  ylim(0, max(drinker_data$pct) * 1.15)

ggsave(paste0(output_dir, "02_drinker_categories.png"),
       p2, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 2: Drinker categories\n")

# Figure 3: Beverage type composition
bev_data <- adults[, .(
  Beer = mean(beer_units, na.rm = TRUE),
  Wine = mean(wine_units, na.rm = TRUE),
  Spirits = mean(spirit_units, na.rm = TRUE),
  RTDs = mean(rtd_units, na.rm = TRUE)
)]

bev_long <- melt(bev_data, measure.vars = c("Beer", "Wine", "Spirits", "RTDs"),
                 variable.name = "Beverage", value.name = "Mean_Units")

p3 <- ggplot(bev_long, aes(x = Beverage, y = Mean_Units, fill = Beverage)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.2f", Mean_Units)), vjust = -0.5, size = 4) +
  scale_fill_manual(values = c(
    "Beer" = "#f39c12",
    "Wine" = "#8e44ad",
    "Spirits" = "#c0392b",
    "RTDs" = "#16a085"
  )) +
  labs(
    title = "Mean Weekly Consumption by Beverage Type",
    subtitle = "HSE 2022 - All adults (16+)",
    x = "Beverage type",
    y = "Mean weekly units",
    caption = "Note: Beer includes normal and strong cider from 2022 onwards"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  )

ggsave(paste0(output_dir, "03_beverage_composition.png"),
       p3, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 3: Beverage composition\n")

# ==============================================================================
# PART 3: Cider-Specific Figures
# ==============================================================================

cat("\nPART 3: Creating cider-specific figures...\n")

# Figure 4: Normal vs Strong Cider
cider_consumers <- adults[ncider_units > 0 | scider_units > 0]
cider_summary <- data.table(
  Type = c("Normal Cider\n(<6% ABV)", "Strong Cider\n(≥6% ABV)"),
  N_Drinkers = c(
    nrow(adults[ncider_units > 0]),
    nrow(adults[scider_units > 0])
  ),
  Mean_Units = c(
    mean(adults[ncider_units > 0]$ncider_units, na.rm = TRUE),
    mean(adults[scider_units > 0]$scider_units, na.rm = TRUE)
  )
)

p4 <- ggplot(cider_summary, aes(x = Type, y = Mean_Units, fill = Type)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.2f units/week\n(n=%d)", Mean_Units, N_Drinkers)),
            vjust = -0.3, size = 4) +
  scale_fill_manual(values = c("#f39c12", "#e67e22")) +
  labs(
    title = "Cider Consumption: Normal vs Strong",
    subtitle = "HSE 2022 - Among cider drinkers only",
    x = "Cider type",
    y = "Mean weekly units (among drinkers)",
    caption = "NEW in HSE 2022: Cider split into normal (<6% ABV) and strong (≥6% ABV)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  ) +
  ylim(0, max(cider_summary$Mean_Units) * 1.2)

ggsave(paste0(output_dir, "04_cider_normal_vs_strong.png"),
       p4, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 4: Normal vs strong cider\n")

# Figure 5: Cider prevalence
cider_prevalence <- data.table(
  Category = c("Normal Cider", "Strong Cider", "Any Cider", "No Cider"),
  N = c(
    nrow(adults[ncider_units > 0]),
    nrow(adults[scider_units > 0]),
    nrow(adults[ncider_units > 0 | scider_units > 0]),
    nrow(adults[ncider_units == 0 & scider_units == 0])
  )
)
cider_prevalence[, pct := 100 * N / nrow(adults)]

p5 <- ggplot(cider_prevalence[Category != "No Cider"],
             aes(x = Category, y = pct, fill = Category)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.1f%%\n(n=%d)", pct, N)),
            vjust = -0.3, size = 4) +
  scale_fill_manual(values = c(
    "Normal Cider" = "#f39c12",
    "Strong Cider" = "#e67e22",
    "Any Cider" = "#d35400"
  )) +
  labs(
    title = "Cider Consumption Prevalence",
    subtitle = "HSE 2022 - Proportion of adults (16+) consuming cider",
    x = "Category",
    y = "Percentage of population",
    caption = "Note: 'Any Cider' includes those drinking normal, strong, or both"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  ) +
  ylim(0, max(cider_prevalence[Category != "No Cider"]$pct) * 1.2)

ggsave(paste0(output_dir, "05_cider_prevalence.png"),
       p5, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 5: Cider prevalence\n")

# ==============================================================================
# PART 4: Stratified Analyses - By Sex
# ==============================================================================

cat("\nPART 4: Creating sex-stratified figures...\n")

# Figure 6: Consumption by sex
by_sex <- adults[!is.na(sex), .(
  mean_total = mean(weekmean, na.rm = TRUE),
  mean_beer = mean(beer_units, na.rm = TRUE),
  mean_wine = mean(wine_units, na.rm = TRUE),
  mean_spirits = mean(spirit_units, na.rm = TRUE),
  mean_rtd = mean(rtd_units, na.rm = TRUE),
  abstention = 100 * sum(drinks_now == "non_drinker") / .N
), by = sex]

by_sex[, sex_label := ifelse(sex == 1, "Male", "Female")]

# Reshape for beverage stacked bar
by_sex_long <- melt(by_sex, id.vars = c("sex", "sex_label", "mean_total", "abstention"),
                    measure.vars = c("mean_beer", "mean_wine", "mean_spirits", "mean_rtd"),
                    variable.name = "Beverage", value.name = "Units")

by_sex_long[, Beverage := factor(Beverage,
  levels = c("mean_beer", "mean_wine", "mean_spirits", "mean_rtd"),
  labels = c("Beer/Cider", "Wine", "Spirits", "RTDs"))]

p6 <- ggplot(by_sex_long, aes(x = sex_label, y = Units, fill = Beverage)) +
  geom_bar(stat = "identity", position = "stack", alpha = 0.8) +
  geom_text(data = by_sex, aes(x = sex_label, y = mean_total + 1,
            label = sprintf("Total: %.1f", mean_total)),
            inherit.aes = FALSE, size = 4, fontface = "bold") +
  scale_fill_manual(values = c(
    "Beer/Cider" = "#f39c12",
    "Wine" = "#8e44ad",
    "Spirits" = "#c0392b",
    "RTDs" = "#16a085"
  )) +
  labs(
    title = "Weekly Alcohol Consumption by Sex",
    subtitle = "HSE 2022 - Mean units per week by beverage type",
    x = "Sex",
    y = "Mean weekly units",
    fill = "Beverage"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right"
  )

ggsave(paste0(output_dir, "06_consumption_by_sex.png"),
       p6, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 6: Consumption by sex\n")

# Figure 7: Abstention by sex
p7 <- ggplot(by_sex, aes(x = sex_label, y = abstention, fill = sex_label)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.1f%%", abstention)),
            vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("Male" = "#3498db", "Female" = "#e74c3c")) +
  labs(
    title = "Abstention Rates by Sex",
    subtitle = "HSE 2022 - Proportion not currently drinking alcohol",
    x = "Sex",
    y = "Abstention rate (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  ) +
  ylim(0, max(by_sex$abstention) * 1.2)

ggsave(paste0(output_dir, "07_abstention_by_sex.png"),
       p7, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 7: Abstention by sex\n")

# ==============================================================================
# PART 5: Stratified Analyses - By Age
# ==============================================================================

cat("\nPART 5: Creating age-stratified figures...\n")

# Figure 8: Consumption by age
by_age <- adults[!is.na(age_cat), .(
  mean_weekmean = mean(weekmean, na.rm = TRUE),
  abstention = 100 * sum(drinks_now == "non_drinker") / .N,
  n = .N
), by = age_cat]

# Order age categories properly
age_order <- c("16-17", "18-19", "20-24", "25-29", "30-34", "35-39", "40-44",
               "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79",
               "80-84", "85-89", "90+")
by_age[, age_cat := factor(age_cat, levels = age_order)]
by_age <- by_age[order(age_cat)]

p8 <- ggplot(by_age, aes(x = age_cat, y = mean_weekmean, group = 1)) +
  geom_line(color = "#3498db", size = 1.2) +
  geom_point(aes(size = n), color = "#3498db", alpha = 0.7) +
  geom_hline(yintercept = 14, linetype = "dashed", color = "red", alpha = 0.5) +
  labs(
    title = "Mean Weekly Consumption by Age Group",
    subtitle = "HSE 2022 - All adults (point size = sample size)",
    x = "Age group",
    y = "Mean weekly units",
    size = "Sample size",
    caption = "Red line = 14 units/week guideline"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(paste0(output_dir, "08_consumption_by_age.png"),
       p8, width = 12, height = 6, dpi = 300)
cat("  ✓ Figure 8: Consumption by age\n")

# Figure 9: Abstention by age
p9 <- ggplot(by_age, aes(x = age_cat, y = abstention, group = 1)) +
  geom_line(color = "#e74c3c", size = 1.2) +
  geom_point(size = 3, color = "#e74c3c", alpha = 0.7) +
  labs(
    title = "Abstention Rates by Age Group",
    subtitle = "HSE 2022 - Proportion not currently drinking",
    x = "Age group",
    y = "Abstention rate (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(paste0(output_dir, "09_abstention_by_age.png"),
       p9, width = 12, height = 6, dpi = 300)
cat("  ✓ Figure 9: Abstention by age\n")

# ==============================================================================
# PART 6: Stratified Analyses - By IMD
# ==============================================================================

cat("\nPART 6: Creating deprivation-stratified figures...\n")

# Figure 10: Consumption by IMD
imd_var <- ifelse("qimd" %in% names(adults), "qimd", "qim4")

by_imd <- adults[!is.na(get(imd_var)), .(
  mean_weekmean = mean(weekmean, na.rm = TRUE),
  abstention = 100 * sum(drinks_now == "non_drinker") / .N,
  n = .N
), by = get(imd_var)]

setnames(by_imd, "get", "imd")
by_imd[, imd_label := paste("Q", imd, sep = "")]

p10 <- ggplot(by_imd, aes(x = imd_label, y = mean_weekmean, fill = as.factor(imd))) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.1f", mean_weekmean)),
            vjust = -0.5, size = 4) +
  geom_hline(yintercept = 14, linetype = "dashed", color = "red", alpha = 0.5) +
  scale_fill_brewer(palette = "RdYlGn", direction = -1) +
  labs(
    title = "Mean Weekly Consumption by Deprivation Quintile",
    subtitle = "HSE 2022 - Index of Multiple Deprivation",
    x = "IMD Quintile (Q1 = Most deprived)",
    y = "Mean weekly units",
    caption = "Red line = 14 units/week guideline"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  )

ggsave(paste0(output_dir, "10_consumption_by_imd.png"),
       p10, width = 10, height = 6, dpi = 300)
cat("  ✓ Figure 10: Consumption by IMD\n")

# ==============================================================================
# PART 7: Summary Statistics Table
# ==============================================================================

cat("\nPART 7: Creating summary statistics table...\n")

# Create comprehensive summary
summary_stats <- data.table(
  Statistic = c(
    "Sample size (adults 16+)",
    "Mean weekly units (all adults)",
    "Median weekly units",
    "Mean weekly units (drinkers only)",
    "Abstention rate (%)",
    "",
    "Mean beer/cider units",
    "Mean wine units",
    "Mean spirits units",
    "Mean RTD units",
    "",
    "Normal cider drinkers (n)",
    "Normal cider drinkers (%)",
    "Mean normal cider units (drinkers)",
    "",
    "Strong cider drinkers (n)",
    "Strong cider drinkers (%)",
    "Mean strong cider units (drinkers)",
    "",
    "Abstainer (%)",
    "Lower risk (%)",
    "Increasing risk (%)",
    "Higher risk (%)"
  ),
  Value = c(
    format(nrow(adults), big.mark = ","),
    sprintf("%.2f", mean(adults$weekmean, na.rm = TRUE)),
    sprintf("%.2f", median(adults$weekmean, na.rm = TRUE)),
    sprintf("%.2f", mean(adults[drinks_now == "drinker"]$weekmean, na.rm = TRUE)),
    sprintf("%.1f", 100 * sum(adults$drinks_now == "non_drinker") / nrow(adults)),
    "",
    sprintf("%.2f", mean(adults$beer_units, na.rm = TRUE)),
    sprintf("%.2f", mean(adults$wine_units, na.rm = TRUE)),
    sprintf("%.2f", mean(adults$spirit_units, na.rm = TRUE)),
    sprintf("%.2f", mean(adults$rtd_units, na.rm = TRUE)),
    "",
    format(sum(adults$ncider_units > 0), big.mark = ","),
    sprintf("%.1f", 100 * sum(adults$ncider_units > 0) / nrow(adults)),
    sprintf("%.2f", mean(adults[ncider_units > 0]$ncider_units, na.rm = TRUE)),
    "",
    format(sum(adults$scider_units > 0), big.mark = ","),
    sprintf("%.1f", 100 * sum(adults$scider_units > 0) / nrow(adults)),
    sprintf("%.2f", mean(adults[scider_units > 0]$scider_units, na.rm = TRUE)),
    "",
    sprintf("%.1f", 100 * sum(adults$drinker_cat == "abstainer", na.rm = TRUE) / nrow(adults)),
    sprintf("%.1f", 100 * sum(adults$drinker_cat == "lower_risk", na.rm = TRUE) / nrow(adults)),
    sprintf("%.1f", 100 * sum(adults$drinker_cat == "increasing_risk", na.rm = TRUE) / nrow(adults)),
    sprintf("%.1f", 100 * sum(adults$drinker_cat == "higher_risk", na.rm = TRUE) / nrow(adults))
  )
)

# Save table
fwrite(summary_stats, paste0(output_dir, "summary_statistics.csv"))
cat("  ✓ Summary statistics table saved\n")

# ==============================================================================
# COMPLETION
# ==============================================================================

cat("\n==========================================\n")
cat("FIGURE GENERATION COMPLETE\n")
cat("==========================================\n\n")
cat("Figures saved to:", output_dir, "\n")
cat("\nGenerated figures:\n")
cat("  01. Weekly consumption distribution\n")
cat("  02. Drinker categories\n")
cat("  03. Beverage composition\n")
cat("  04. Normal vs strong cider\n")
cat("  05. Cider prevalence\n")
cat("  06. Consumption by sex\n")
cat("  07. Abstention by sex\n")
cat("  08. Consumption by age\n")
cat("  09. Abstention by age\n")
cat("  10. Consumption by IMD\n")
cat("  Plus: Summary statistics table (CSV)\n\n")

cat("Next steps:\n")
cat("  1. Review figures in:", output_dir, "\n")
cat("  2. For multi-year trends, process years 2011-2022\n")
cat("  3. See HSE_2022_Alcohol_Trends_Report.md for analysis framework\n\n")
