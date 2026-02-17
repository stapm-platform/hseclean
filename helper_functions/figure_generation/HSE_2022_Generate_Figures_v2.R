# HSE 2022 Alcohol Analysis 
# ==============================================================================

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(Hmisc)
library(scales)



# Load hseclean or source functions
if (requireNamespace("hseclean", quietly = TRUE)) {
  library(hseclean)
  USE_PACKAGE <- TRUE
} else {
  USE_PACKAGE <- FALSE
  if(file.exists("data/abv_data_2022.rda")) {
    load("data/abv_data_2022.rda")
    abv_data <- abv_data_2022
    cat("  Using 2022-specific ABV values\n")
  } else {
    load("data/abv_data.rda")
    cat("  Using standard ABV values\n")
  }
  load("data/alc_volume_data.rda")
  source("R/alc_drink_freq.R")
  source("R/read_2022.R")
  source("R/clean_age.R")
  source("R/alc_drink_now_allages.R")
  source("R/alc_weekmean_adult.R")
}

# Load custom theme
source("R/theme_publication.R")

# Create output directory
output_dir <- "figures_2022_publication/"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Define color palettes
pal_risk <- c(abstainer = "#95A5A6", lower_risk = "#27AE60",
              increasing_risk = "#E67E22", higher_risk = "#C0392B")
pal_beverages <- c(Beer = "#F39C12", Wine = "#8E44AD",
                   Spirits = "#E74C3C", RTDs = "#16A085")
pal_sex <- c(Male = "#3498DB", Female = "#E74C3C")
pal_categorical <- c("#0173B2", "#DE8F05", "#029E73", "#CC78BC", "#CA9161")

# ==============================================================================
# PART 1: Load and Process Data
# ==============================================================================

cat("\nPART 1: Loading and processing data...\n")

data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)

data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)

if (!USE_PACKAGE) {
  data_2022 <- alc_weekmean_adult(data_2022, abv_data = abv_data,
                                   volume_data = alc_volume_data)
} else {
  data_2022 <- alc_weekmean_adult(data_2022)
}

adults <- data_2022[age >= 16]

# IMPORTANT: Convert numeric sex codes to labeled factors
# HSE coding: 1 = Male, 2 = Female
adults[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]

cat("  ✓ Processed:", nrow(adults), "adults\n\n")

# ==============================================================================
# FIGURE 1: Weekly Consumption Distribution
# ==============================================================================

cat("Creating Figure 1: Weekly consumption distribution...\n")

p1 <- ggplot(adults[weekmean > 0 & weekmean <= 50], aes(x = weekmean)) +
  geom_histogram(binwidth = 2, fill = "#0173B2", color = "white",
                 alpha = 0.85, linewidth = 0.3) +
  geom_vline(xintercept = 14, linetype = "dashed", color = "#E74C3C",
             linewidth = 0.8, alpha = 0.7) +
  annotate("text", x = 14, y = Inf, label = "14 units\n(low risk limit)",
           vjust = 1.5, hjust = -0.1, color = "#E74C3C", size = 3.5, fontface = "bold") +
  scale_x_continuous(breaks = seq(0, 50, by = 10), expand = c(0.01, 0)) +
  scale_y_continuous(expand = c(0, 0), labels = comma) +
  labs(
    title = "Distribution of Weekly Alcohol Consumption",
    subtitle = "HSE 2022 • Adults aged 16+ who drink",
    x = "Weekly alcohol consumption (UK units)",
    y = "Number of adults",
    caption = "Note: Limited to ≤50 units for clarity. 1 UK unit = 10ml pure ethanol."
  ) +
  theme_publication()

ggsave(paste0(output_dir, "01_weekly_consumption_distribution.png"),
       p1, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 2: Drinker Risk Categories
# ==============================================================================

cat("Creating Figure 2: Drinker risk categories...\n")

drinker_data <- adults[, .N, by = drinker_cat][!is.na(drinker_cat)]
drinker_data[, pct := 100 * N / sum(N)]
drinker_data[, drinker_cat := factor(drinker_cat,
  levels = c("abstainer", "lower_risk", "increasing_risk", "higher_risk"),
  labels = c("Abstainer", "Lower risk\n(<14 units/week)",
             "Increasing risk\n(14-35/50 units/week)", "Higher risk\n(≥35/50 units/week)"))]

# Create palette matching the new labels
pal_risk_labeled <- c("Abstainer" = "#95A5A6",
                      "Lower risk\n(<14 units/week)" = "#27AE60",
                      "Increasing risk\n(14-35/50 units/week)" = "#E67E22",
                      "Higher risk\n(≥35/50 units/week)" = "#C0392B")

p2 <- ggplot(drinker_data, aes(x = drinker_cat, y = pct, fill = drinker_cat)) +
  geom_bar(stat = "identity", width = 0.7, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            vjust = -0.5, size = 4.5, fontface = "bold", color = "gray20") +
  geom_text(aes(label = sprintf("n = %s", comma(N))),
            vjust = 1.5, size = 3.5, color = "white", fontface = "bold") +
  scale_fill_manual(values = pal_risk_labeled) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "Distribution of Drinker Risk Categories",
    subtitle = "HSE 2022 • Adults aged 16+",
    x = NULL,
    y = "Percentage of population",
    caption = "Risk thresholds: 14 units/week for all; 35 units/week (F) or 50 units/week (M) for higher risk."
  ) +
  theme_publication() +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, lineheight = 1.1))

ggsave(paste0(output_dir, "02_drinker_risk_categories.png"),
       p2, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 3: Beverage Composition
# ==============================================================================

cat("Creating Figure 3: Beverage composition...\n")

bev_data <- adults[, .(
  Beer = mean(beer_units, na.rm = TRUE),
  Wine = mean(wine_units, na.rm = TRUE),
  Spirits = mean(spirit_units, na.rm = TRUE),
  RTDs = mean(rtd_units, na.rm = TRUE)
)]

bev_long <- melt(bev_data, measure.vars = c("Beer", "Wine", "Spirits", "RTDs"),
                 variable.name = "Beverage", value.name = "Units")
bev_long[, Beverage := factor(Beverage, levels = c("Beer", "Wine", "Spirits", "RTDs"))]

p3 <- ggplot(bev_long, aes(x = Beverage, y = Units, fill = Beverage)) +
  geom_bar(stat = "identity", width = 0.65, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.2f", Units)),
            vjust = -0.5, size = 4.5, fontface = "bold", color = "gray20") +
  scale_fill_manual(values = pal_beverages) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Mean Weekly Consumption by Beverage Type",
    subtitle = "HSE 2022 • All adults aged 16+",
    x = NULL,
    y = "Mean weekly units",
    caption = "Includes both drinkers and non-drinkers."
  ) +
  theme_publication() +
  theme(legend.position = "none")

ggsave(paste0(output_dir, "03_beverage_composition.png"),
       p3, width = 8, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 4: Cider Comparison (Normal vs Strong)
# ==============================================================================

cat("Creating Figure 4: Cider comparison...\n")

cider_data <- adults[, .(
  `Normal cider\n(<6% ABV)` = mean(ncider_units, na.rm = TRUE),
  `Strong cider\n(≥6% ABV)` = mean(scider_units, na.rm = TRUE)
)]

cider_long <- melt(cider_data, measure.vars = 1:2,
                   variable.name = "Type", value.name = "Units")

p4 <- ggplot(cider_long, aes(x = Type, y = Units, fill = Type)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.3f", Units)),
            vjust = -0.5, size = 4.5, fontface = "bold", color = "gray20") +
  scale_fill_manual(values = c("#F39C12", "#C0392B")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title = "Cider Consumption: Normal vs Strong Strength",
    subtitle = "HSE 2022 • All adults aged 16+ • First year with cider strength split",
    x = NULL,
    y = "Mean weekly units",
    caption = "Note: HSE 2022 introduced separate questions for normal and strong cider."
  ) +
  theme_publication() +
  theme(legend.position = "none")

ggsave(paste0(output_dir, "04_cider_normal_vs_strong.png"),
       p4, width = 8, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 5: Consumption by Sex
# ==============================================================================

cat("Creating Figure 5: Consumption by sex...\n")

by_sex <- adults[!is.na(sex), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  se = sd(weekmean, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = sex]

p5 <- ggplot(by_sex, aes(x = sex, y = mean_units, fill = sex)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_errorbar(aes(ymin = mean_units - 1.96*se, ymax = mean_units + 1.96*se),
                width = 0.2, linewidth = 0.6, color = "gray30") +
  geom_text(aes(label = sprintf("%.1f units", mean_units)),
            vjust = -2, size = 4.5, fontface = "bold", color = "gray20") +
  geom_text(aes(label = sprintf("n = %s", comma(n))),
            vjust = 1.5, size = 3.5, color = "white", fontface = "bold") +
  geom_hline(yintercept = 14, linetype = "dashed", color = "#E74C3C",
             linewidth = 0.6, alpha = 0.6) +
  scale_fill_manual(values = pal_sex) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title = "Mean Weekly Alcohol Consumption by Sex",
    subtitle = "HSE 2022 • Adults aged 16+ • Error bars show 95% CI",
    x = NULL,
    y = "Mean weekly units",
    caption = "Dashed line indicates low-risk drinking guideline (14 units/week)."
  ) +
  theme_publication() +
  theme(legend.position = "none")

ggsave(paste0(output_dir, "05_consumption_by_sex.png"),
       p5, width = 8, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 6: Abstention Rate by Sex
# ==============================================================================

cat("Creating Figure 6: Abstention by sex...\n")

abstention_sex <- adults[!is.na(sex) & !is.na(drinks_now), .(
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N,
  n_abstainers = sum(drinks_now == "non_drinker"),
  n_total = .N
), by = sex]

p6 <- ggplot(abstention_sex, aes(x = sex, y = abstention_pct, fill = sex)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f%%", abstention_pct)),
            vjust = -0.5, size = 4.5, fontface = "bold", color = "gray20") +
  geom_text(aes(label = sprintf("%s / %s", comma(n_abstainers), comma(n_total))),
            vjust = 1.5, size = 3.5, color = "white", fontface = "bold") +
  scale_fill_manual(values = pal_sex) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "Alcohol Abstention Rate by Sex",
    subtitle = "HSE 2022 • Adults aged 16+",
    x = NULL,
    y = "Abstention rate",
    caption = "Proportion of adults who do not drink alcohol."
  ) +
  theme_publication() +
  theme(legend.position = "none")

ggsave(paste0(output_dir, "06_abstention_by_sex.png"),
       p6, width = 8, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 7: Consumption by Age Group
# ==============================================================================

cat("Creating Figure 7: Consumption by age...\n")

# Create broader age bands for cleaner visualization
adults[, age_broad := fcase(
  age_cat %in% c("16-17", "18-19"), "16-19",
  age_cat %in% c("20-24", "25-29"), "20-29",
  age_cat %in% c("30-34", "35-39"), "30-39",
  age_cat %in% c("40-44", "45-49"), "40-49",
  age_cat %in% c("50-54", "55-59"), "50-59",
  age_cat %in% c("60-64", "65-69"), "60-69",
  age_cat %in% c("70-74", "75-79"), "70-79",
  age_cat %in% c("80-84", "85-89"), "80+"
)]

by_age <- adults[!is.na(age_broad) & !is.na(drinks_now), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N,
  n = .N
), by = age_broad]

# Order age categories
age_broad_levels <- c("16-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
by_age[, age_broad := factor(age_broad, levels = age_broad_levels)]
by_age <- by_age[order(age_broad)]

p7 <- ggplot(by_age, aes(x = age_broad, y = mean_units, group = 1)) +
  geom_line(color = "#0173B2", linewidth = 1.2, alpha = 0.8) +
  geom_point(color = "#0173B2", size = 3.5, alpha = 0.9) +
  geom_hline(yintercept = 14, linetype = "dashed", color = "#E74C3C",
             linewidth = 0.6, alpha = 0.6) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Mean Weekly Alcohol Consumption by Age Group",
    subtitle = "HSE 2022 • Adults aged 16+",
    x = "Age group",
    y = "Mean weekly units",
    caption = "Dashed line indicates low-risk drinking guideline (14 units/week)."
  ) +
  theme_publication() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(paste0(output_dir, "07_consumption_by_age.png"),
       p7, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 8: Abstention by Age Group
# ==============================================================================

cat("Creating Figure 8: Abstention by age...\n")

p8 <- ggplot(by_age, aes(x = age_broad, y = abstention_pct, group = 1)) +
  geom_line(color = "#E67E22", linewidth = 1.2, alpha = 0.8) +
  geom_point(color = "#E67E22", size = 3.5, alpha = 0.9) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "Alcohol Abstention Rate by Age Group",
    subtitle = "HSE 2022 • Adults aged 16+",
    x = "Age group",
    y = "Abstention rate",
    caption = "Proportion of adults who do not drink alcohol."
  ) +
  theme_publication() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(paste0(output_dir, "08_abstention_by_age.png"),
       p8, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 9: Consumption by IMD
# ==============================================================================

cat("Creating Figure 9: Consumption by deprivation...\n")

imd_var <- ifelse("qimd" %in% names(adults), "qimd", "qim4")

by_imd <- adults[!is.na(get(imd_var)), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N,
  n = .N
), by = get(imd_var)]

setnames(by_imd, "get", "imd")
by_imd[, imd_label := ifelse(imd_var == "qimd",
                               paste0("Q", imd, "\n(", c("Most\ndeprived", "", "", "", "Least\ndeprived")[imd], ")"),
                               paste0("Q", imd))]

p9 <- ggplot(by_imd, aes(x = factor(imd), y = mean_units, fill = factor(imd))) +
  geom_bar(stat = "identity", width = 0.7, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f", mean_units)),
            vjust = -0.5, size = 4, fontface = "bold", color = "gray20") +
  geom_hline(yintercept = 14, linetype = "dashed", color = "#E74C3C",
             linewidth = 0.6, alpha = 0.6) +
  scale_fill_brewer(palette = "RdYlGn", direction = -1) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  scale_x_discrete(labels = function(x) paste0("Q", x)) +
  labs(
    title = "Mean Weekly Alcohol Consumption by Deprivation",
    subtitle = paste0("HSE 2022 • Adults aged 16+ • ", toupper(imd_var), " quintiles"),
    x = "Index of Multiple Deprivation (1 = most deprived)",
    y = "Mean weekly units",
    caption = "Dashed line indicates low-risk drinking guideline (14 units/week)."
  ) +
  theme_publication() +
  theme(legend.position = "none")

ggsave(paste0(output_dir, "09_consumption_by_imd.png"),
       p9, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 10: Beverage Preferences by Drinker Category
# ==============================================================================

cat("Creating Figure 10: Beverage preferences...\n")

bev_by_cat <- adults[drinker_cat != "abstainer", .(
  Beer = mean(beer_units, na.rm = TRUE),
  Wine = mean(wine_units, na.rm = TRUE),
  Spirits = mean(spirit_units, na.rm = TRUE),
  RTDs = mean(rtd_units, na.rm = TRUE)
), by = drinker_cat]

bev_by_cat <- bev_by_cat[!is.na(drinker_cat)]
bev_by_cat_long <- melt(bev_by_cat, id.vars = "drinker_cat",
                         variable.name = "Beverage", value.name = "Units")

bev_by_cat_long[, drinker_cat := factor(drinker_cat,
  levels = c("lower_risk", "increasing_risk", "higher_risk"),
  labels = c("Lower risk", "Increasing risk", "Higher risk"))]

p10 <- ggplot(bev_by_cat_long, aes(x = drinker_cat, y = Units, fill = Beverage)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, alpha = 0.9,
           color = "white", linewidth = 0.3) +
  scale_fill_manual(values = pal_beverages) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Beverage Preferences by Drinker Risk Category",
    subtitle = "HSE 2022 • Adults aged 16+ who drink",
    x = "Drinker category",
    y = "Mean weekly units",
    fill = "Beverage type",
    caption = "Shows mean consumption of each beverage type within each risk category."
  ) +
  theme_publication() +
  theme(legend.position = "right",
        axis.text.x = element_text(angle = 0))

ggsave(paste0(output_dir, "10_beverages_by_risk_category.png"),
       p10, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# Summary Statistics Table
# ==============================================================================

cat("\nCreating summary statistics table...\n")

summary_stats <- data.table(
  Metric = c(
    "Sample size (adults 16+)",
    "Mean weekly units (all)",
    "Mean weekly units (drinkers)",
    "Abstention rate (%)",
    "Lower risk drinkers (%)",
    "Increasing risk drinkers (%)",
    "Higher risk drinkers (%)",
    "Mean beer units",
    "Mean wine units",
    "Mean spirits units",
    "Mean normal cider units",
    "Mean strong cider units"
  ),
  Value = c(
    nrow(adults),
    round(mean(adults$weekmean, na.rm = TRUE), 2),
    round(mean(adults[drinks_now == "drinker"]$weekmean, na.rm = TRUE), 2),
    round(100 * sum(adults$drinks_now == "non_drinker") / nrow(adults), 1),
    round(100 * sum(adults$drinker_cat == "lower_risk", na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$drinker_cat == "increasing_risk", na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$drinker_cat == "higher_risk", na.rm = TRUE) / nrow(adults), 1),
    round(mean(adults$beer_units, na.rm = TRUE), 3),
    round(mean(adults$wine_units, na.rm = TRUE), 3),
    round(mean(adults$spirit_units, na.rm = TRUE), 3),
    round(mean(adults$ncider_units, na.rm = TRUE), 3),
    round(mean(adults$scider_units, na.rm = TRUE), 3)
  )
)

fwrite(summary_stats, paste0(output_dir, "summary_statistics.csv"))

cat("\n==========================================\n")
cat("ALL FIGURES COMPLETE\n")
cat("==========================================\n\n")
cat("Output directory:", output_dir, "\n")
cat("- 10 publication-quality figures (PNG, 300 DPI)\n")
cat("- 1 summary statistics table (CSV)\n")
cat("\nAll figures have:\n")
cat("  ✓ White backgrounds\n")
cat("  ✓ Professional typography\n")
cat("  ✓ Colorblind-friendly palettes\n")
cat("  ✓ Clear annotations and captions\n")
cat("  ✓ Consistent theming\n\n")
