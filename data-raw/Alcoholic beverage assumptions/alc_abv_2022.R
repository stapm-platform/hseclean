# HSE 2022 Specific ABV Assumptions
# ==============================================================================
# Updated ABV values based on HSE 2022 methodology
#
# Key changes from previous years:
# - Normal beer: 4.4% (updated from 4.0%)
# - Strong beer: 7.6% (updated from 5.5%)
# - Normal cider: 4.6% (NEW - split from unified cider)
# - Strong cider: 7.4% (NEW - split from unified cider)
#
# These values should be used specifically for HSE 2022 data processing
# ==============================================================================

library(data.table)

# Create ABV data table for HSE 2022
abv_data_2022 <- data.table(
  beverage = c(
    "nbeerabv",      # Normal beer
    "sbeerabv",      # Strong beer
    "nciderabv",     # Normal cider (NEW)
    "sciderabv",     # Strong cider (NEW)
    "wineabv",       # Wine
    "sherryabv",     # Sherry/fortified wine
    "spiritsabv",    # Spirits
    "popsabv"        # RTDs/alcopops
  ),
  abv = c(
    4.4,   # Normal beer - updated for 2022
    7.6,   # Strong beer - updated for 2022
    4.6,   # Normal cider - new for 2022
    7.4,   # Strong cider - new for 2022
    12.5,  # Wine - unchanged
    17.5,  # Sherry - unchanged
    37.5,  # Spirits - unchanged
    5.0    # RTDs - unchanged
  )
)

# Save to package data
# Note: This requires the package to be in development mode
# If running standalone, you can save manually:
if(requireNamespace("usethis", quietly = TRUE)) {
  usethis::use_data(abv_data_2022, overwrite = TRUE)
} else {
  # Save to data/ directory manually
  save(abv_data_2022, file = "data/abv_data_2022.rda")
}

cat("HSE 2022 ABV data created successfully\n")
cat("\nABV values for HSE 2022:\n")
print(abv_data_2022)

cat("\n\nChanges from standard ABV assumptions:\n")
cat("- Normal beer: 4.0% → 4.4% (+0.4%)\n")
cat("- Strong beer: 5.5% → 7.6% (+2.1%)\n")
cat("- Normal cider: 4.5% → 4.6% (NEW, +0.1% from previous unified cider)\n")
cat("- Strong cider: NEW at 7.4%\n")
cat("\nAll other beverages unchanged from standard assumptions.\n")
