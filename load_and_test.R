# Load package for development and run tests
# This is faster than full installation - good for testing changes

cat("========================================\n")
cat("LOAD & TEST HSE 2022\n")
cat("========================================\n\n")

# Step 1: Rebuild data files
cat("Step 1: Rebuilding data files...\n")
library(data.table)

abv_data <- data.table(
  beverage = c("nbeerabv", "sbeerabv", "nciderabv", "sciderabv",
               "spiritsabv", "sherryabv", "wineabv", "popsabv"),
  abv = c(4.4, 8.4, 4.5, 7.5, 38, 17, 12.5, 4.5)
)

alc_volume_data <- data.table(
  beverage = c("nbeerhalfvol", "nbeerscanvol", "nbeerlcanvol", "nbeerbtlvol",
               "sbeerhalfvol", "sbeerscanvol", "sbeerlcanvol", "sbeerbtlvol",
               "nciderpintvol", "nciderscanvol", "nciderlcanvol", "nciderbtlvol",
               "sciderpintvol", "sciderscanvol", "sciderlcanvol", "sciderbtlvol",
               "spiritsvol", "sherryvol",
               "wineglassvol", "winesglassvol", "winelglassvol", "winebtlvol",
               "popsscvol", "popssbvol", "popslbvol"),
  volume = c(284, 330, 440, 330, 284, 330, 440, 330,
             568, 330, 440, 500, 568, 330, 500, 500,
             25, 50, 175, 125, 250, 750, 250, 275, 700)
)

save(abv_data, file = "data/abv_data.rda", compress = "bzip2")
save(alc_volume_data, file = "data/alc_volume_data.rda", compress = "bzip2")
cat("  ✓ Data files rebuilt\n")

# Step 2: Clean up any conflicting functions from sourced files
cat("\nStep 2: Cleaning up environment...\n")
conflicting_functions <- c("alc_drink_freq", "alc_drink_now_allages", "alc_sevenday_adult",
                          "alc_sevenday_child", "alc_upshift", "alc_weekmean_adult",
                          "read_2018", "read_2019", "read_2021", "read_2022")
for (func in conflicting_functions) {
  if (exists(func, envir = .GlobalEnv)) {
    rm(list = func, envir = .GlobalEnv)
  }
}
cat("  ✓ Environment cleaned\n")

# Step 3: Load package for development (faster than install)
cat("\nStep 3: Loading package with devtools::load_all()...\n")
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Force complete unload
if ("package:hseclean" %in% search()) {
  detach("package:hseclean", unload = TRUE)
}
if ("hseclean" %in% loadedNamespaces()) {
  unloadNamespace("hseclean")
}

# Reload with fresh code
devtools::load_all(".", quiet = TRUE, reset = TRUE)
cat("  ✓ Package loaded with fresh code\n")

# Step 4: Verify cider data
cat("\nStep 4: Verifying cider data...\n")
cat("  Cider ABV entries:\n")
print(hseclean::abv_data[grepl("cider", beverage, ignore.case = TRUE)])
cat("\n  Cider volume entries:\n")
print(hseclean::alc_volume_data[grepl("cider", beverage, ignore.case = TRUE)])

# Step 5: Run tests
cat("\n========================================\n")
cat("Step 5: Running tests...\n")
cat("========================================\n\n")

source("tests/test_hse_2022.r")
