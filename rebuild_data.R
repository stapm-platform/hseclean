# Rebuild package data with updated cider assumptions
# Run this script from the package root directory

library(data.table)

# Rebuild abv_data
source("data-raw/Alcoholic beverage assumptions/alc_abv.R")

# Rebuild alc_volume_data
source("data-raw/Alcoholic beverage assumptions/alc_volume.R")

cat("Data files rebuilt successfully!\n")
cat("abv_data now includes:\n")
print(abv_data)
cat("\nalc_volume_data now includes:\n")
print(alc_volume_data) 