# HSE 2022 - 
# ==============================================================================

library(data.table)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(patchwork)  # For combining plots



# Load functions
if (requireNamespace("hseclean", quietly = TRUE)) {
  library(hseclean)
  USE_PACKAGE <- TRUE
} else {
  USE_PACKAGE <- FALSE
  if(file.exists("data/abv_data_2022.rda")) {
    load("data/abv_data_2022.rda")
    abv_data <- abv_data_2022
  } else {
    load("data/abv_data.rda")
  }
  load("data/alc_volume_data.rda")
  source("R/alc_drink_freq.R")
  source("R/read_2022.R")
  source("R/clean_age.R")
  source("R/alc_drink_now_allages.R")
  source("R/alc_weekmean_adult.R")
  source("R/theme_publication.R")
}

# Output directory
output_dir <- "figures_2022_innovative/"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Load and process data
cat("\nLoading and processing data...\n")
data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)

data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)

if (!USE_PACKAGE) {
  data_2022 <- alc_weekmean_adult(data_2022, abv_data = abv_data, volume_data = alc_volume_data)
} else {
  data_2022 <- alc_weekmean_adult(data_2022)
}

adults <- data_2022[age >= 16]

# IMPORTANT: Convert numeric sex codes to labeled factors
# HSE coding: 1 = Male, 2 = Female
adults[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]

cat("  Processed:", nrow(adults), "adults\n\n")

# ==============================================================================
# FIGURE 1: Population Pyramid of Drinking Patterns
# ==============================================================================

cat("Creating Figure 1: Population drinking pyramid...\n")

# Order age categories (match clean_age() output)
age_levels <- c("16-17", "18-19", "20-24", "25-29", "30-34", "35-39", "40-44",
                "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79",
                "80-84", "85-89")

# Prepare data by sex and age
pyramid_data <- adults[!is.na(sex) & !is.na(age_cat), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  n = .N
), by = .(sex, age_cat)]

# Aggregate into broader age bands for cleaner visualization
pyramid_data[, age_broad := fcase(
  age_cat %in% c("16-17", "18-19"), "16-19",
  age_cat %in% c("20-24", "25-29"), "20-29",
  age_cat %in% c("30-34", "35-39"), "30-39",
  age_cat %in% c("40-44", "45-49"), "40-49",
  age_cat %in% c("50-54", "55-59"), "50-59",
  age_cat %in% c("60-64", "65-69"), "60-69",
  age_cat %in% c("70-74", "75-79"), "70-79",
  age_cat %in% c("80-84", "85-89"), "80+"
)]

pyramid_broad <- pyramid_data[, .(
  mean_units = weighted.mean(mean_units, n),
  n = sum(n)
), by = .(sex, age_broad)]

# Create male/female with opposite directions
pyramid_broad[sex == "Male", mean_units_plot := -mean_units]
pyramid_broad[sex == "Female", mean_units_plot := mean_units]

age_broad_levels <- c("16-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
pyramid_broad[, age_broad := factor(age_broad, levels = age_broad_levels)]

p1 <- ggplot(pyramid_broad, aes(x = age_broad, y = mean_units_plot, fill = sex)) +
  geom_bar(stat = "identity", width = 0.8, alpha = 0.9) +
  geom_hline(yintercept = 0, color = "gray30", linewidth = 0.8) +
  coord_flip() +
  scale_y_continuous(
    labels = function(x) abs(x),
    breaks = seq(-20, 20, by = 5),
    limits = c(-20, 20)
  ) +
  scale_fill_manual(values = c("Male" = "#3498DB", "Female" = "#E74C3C"),
                    labels = c("Male", "Female")) +
  labs(
    title = "Weekly Alcohol Consumption Across the Lifespan",
    subtitle = "HSE 2022 • Mean units per week by age and sex",
    x = "Age group",
    y = "Mean weekly units",
    fill = NULL,
    caption = "Left (blue) = Males | Right (red) = Females"
  ) +
  theme_publication() +
  theme(
    legend.position = "top",
    panel.grid.major.y = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.major.x = element_line(color = "gray85", linewidth = 0.3)
  )

ggsave(paste0(output_dir, "01_population_pyramid_drinking.png"),
       p1, width = 10, height = 8, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 2: Risk Category Distribution by Sex (Stacked)
# ==============================================================================

cat("Creating Figure 2: Risk distribution by sex...\n")

risk_by_sex <- adults[!is.na(sex) & !is.na(drinker_cat), .N, by = .(sex, drinker_cat)]
risk_by_sex[, pct := 100 * N / sum(N), by = sex]

risk_by_sex[, drinker_cat := factor(drinker_cat,
  levels = c("abstainer", "lower_risk", "increasing_risk", "higher_risk"),
  labels = c("Abstainer", "Lower risk", "Increasing risk", "Higher risk"))]

p2 <- ggplot(risk_by_sex, aes(x = sex, y = pct, fill = drinker_cat)) +
  geom_bar(stat = "identity", position = "stack", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = ifelse(pct > 5, sprintf("%.1f%%", pct), "")),
            position = position_stack(vjust = 0.5), size = 3.5, fontface = "bold", color = "white") +
  scale_fill_manual(values = c("Abstainer" = "#95A5A6", "Lower risk" = "#27AE60",
                                "Increasing risk" = "#E67E22", "Higher risk" = "#C0392B")) +
  scale_y_continuous(expand = c(0, 0), labels = function(x) paste0(x, "%")) +
  labs(
    title = "Drinking Risk Profile by Sex",
    subtitle = "HSE 2022 • Distribution of risk categories",
    x = NULL,
    y = "Percentage",
    fill = "Risk category",
    caption = "Lower risk: <14 units/week | Increasing: 14-35(F)/50(M) | Higher: ≥35(F)/50(M)"
  ) +
  theme_publication() +
  theme(legend.position = "right")

ggsave(paste0(output_dir, "02_risk_distribution_by_sex.png"),
       p2, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 3: Beverage Portfolio Heatmap
# ==============================================================================

cat("Creating Figure 3: Beverage consumption heatmap...\n")

# Calculate beverage consumption by age and sex - use broader age bands
bev_heatmap <- adults[!is.na(sex) & !is.na(age_cat), .(
  Beer = mean(beer_units, na.rm = TRUE),
  Wine = mean(wine_units, na.rm = TRUE),
  Spirits = mean(spirit_units, na.rm = TRUE),
  RTDs = mean(rtd_units, na.rm = TRUE)
), by = .(sex, age_cat)]

# Aggregate to broader age bands
bev_heatmap[, age_broad := fcase(
  age_cat %in% c("16-17", "18-19"), "16-19",
  age_cat %in% c("20-24", "25-29"), "20-29",
  age_cat %in% c("30-34", "35-39"), "30-39",
  age_cat %in% c("40-44", "45-49"), "40-49",
  age_cat %in% c("50-54", "55-59"), "50-59",
  age_cat %in% c("60-64", "65-69"), "60-69",
  age_cat %in% c("70-74", "75-79"), "70-79",
  age_cat %in% c("80-84", "85-89"), "80+"
)]

bev_broad <- bev_heatmap[, .(
  Beer = mean(Beer, na.rm = TRUE),
  Wine = mean(Wine, na.rm = TRUE),
  Spirits = mean(Spirits, na.rm = TRUE),
  RTDs = mean(RTDs, na.rm = TRUE)
), by = .(sex, age_broad)]

age_broad_levels <- c("16-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
bev_broad[, age_broad := factor(age_broad, levels = age_broad_levels)]

bev_long <- melt(bev_broad, id.vars = c("sex", "age_broad"),
                 variable.name = "Beverage", value.name = "Units")

p3 <- ggplot(bev_long, aes(x = Beverage, y = age_broad, fill = Units)) +
  geom_tile(color = "white", linewidth = 1) +
  geom_text(aes(label = sprintf("%.1f", Units)), size = 3, fontface = "bold", color = "white") +
  scale_fill_gradient2(low = "#f7fbff", mid = "#6baed6", high = "#08306b",
                       midpoint = 2.5, limits = c(0, NA)) +
  facet_wrap(~ sex, ncol = 2) +
  labs(
    title = "Beverage Preferences Across Age and Sex",
    subtitle = "HSE 2022 • Mean weekly units by beverage type",
    x = "Beverage type",
    y = "Age group",
    fill = "Weekly\nunits",
    caption = "Darker colors indicate higher consumption"
  ) +
  theme_publication() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 0),
    strip.background = element_rect(fill = "gray95")
  )

ggsave(paste0(output_dir, "03_beverage_heatmap.png"),
       p3, width = 10, height = 8, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 4: Cider Revolution - Before/After Concept
# ==============================================================================

cat("Creating Figure 4: Cider strength analysis...\n")

# Calculate cider metrics
cider_stats <- adults[, .(
  `Normal cider drinkers` = sum(ncider_units > 0, na.rm = TRUE),
  `Strong cider drinkers` = sum(scider_units > 0, na.rm = TRUE),
  `Normal: Mean units` = mean(ncider_units[ncider_units > 0], na.rm = TRUE),
  `Strong: Mean units` = mean(scider_units[scider_units > 0], na.rm = TRUE)
)]

# Create comparison data
cider_comp <- data.table(
  Type = c("Normal cider\n(<6% ABV)", "Strong cider\n(≥6% ABV)"),
  Prevalence = c(
    100 * cider_stats$`Normal cider drinkers` / nrow(adults),
    100 * cider_stats$`Strong cider drinkers` / nrow(adults)
  ),
  Mean_Units = c(
    cider_stats$`Normal: Mean units`,
    cider_stats$`Strong: Mean units`
  )
)

# Create two-panel plot
p4a <- ggplot(cider_comp, aes(x = Type, y = Prevalence, fill = Type)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f%%", Prevalence)),
            vjust = -0.5, size = 5, fontface = "bold", color = "gray20") +
  scale_fill_manual(values = c("#F39C12", "#C0392B")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)), labels = function(x) paste0(x, "%")) +
  labs(title = "Prevalence", x = NULL, y = "% of population") +
  theme_publication() +
  theme(legend.position = "none", axis.text.x = element_text(size = 9))

p4b <- ggplot(cider_comp, aes(x = Type, y = Mean_Units, fill = Type)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.2f", Mean_Units)),
            vjust = -0.5, size = 5, fontface = "bold", color = "gray20") +
  scale_fill_manual(values = c("#F39C12", "#C0392B")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Intensity (among drinkers)", x = NULL, y = "Mean units/week") +
  theme_publication() +
  theme(legend.position = "none", axis.text.x = element_text(size = 9))

p4 <- p4a + p4b +
  plot_annotation(
    title = "The Cider Split: Normal vs Strong Strength",
    subtitle = "HSE 2022 • First year measuring normal (<6%) and strong (≥6%) cider separately",
    caption = "Strong cider drinkers are less common but consume more units per week",
    theme = theme_publication()
  )

ggsave(paste0(output_dir, "04_cider_split_analysis.png"),
       p4, width = 12, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 5: Abstention Gradient
# ==============================================================================

cat("Creating Figure 5: Abstention patterns...\n")

abstention_data <- adults[!is.na(sex) & !is.na(age_cat), .(
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N,
  n = .N
), by = .(sex, age_cat)]

abstention_data <- abstention_data[age_cat %in% age_levels]
abstention_data[, age_cat := factor(age_cat, levels = age_levels)]
abstention_data <- abstention_data[!is.na(age_cat)]

# Aggregate into broader categories for cleaner visualization
abstention_data[, age_broad := fcase(
  age_cat %in% c("16-17", "18-19"), "16-19",
  age_cat %in% c("20-24", "25-29"), "20-29",
  age_cat %in% c("30-34", "35-39"), "30-39",
  age_cat %in% c("40-44", "45-49"), "40-49",
  age_cat %in% c("50-54", "55-59"), "50-59",
  age_cat %in% c("60-64", "65-69"), "60-69",
  age_cat %in% c("70-74", "75-79"), "70-79",
  age_cat %in% c("80-84", "85-89"), "80+"
)]

abstention_broad <- abstention_data[, .(
  abstention_pct = weighted.mean(abstention_pct, n),
  n = sum(n)
), by = .(sex, age_broad)]

age_broad_levels <- c("16-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
abstention_broad[, age_broad := factor(age_broad, levels = age_broad_levels)]

p5 <- ggplot(abstention_broad, aes(x = age_broad, y = abstention_pct, color = sex, group = sex)) +
  geom_line(linewidth = 1.5, alpha = 0.8) +
  geom_point(size = 4, alpha = 0.9) +
  geom_text(aes(label = sprintf("%.0f%%", abstention_pct)),
            vjust = -1.2, size = 3.5, fontface = "bold", show.legend = FALSE) +
  scale_color_manual(values = c("Male" = "#3498DB", "Female" = "#E74C3C")) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.15)), labels = function(x) paste0(x, "%")) +
  labs(
    title = "Alcohol Abstention Across the Lifespan",
    subtitle = "HSE 2022 • Percentage who do not drink alcohol",
    x = "Age group",
    y = "Abstention rate",
    color = NULL,
    caption = "Abstention is highest among youngest and oldest adults"
  ) +
  theme_publication() +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 0)
  )

ggsave(paste0(output_dir, "05_abstention_gradient.png"),
       p5, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# FIGURE 6: The 14-Unit Threshold
# ==============================================================================

cat("Creating Figure 6: Distribution around risk threshold...\n")

# Create bins around 14 units
adults_drinkers <- adults[drinks_now == "drinker" & weekmean > 0 & weekmean <= 50]
adults_drinkers[, risk_zone := cut(weekmean,
  breaks = c(0, 7, 14, 21, 35, 50),
  labels = c("0-7\n(Very low)", "7-14\n(Low)", "14-21\n(Moderate)", "21-35\n(High)", "35-50\n(Very high)"),
  include.lowest = TRUE
)]

risk_dist <- adults_drinkers[!is.na(risk_zone), .N, by = risk_zone]
risk_dist[, pct := 100 * N / sum(N)]

p6 <- ggplot(risk_dist, aes(x = risk_zone, y = pct, fill = risk_zone)) +
  geom_bar(stat = "identity", width = 0.7, alpha = 0.9, color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.1f%%\n(n=%s)", pct, comma(N))),
            vjust = -0.3, size = 4, fontface = "bold", color = "gray20") +
  scale_fill_manual(values = c("#27AE60", "#F39C12", "#E67E22", "#E74C3C", "#C0392B")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)), labels = function(x) paste0(x, "%")) +
  geom_vline(xintercept = 2.5, linetype = "dashed", color = "gray20", linewidth = 1) +
  annotate("text", x = 2.5, y = max(risk_dist$pct) * 0.9,
           label = "14 units/week\nthreshold", hjust = -0.1, size = 4, fontface = "bold", color = "gray20") +
  labs(
    title = "How Much Do Drinkers Actually Drink?",
    subtitle = "HSE 2022 • Distribution of weekly consumption among drinkers",
    x = "Weekly consumption (units)",
    y = "Percentage of drinkers",
    caption = "UK guideline: Keep consumption below 14 units/week to minimize health risks"
  ) +
  theme_publication() +
  theme(legend.position = "none", axis.text.x = element_text(size = 10))

ggsave(paste0(output_dir, "06_threshold_distribution.png"),
       p6, width = 10, height = 6, dpi = 300, bg = "white")

# ==============================================================================
# Summary Statistics
# ==============================================================================

cat("\nCreating summary statistics...\n")

summary_stats <- data.table(
  Metric = c(
    "Total adults (16+)",
    "Mean weekly units (all)",
    "Mean weekly units (drinkers)",
    "Median weekly units (drinkers)",
    "Abstention rate (%)",
    "% Exceeding 14 units/week",
    "% Higher risk drinkers",
    "Beer drinkers (%)",
    "Wine drinkers (%)",
    "Normal cider drinkers (%)",
    "Strong cider drinkers (%)"
  ),
  Value = c(
    nrow(adults),
    round(mean(adults$weekmean, na.rm = TRUE), 2),
    round(mean(adults[drinks_now == "drinker"]$weekmean, na.rm = TRUE), 2),
    round(median(adults[drinks_now == "drinker" & weekmean > 0]$weekmean, na.rm = TRUE), 2),
    round(100 * sum(adults$drinks_now == "non_drinker") / nrow(adults), 1),
    round(100 * sum(adults$weekmean > 14, na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$drinker_cat == "higher_risk", na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$beer_units > 0, na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$wine_units > 0, na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$ncider_units > 0, na.rm = TRUE) / nrow(adults), 1),
    round(100 * sum(adults$scider_units > 0, na.rm = TRUE) / nrow(adults), 1)
  )
)

fwrite(summary_stats, paste0(output_dir, "summary_statistics.csv"))

cat("\n==========================================\n")
cat("ALL FIGURES COMPLETE\n")
cat("==========================================\n\n")
cat("Output directory:", output_dir, "\n")

