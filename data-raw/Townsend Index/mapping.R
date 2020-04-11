
# The aim of this code is to produce a file that maps
# quintiles of the Index of Multiple Deprivation onto the Townsend Index of Deprviation

# we used area-level Office for National Statistics data to estimate the statistical association between
# the two metrics of deprivation,

# We used estimates of the Townsend Index from 2001 Census data at Ward level,
# and the Index of Multiple Deprivation 2015 (IMD 2015) at Lower-layer Super Output Area (LSOA) level
# (downloaded from https://census.ukdataservice.ac.uk/get-data/related/deprivation).

# First, we mapped the 2001 definitions of Wards to the 2001 definitions of LSOAs
# (https://data.gov.uk/dataset/fe6e0ebc-8def-4cc6-a228-1968ccca3dd2/lower-layer-super-output-area-2001-to-ward-2001-lookup-in-england-and-wales).

# Second, we mapped the 2001 definitions of LSOAs to the 2011 definitions of LSOAs that are used by the IMD 2015 (https://data.gov.uk/dataset/afc2ed54-f1c5-44f3-b8bb-6454eb0153d0/lower-layer-super-output-area-2001-to-lower-layer-super-output-area-2011-to-local-authority-district-2011-lookup-in-england-and-wales).

library(data.table)

# Estimates of the Townsend Index from 2001 Census data at Ward level
town2001 <- fread("data-raw/Townsend Index/Lookup data/Townsend2001.csv")
setnames(town2001, "Ward-Code", "WD01CD")

# Map the 2001 definitions of Wards to the 2001 definitions of LSOAs
ward_to_lsoa_2001 <- fread("data-raw/Townsend Index/Lookup data/Lower_Layer_Super_Output_Area_2001_to_Ward_2001_Lookup_in_England_and_Wales.csv")

# Merge the above two datasets
town2001 <- merge(town2001, ward_to_lsoa_2001, by = "WD01CD", all = F)

# Map the 2001 definitions of LSOAs to the 2011 definitions of LSOAs that are used by the IMD 2015
lsoa_2001_to_2015 <- fread("data-raw/Townsend Index/Lookup data/Lower_Layer_Super_Output_Area_2001_to_Lower_Layer_Super_Output_Area_2011_to_Local_Authority_District_2011_Lookup_in_England_and_Wales.csv")

# Merge in this new mapping data
town2001 <- merge(town2001, lsoa_2001_to_2015, by = c("LSOA01CD"), all = F)

# Estimates of the Index of Multiple Deprivation 2015 (IMD 2015) at Lower-layer Super Output Area (LSOA) level
imd2015 <- fread("data-raw/Townsend Index/Lookup data/File_1_ID_2015_Index_of_Multiple_Deprivation.csv")
setnames(imd2015, c("LSOA code (2011)", "Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOAs)"), c("LSOA11CD", "imd_decile"))

# Merge in this new mapping data
town2001 <- merge(town2001, imd2015, by = c("LSOA11CD"), all = F)

# Convert IMD deciles to quintiles
town2001[imd_decile %in% 1:2, imd_quintile := 5]
town2001[imd_decile %in% 3:4, imd_quintile := 4]
town2001[imd_decile %in% 5:6, imd_quintile := 3]
town2001[imd_decile %in% 7:8, imd_quintile := 2]
town2001[imd_decile %in% 9:10, imd_quintile := 1]

lkup <- town2001[ , .N, by = c("Quintiles", "imd_quintile")]

# Calculate the probability density function of Townsend quintiles by IMD quintile
lkup[ , p := N / sum(N), by = "imd_quintile"]

lkup[ , N := NULL]

# Reshape the data into wide form
imdq_to_townsend <- dcast(lkup, imd_quintile ~ Quintiles, value.var = "p")

imdq_to_townsend[ , imd_quintile := plyr::revalue(as.character(imd_quintile), c(
  "1" = "1_least_deprived",
  "5" = "5_most_deprived"
))]

setnames(imdq_to_townsend, as.character(1:5), paste0("townsend", 1:5))

# Embed the data within the package
usethis::use_data(imdq_to_townsend, overwrite = TRUE)

rm(town2001, ward_to_lsoa_2001, lsoa_2001_to_2015, imd2015, lkup, imdq_to_townsend)
gc()
