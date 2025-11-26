# % alcohol by volume

abv_data <- data.table(
  beverage = c("nbeerabv", "sbeerabv", "spiritsabv", "sherryabv", "wineabv", "popsabv"),
  abv = c(4.4, 8.4, 38, 17, 12.5, 4.5)
)

usethis::use_data(abv_data, overwrite = TRUE)

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
# The below values should be used specifically for HSE 2022 data processing
# ==============================================================================

# Create ABV data table for HSE 2022
abv_data_2022 <- data.table(
  beverage = c(
    "nbeerabv", # Normal beer
    "sbeerabv", # Strong beer
    "nciderabv", # Normal cider (NEW)
    "sciderabv", # Strong cider (NEW)
    "wineabv", # Wine
    "sherryabv", # Sherry/fortified wine
    "spiritsabv", # Spirits
    "popsabv" # RTDs/alcopops
  ),
  abv = c(
    4.4, # Normal beer - updated for 2022
    7.6, # Strong beer - updated for 2022
    4.6, # Normal cider - new for 2022
    7.4, # Strong cider - new for 2022
    12.5, # Wine - unchanged
    17.5, # Sherry - unchanged
    37.5, # Spirits - unchanged
    5.0 # RTDs - unchanged
  )
)

usethis::use_data(abv_data_2022, overwrite = TRUE)
