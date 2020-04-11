
# The aim of this code is to prepare the data on population numbers
# The latest year of observed data is 2016
# The observed population is stratified by age, sex and IMD quintile

library(data.table)

# Read the Office for National Statistics population estimates from 2001 to 2016
pop_counts <- fread("X:/ScHARR/PR_Mortality_data_TA/Code/model_inputs/Output/stapm_pop_sizes_2019-05-04_mort.tools_1.0.0.csv")

setnames(pop_counts, c("pops"), c("N"))

# Embed the data within the package
usethis::use_data(pop_counts, overwrite = TRUE)

rm(pop_counts)
gc()


