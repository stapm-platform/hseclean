# Rebuild package data with updated cider assumptions
# Run this script from the package root directory

library(data.table)

cat("========================================\n")
cat("REBUILDING PACKAGE DATA FILES\n")
cat("========================================\n\n")

# Step 1: Build abv_data
cat("Step 1: Building abv_data...\n")
abv_data <- data.table(
  beverage = c("nbeerabv", "sbeerabv", "nciderabv", "sciderabv", "spiritsabv", "sherryabv", "wineabv", "popsabv"),
  abv = c(4.4, 8.4, 4.5, 7.5, 38, 17, 12.5, 4.5)
)
print(abv_data)

# Step 2: Build alc_volume_data
cat("\nStep 2: Building alc_volume_data...\n")
alc_volume_data <- data.table(
  beverage = c("nbeerhalfvol", "nbeerscanvol", "nbeerlcanvol", "nbeerbtlvol",
               "sbeerhalfvol", "sbeerscanvol", "sbeerlcanvol", "sbeerbtlvol",
               "nciderpintvol", "nciderscanvol", "nciderlcanvol", "nciderbtlvol",
               "sciderpintvol", "sciderscanvol", "sciderlcanvol", "sciderbtlvol",
               "spiritsvol", "sherryvol",
               "wineglassvol", "winesglassvol", "winelglassvol", "winebtlvol",
               "popsscvol", "popssbvol", "popslbvol"),

  volume = c(284, 330, 440, 330,      # normal beer (half pint, small can, large can, bottle)
             284, 330, 440, 330,      # strong beer (half pint, small can, large can, bottle)
             568, 330, 440, 500,      # normal cider (pint, small can, large can, bottle)
             568, 330, 500, 500,      # strong cider (pint, small can, large can, bottle)
             25, 50,                  # spirits, sherry
             175, 125, 250, 750,      # wine (glass, small glass, large glass, bottle)
             250, 275, 700)           # pops (small can, small bottle, large bottle)
)
print(alc_volume_data)

# Step 3: Save the data files
cat("\nStep 3: Saving data files...\n")

# Save manually to data/ directory
save(abv_data, file = "data/abv_data.rda", compress = "bzip2")
cat("  ✓ Saved data/abv_data.rda\n")

save(alc_volume_data, file = "data/alc_volume_data.rda", compress = "bzip2")
cat("  ✓ Saved data/alc_volume_data.rda\n")

# Step 4: Verify the files
cat("\nStep 4: Verifying saved files...\n")
rm(abv_data, alc_volume_data)
load("data/abv_data.rda")
load("data/alc_volume_data.rda")

cider_vol <- alc_volume_data[grepl("cider", beverage, ignore.case = TRUE)]
cider_abv <- abv_data[grepl("cider", beverage, ignore.case = TRUE)]

cat("\nCider entries in abv_data:\n")
print(cider_abv)

cat("\nCider entries in alc_volume_data:\n")
print(cider_vol)

cat("\n========================================\n")
cat("✓ DATA FILES REBUILT SUCCESSFULLY!\n")
cat("========================================\n\n")

cat("Next steps:\n")
cat("1. Install/reload the package: devtools::load_all() or devtools::install()\n")
cat("2. Run your tests: source('tests/test_hse_2022.r')\n")
