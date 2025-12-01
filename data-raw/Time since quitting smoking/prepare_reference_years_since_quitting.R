
# Addressing the problem that years since quit is only provided in categories
# rather than single years of age 
# in the Health Surveys for England >= 2015

# use previous years to get the distribution of years since quitting within these categories
# to use in imputation of the single years
# instead of having assume a uniform distribution of years since quitting 
# within each category

# This code estimates the distribution of time since quitting in years
# based on years 2011 to 2014
# within the categories of years since quitting that are used in later years

library(hseclean)
library(magrittr)
library(data.table)

# load the data with info on kids
cleandata <- function(data) {
  
  data %<>%
    clean_age %>%
    clean_demographic %>% 
    clean_education %>%
    clean_economic_status %>%
    clean_family %>%
    clean_income %>%
    clean_health_and_bio %>%
    smk_status %>%
    smk_former %>%
    smk_quit %>%
    smk_life_history %>%
    smk_amount %>%
    
    select_data(
      ages = 16:89,
      years = 2011:2014,
      
      # variables to retain
      keep_vars = c("wt_int", "psu", "cluster", "year",
                    "age", "sex", "imd_quintile",
                    "cig_smoker_status", "years_since_quit", "years_reg_smoker", "cig_ever",
                    "smk_start_age", "smk_stop_age"
      ),
      
      # The variables that must have complete cases
      complete_vars = c("wt_int", "psu", "cluster", "year",
                        "age", "sex", "imd_quintile", "cig_smoker_status", "years_since_quit")
    )
  
  return(data)
}

# Read and clean each year of data and bind them together in one big dataset

root_dir <- "X:/"

data <- combine_years(list(
  cleandata(read_2011(root = root_dir)),
  cleandata(read_2012(root = root_dir)),
  cleandata(read_2013(root = root_dir)),
  cleandata(read_2014(root = root_dir))
))

data[ , wt_int := wt_int / mean(wt_int), by = "year"]

data <- data[years_since_quit <= 59]

# categorise time since quit as it is in later years
data[, endsmoke_cat := c("0-4", "5-9", "10-14", "15-19", "20-29", "30-39", "40-49", "50-59")[findInterval(
  years_since_quit, c(-1, 5, 10, 15, 20, 30, 40, 50, 1000))]]

# summarise the distribution of times since quitting within each category
quit_years_lkup <- data[ , .(mu = sum(wt_int, na.rm = T)), by = c("endsmoke_cat", "years_since_quit")]
quit_years_lkup[ , p := mu / sum(mu), by = "endsmoke_cat"]

#ggplot(temp) + geom_line(aes(x = years_since_quit, y = p, group = endsmoke_cat))
# note that for the higher numbers of years there bunching at 10, 20, 30, 40 etc. 

quit_years_lkup[ , mu := NULL]

setnames(quit_years_lkup, c("endsmoke_cat", "years_since_quit"), c("ind", "var"))

# Embed the data within the package
usethis::use_data(quit_years_lkup, overwrite = TRUE)



