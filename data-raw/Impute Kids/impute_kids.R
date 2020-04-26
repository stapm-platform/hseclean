
# This code fits a multinomial model to the number of children in each household
# to fill in the missing data for number of children for years 2015+
# using the last 3 years of data for which number of kids available - 2012-2014

library(hseclean)
library(magrittr)
library(nnet)
library(data.table)

# load the data with info on kids
cleandata <- function(data) {
  
  data %<>%
    clean_age %>%
    clean_demographic %>% 
    clean_education %>%
    clean_economic_status %>%
    clean_family %>%
    
    select_data(
      ages = 0:89,
      years = 2012:2014,
      
      # variables to retain
      keep_vars = c("wt_int", "psu", "cluster", "year",
                    "age", "sex", "imd_quintile", "ethnicity_4cat",
                    "eduend4cat", "degree", 
                    "relationship_status", "kids",
                    "employ2cat", "nssec3_lab", "activity_lstweek", "age_cat"
      ),
      
      # The variables that must have complete cases
      complete_vars = c("wt_int", "psu", "cluster", "year",
                        "age", "sex", "imd_quintile", "ethnicity_4cat",
                        "eduend4cat", "degree", 
                        "relationship_status",
                        "employ2cat", "nssec3_lab", "activity_lstweek")
    )
  
  return(data)
}

# Read and clean each year of data and bind them together in one big dataset

root_dir <- "/Volumes/Shared/"

data <- combine_years(list(
  cleandata(read_2012(root = root_dir)),
  cleandata(read_2013(root = root_dir)),
  cleandata(read_2014(root = root_dir))
))

# Assume that if number of kids in household is missing for these years, then there are no kids in the household
nrow(data[is.na(kids)])
data[is.na(kids), kids := "0"]

# fit multinomial model to number of children
impute_kids_model <- multinom(kids ~ age_cat + sex + relationship_status + ethnicity_4cat + imd_quintile + eduend4cat + degree + nssec3_lab + employ2cat + activity_lstweek, 
               data = data, maxit = 1e3)


# Embed the data within the package
usethis::use_data(impute_kids_model, overwrite = TRUE)




