
# Example of processing tobacco and alcohol data from the Health Survey for England

library(hseclean)

# apply functions to create the variables for analysis and to retain only the required variables

# The variables to retain
keep_vars <- c(
  "wt_int",
  "psu",
  "cluster",
  "year",
  "quarter",
  "age",
  "age_cat",
  "censor_age",
  "sex",
  "imd_quintile",
  
  "degree",
  "relationship_status",
  "employ2cat",
  "social_grade",
  "kids",
  "income5cat",
  
  "cig_smoker_status",
  "smk_start_age",
  "years_since_quit",
  "cigs_per_day",
  "smoker_cat",
  
  "drinks_now",
  "drink_freq_7d",
  "n_days_drink",
  "peakday",
  "binge_cat",
  "beer_units",
  "wine_units",
  "spirit_units",
  "rtd_units",
  "weekmean",
  "perc_spirit_units",
  "perc_wine_units",
  "perc_rtd_units",
  "perc_beer_units",
  "drinker_cat",
  "spirits_pref_cat",
  "wine_pref_cat",
  "rtd_pref_cat",
  "beer_pref_cat",
  "total_units7_ch"
)

# The variables that must have complete cases
complete_vars <-
  c("age", "sex", "year", "quarter", "psu", "cluster")

# Vary from 2001 to 2017
year <- 2017

data <- read_hse(year, root = "/Volumes/Shared/")

data <- clean_age(data)
data <- clean_family(data)
data <- clean_demographic(data)
data <- clean_education(data)
data <- clean_economic_status(data)
data <- clean_income(data)
data <- clean_health_and_bio(data)

data <- smk_status(data)
data <- smk_former(data)
data <- smk_life_history(data)
data <- smk_amount(data)

data <- alc_drink_now_allages(data)
data <- alc_weekmean_adult(data)
data <- alc_sevenday_adult(data)
data <- alc_sevenday_child(data)
  
data <- select_data(data, ages = 12:89, years = year, keep_vars = keep_vars, complete_vars = complete_vars)

data <- clean_surveyweights(data)



