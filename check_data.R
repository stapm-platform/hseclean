# Quick check of what's in the current data files

library(data.table)

cat("Loading current data files...\n")
load("data/alc_volume_data.rda")
load("data/abv_data.rda")

cat("\n=== ABV DATA ===\n")
print(abv_data)

cat("\n=== VOLUME DATA ===\n")
print(alc_volume_data)

cat("\n=== Checking for cider variables ===\n")
cider_vol <- alc_volume_data[grepl("cider", beverage, ignore.case = TRUE)]
cider_abv <- abv_data[grepl("cider", beverage, ignore.case = TRUE)]

if (nrow(cider_vol) > 0) {
  cat("✓ Cider volume data found:\n")
  print(cider_vol)
} else {
  cat("✗ NO cider volume data found - need to rebuild!\n")
}

if (nrow(cider_abv) > 0) {
  cat("\n✓ Cider ABV data found:\n")
  print(cider_abv)
} else {
  cat("\n✗ NO cider ABV data found - need to rebuild!\n")
}
