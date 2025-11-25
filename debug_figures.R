# Debug script to diagnose empty figures issue
# ==============================================================================

library(data.table)
library(ggplot2)

cat("==========================================\n")
cat("FIGURE GENERATION DEBUG\n")
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
cat("  ✓ Processed:", nrow(adults), "adults\n\n")

# ==============================================================================
# CHECK 1: Sex variable
# ==============================================================================

cat("==========================================\n")
cat("CHECK 1: Sex Variable\n")
cat("==========================================\n\n")

cat("Sex variable class:", class(adults$sex), "\n")
cat("Sex variable type:", typeof(adults$sex), "\n\n")

cat("Sex value distribution:\n")
print(table(adults$sex, useNA = "always"))
cat("\n")

if(is.factor(adults$sex)) {
  cat("Sex is a FACTOR\n")
  cat("Levels:", levels(adults$sex), "\n")
} else if(is.character(adults$sex)) {
  cat("Sex is a CHARACTER\n")
  cat("Unique values:", unique(adults$sex), "\n")
} else if(is.numeric(adults$sex)) {
  cat("Sex is NUMERIC\n")
  cat("Unique values:", unique(adults$sex), "\n")
}

cat("\nFirst 20 sex values:\n")
print(head(adults$sex, 20))

# ==============================================================================
# CHECK 2: Aggregation behavior
# ==============================================================================

cat("\n==========================================\n")
cat("CHECK 2: Aggregation Behavior\n")
cat("==========================================\n\n")

cat("BEFORE aggregation:\n")
cat("  Sex class:", class(adults$sex), "\n")
cat("  Sex type:", typeof(adults$sex), "\n\n")

# Test aggregation
test_agg <- adults[!is.na(sex) & !is.na(age_cat), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  n = .N
), by = .(sex, age_cat)]

cat("AFTER aggregation:\n")
cat("  Sex class:", class(test_agg$sex), "\n")
cat("  Sex type:", typeof(test_agg$sex), "\n")
cat("  Sex values:\n")
print(table(test_agg$sex, useNA = "always"))
cat("\n")

cat("First 10 aggregated rows:\n")
print(test_agg[1:10, .(sex, age_cat, mean_units, n)])

# ==============================================================================
# CHECK 3: Try creating a simple plot
# ==============================================================================

cat("\n==========================================\n")
cat("CHECK 3: Simple Plot Test\n")
cat("==========================================\n\n")

# Convert sex to factor explicitly
test_agg[, sex := factor(sex, levels = c("Male", "Female"))]

cat("After factor conversion:\n")
cat("  Sex class:", class(test_agg$sex), "\n")
cat("  Sex is factor?:", is.factor(test_agg$sex), "\n")
cat("  Sex levels:", levels(test_agg$sex), "\n")
cat("  Sex values:\n")
print(table(test_agg$sex, useNA = "always"))

# Try by_sex aggregation (like in figures)
by_sex <- adults[!is.na(sex), .(
  mean_units = mean(weekmean, na.rm = TRUE),
  n = .N
), by = sex]

cat("\nby_sex data:\n")
print(by_sex)
cat("\nby_sex sex class:", class(by_sex$sex), "\n")

# Convert to factor
by_sex[, sex := factor(sex, levels = c("Male", "Female"))]

cat("After factor conversion:\n")
print(by_sex)
cat("sex class:", class(by_sex$sex), "\n")
cat("sex levels:", levels(by_sex$sex), "\n")

# Try creating a simple plot
cat("\nAttempting to create simple bar plot...\n")
tryCatch({
  p_test <- ggplot(by_sex, aes(x = sex, y = mean_units, fill = sex)) +
    geom_bar(stat = "identity") +
    scale_fill_manual(values = c("Male" = "blue", "Female" = "red")) +
    labs(title = "Test Plot")

  cat("  ✓ Plot created successfully!\n")
  cat("  Plot has data?:", length(p_test$data$sex) > 0, "\n")

  # Try saving
  ggsave("test_plot.png", p_test, width = 8, height = 6, dpi = 150)
  cat("  ✓ Plot saved as test_plot.png\n")

}, error = function(e) {
  cat("  ✗ ERROR creating plot:\n")
  cat("   ", conditionMessage(e), "\n")
})

# ==============================================================================
# CHECK 4: Check actual values in the data
# ==============================================================================

cat("\n==========================================\n")
cat("CHECK 4: Data Values Check\n")
cat("==========================================\n\n")

cat("weekmean summary:\n")
print(summary(adults$weekmean))
cat("\n")

cat("Number with weekmean > 0:", sum(adults$weekmean > 0, na.rm = TRUE), "\n")
cat("Number with weekmean NA:", sum(is.na(adults$weekmean)), "\n\n")

cat("Sample of actual data:\n")
print(adults[1:20, .(sex, age_cat, weekmean, drinks_now)])

# ==============================================================================
# CHECK 5: Check age_cat variable
# ==============================================================================

cat("\n==========================================\n")
cat("CHECK 5: Age Category Check\n")
cat("==========================================\n\n")

cat("age_cat class:", class(adults$age_cat), "\n")
if(is.factor(adults$age_cat)) {
  cat("age_cat levels:\n")
  print(levels(adults$age_cat))
}
cat("\nage_cat distribution:\n")
print(table(adults$age_cat, useNA = "always"))

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n==========================================\n")
cat("DIAGNOSTIC SUMMARY\n")
cat("==========================================\n\n")

cat("Total adults:", nrow(adults), "\n")
cat("Adults with valid sex:", sum(!is.na(adults$sex)), "\n")
cat("Adults with valid age_cat:", sum(!is.na(adults$age_cat)), "\n")
cat("Adults with valid weekmean:", sum(!is.na(adults$weekmean)), "\n")
cat("Adults with weekmean > 0:", sum(adults$weekmean > 0, na.rm = TRUE), "\n\n")

cat("Sex variable issues?\n")
if(!is.factor(adults$sex) && !is.character(adults$sex)) {
  cat("  ⚠ WARNING: Sex is numeric, should be factor or character\n")
} else {
  cat("  ✓ Sex is", class(adults$sex), "\n")
}

cat("\nIf test_plot.png was created and looks correct, the issue is likely\n")
cat("in the figure generation scripts, not the underlying data.\n\n")

cat("==========================================\n")
cat("DEBUG COMPLETE\n")
cat("==========================================\n")
