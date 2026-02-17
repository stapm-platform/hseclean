# Complete fresh install of hseclean package
# This removes corrupted files and reinstalls everything

cat("========================================\n")
cat("FRESH INSTALL OF HSECLEAN PACKAGE\n")
cat("========================================\n\n")

# Step 1: Remove old package if it exists
cat("Step 1: Removing old/corrupted package...\n")
if ("hseclean" %in% rownames(installed.packages())) {
  try(detach("package:hseclean", unload = TRUE), silent = TRUE)
  remove.packages("hseclean")
  cat("  ✓ Old package removed\n")
} else {
  cat("  No existing package found\n")
}

# Step 2: Clean up any loaded namespaces
if ("hseclean" %in% loadedNamespaces()) {
  unloadNamespace("hseclean")
}

# Step 3: Rebuild data files
cat("\nStep 2: Rebuilding data files...\n")
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
  volume = c(284, 330, 440, 330,      # normal beer
             284, 330, 440, 330,      # strong beer
             568, 330, 440, 500,      # normal cider
             568, 330, 500, 500,      # strong cider
             25, 50,                  # spirits, sherry
             175, 125, 250, 750,      # wine
             250, 275, 700)           # pops
)

save(abv_data, file = "data/abv_data.rda", compress = "bzip2")
save(alc_volume_data, file = "data/alc_volume_data.rda", compress = "bzip2")
cat("  ✓ Data files saved\n")

# Step 4: Install the package from local directory
cat("\nStep 3: Installing package from local directory...\n")
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install from current directory (not from GitHub)
# This installs your local version with HSE 2022 support
devtools::install(pkg = ".", upgrade = "never", build_vignettes = FALSE)
cat("  ✓ Package installed from local directory\n")

# Step 5: Verify installation
cat("\nStep 4: Verifying installation...\n")
library(hseclean)

cat("  Checking abv_data:\n")
print(hseclean::abv_data[grepl("cider", beverage, ignore.case = TRUE)])

cat("\n  Checking alc_volume_data:\n")
print(hseclean::alc_volume_data[grepl("cider", beverage, ignore.case = TRUE)])

cat("\n========================================\n")
cat("✓ INSTALLATION COMPLETE!\n")
cat("========================================\n\n")

cat("You can now run: source('tests/test_hse_2022.r')\n")
