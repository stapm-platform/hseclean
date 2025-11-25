# Debug script for Figure 6 and 8 issues
# ==============================================================================

library(data.table)
library(ggplot2)

cat("==========================================\n")
cat("FIGURE 6 & 8 DEBUG\n")
cat("==========================================\n\n")

# Load functions and data
cat("Loading functions...\n")
source("R/read_2022.R")
source("R/clean_age.R")
source("R/alc_drink_now_allages.R")
source("R/alc_weekmean_adult.R")
source("R/theme_publication.R")

if(file.exists("data/abv_data_2022.rda")) {
  load("data/abv_data_2022.rda")
  abv_data <- abv_data_2022
  cat("  ✓ Using 2022-specific ABV data\n")
} else {
  load("data/abv_data.rda")
  cat("  ✓ Using standard ABV data\n")
}
load("data/alc_volume_data.rda")

# Load and process data
cat("\nLoading HSE 2022 data...\n")
data_2022 <- read_2022(
  root = "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/",
  file = "HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab"
)

cat("Processing data...\n")
data_2022 <- clean_age(data_2022)
data_2022 <- alc_drink_now_allages(data_2022)
data_2022 <- alc_weekmean_adult(data_2022, abv_data = abv_data, volume_data = alc_volume_data)

adults <- data_2022[age >= 16]

# IMPORTANT: Convert numeric sex codes to labeled factors
# HSE coding: 1 = Male, 2 = Female
adults[, sex := factor(sex, levels = c(1, 2), labels = c("Male", "Female"))]

cat("  ✓ Processed:", nrow(adults), "adults\n\n")

# ==============================================================================
# CHECK FIGURE 6: Abstention by Sex
# ==============================================================================

cat("==========================================\n")
cat("CHECK FIGURE 6: Abstention by Sex\n")
cat("==========================================\n\n")

cat("drinks_now variable:\n")
cat("  Class:", class(adults$drinks_now), "\n")
cat("  Type:", typeof(adults$drinks_now), "\n")
print(table(adults$drinks_now, useNA = "always"))
cat("\n")

cat("Creating abstention_sex data...\n")
abstention_sex <- adults[!is.na(sex), .(
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N,
  n_abstainers = sum(drinks_now == "non_drinker"),
  n_total = .N
), by = sex]

cat("abstention_sex data:\n")
print(abstention_sex)
cat("\n")

cat("Number of rows:", nrow(abstention_sex), "\n")
cat("Has data?:", nrow(abstention_sex) > 0, "\n\n")

if(nrow(abstention_sex) > 0) {
  cat("Attempting to create Figure 6...\n")
  tryCatch({
    pal_sex <- c(Male = "#3498DB", Female = "#E74C3C")

    p6 <- ggplot(abstention_sex, aes(x = sex, y = abstention_pct, fill = sex)) +
      geom_bar(stat = "identity", width = 0.6, alpha = 0.9, color = "white", linewidth = 0.5) +
      geom_text(aes(label = sprintf("%.1f%%", abstention_pct)),
                vjust = -0.5, size = 4.5, fontface = "bold", color = "gray20") +
      scale_fill_manual(values = pal_sex) +
      labs(title = "Test Figure 6") +
      theme_publication()

    cat("  ✓ Plot created successfully!\n")
    ggsave("test_figure_6.png", p6, width = 8, height = 6, dpi = 150)
    cat("  ✓ Saved as test_figure_6.png\n")
  }, error = function(e) {
    cat("  ✗ ERROR:\n")
    cat("   ", conditionMessage(e), "\n")
  })
} else {
  cat("  ✗ ERROR: abstention_sex has no rows!\n")
}

# ==============================================================================
# CHECK FIGURE 8: Abstention by Age
# ==============================================================================

cat("\n==========================================\n")
cat("CHECK FIGURE 8: Abstention by Age\n")
cat("==========================================\n\n")

cat("age_cat variable:\n")
cat("  Class:", class(adults$age_cat), "\n")
print(table(adults$age_cat, useNA = "always"))
cat("\n")

cat("Creating age_broad...\n")
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

cat("age_broad distribution:\n")
print(table(adults$age_broad, useNA = "always"))
cat("\n")

cat("Creating by_age data...\n")
by_age <- adults[!is.na(age_broad), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  abstention_pct = 100 * sum(drinks_now == "non_drinker") / .N,
  n = .N
), by = age_broad]

age_broad_levels <- c("16-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+")
by_age[, age_broad := factor(age_broad, levels = age_broad_levels)]
by_age <- by_age[order(age_broad)]

cat("by_age data:\n")
print(by_age)
cat("\n")

cat("Number of rows:", nrow(by_age), "\n")
cat("Has data?:", nrow(by_age) > 0, "\n\n")

if(nrow(by_age) > 0) {
  cat("Attempting to create Figure 8...\n")
  tryCatch({
    p8 <- ggplot(by_age, aes(x = age_broad, y = abstention_pct, group = 1)) +
      geom_line(color = "#E67E22", linewidth = 1.2, alpha = 0.8) +
      geom_point(color = "#E67E22", size = 3.5, alpha = 0.9) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.15)),
                        labels = function(x) paste0(x, "%")) +
      labs(title = "Test Figure 8",
           x = "Age group",
           y = "Abstention rate") +
      theme_publication() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

    cat("  ✓ Plot created successfully!\n")
    ggsave("test_figure_8.png", p8, width = 10, height = 6, dpi = 150)
    cat("  ✓ Saved as test_figure_8.png\n")
  }, error = function(e) {
    cat("  ✗ ERROR:\n")
    cat("   ", conditionMessage(e), "\n")
  })
} else {
  cat("  ✗ ERROR: by_age has no rows!\n")
}

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n==========================================\n")
cat("DIAGNOSTIC SUMMARY\n")
cat("==========================================\n\n")

cat("Total adults:", nrow(adults), "\n")
cat("Adults with valid sex:", sum(!is.na(adults$sex)), "\n")
cat("Adults with valid age_cat:", sum(!is.na(adults$age_cat)), "\n")
cat("Adults with valid age_broad:", sum(!is.na(adults$age_broad)), "\n")
cat("Adults with valid drinks_now:", sum(!is.na(adults$drinks_now)), "\n")
cat("Adults who are non_drinkers:", sum(adults$drinks_now == "non_drinker", na.rm = TRUE), "\n\n")

cat("If test figures were created successfully, the issue is NOT with the data.\n")
cat("Check if there are any other issues in the full script.\n\n")

cat("==========================================\n")
cat("DEBUG COMPLETE\n")
cat("==========================================\n")
