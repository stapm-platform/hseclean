# Create HSE 2022 ABV data
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

# Save to data/ directory
save(abv_data_2022, file = "data/abv_data_2022.rda")

cat("HSE 2022 ABV data created successfully\n")
cat("\nABV values for HSE 2022:\n")
print(abv_data_2022)

cat("\n\nChanges from standard ABV assumptions:\n")
cat("- Normal beer: 4.0% -> 4.4% (+0.4%)\n")
cat("- Strong beer: 5.5% -> 7.6% (+2.1%)\n")
cat("- Normal cider: 4.5% -> 4.6% (NEW, +0.1% from previous unified cider)\n")
cat("- Strong cider: NEW at 7.4%\n")
cat("\nFile saved to: data/abv_data_2022.rda\n")
