
# The aim of this code is to clean the alcohol data from the Scottish Health Survey (SHeS)
# for use in the Scottish version of STAPM

# note: no questions asked to < 16 year olds in SHeS

# Using functions in the hseclean package
library(hseclean)
library(data.table)
library(magrittr)

# Location of Scottish Health Survey data
# this is downloaded from the UK Data Service https://ukdataservice.ac.uk/
# in tab delimited form

# change folder location as needed
root_dir <- "X:/HAR_PR/PR/Consumption_TA/HSE/Scottish Health Survey (SHeS)/"

# The variables to retain in the cleaned dataset
keep_vars = c(
  "hse_id",
  "wt_int", "psu", "cluster", "year",
  "quarter",
  "age", "age_cat", "sex", "imd_quintile",
  "ethnicity_2cat",
  "degree", "marstat", "relationship_status", "employ2cat", "social_grade", "kids", "income5cat",
  "nssec3_lab", "man_nonman", "activity_lstweek", "eduend4cat",
  "hse_mental",
  "drinks_now",
  "drink_freq_7d", "n_days_drink", "peakday", "binge_cat",
  "beer_units", "wine_units", "spirit_units", "rtd_units",
  "weekmean", "drating", "dnoft", "dnnow", "dnany", "dnevr",
  "perc_spirit_units", "perc_wine_units", "perc_rtd_units", "perc_beer_units",
  "drinker_cat",
  "total_units7_ch")

######
# Test code

data <- read_SHeS_2018(root = root_dir) %>%
  clean_age %>% clean_demographic %>%
  #clean_education %>% clean_economic_status %>% clean_family %>%
  #clean_income %>% clean_health_and_bio %>%

  alc_drink_now_allages %>%
  alc_weekmean_adult %>%
  #alc_sevenday_adult %>%

  select_data(
    ages = 16:89,
    years = 2018,
    #keep_vars = keep_vars,
    keep_vars = c("year", "age", "sex", "imd_quintile", "weekmean", "wt_int"),
    complete_vars = c("sex", "weekmean")
  )

######

# Main processing

# note that the order in which the cleaning functions are applied is important
# e.g. because a cleaned age variable is needed for the processing of other variables

cleandata <- function(data) {

  data <- clean_age(data)
  data <- clean_demographic(data)
  data <- clean_education(data)
  data <- clean_economic_status(data)
  data <- clean_family(data)
  data <- clean_income(data)
  data <- clean_health_and_bio(data)

  data <- alc_drink_now_allages(data)
  data <- alc_weekmean_adult(data)
  data <- alc_sevenday_adult(data)

  data <- select_data(
    data,
    ages = 16:89,
    years = 2008:2019,
    keep_vars = keep_vars,
    complete_vars = c("age", "sex", "imd_quintile", "psu", "cluster", "year")
  )

  return(data)
}

# Apply the cleaning function and bind together the years of data
shes_data <- combine_years(list(
  cleandata(read_SHeS_2008(root = root_dir)),
  cleandata(read_SHeS_2009(root = root_dir)),
  cleandata(read_SHeS_2010(root = root_dir)),
  cleandata(read_SHeS_2011(root = root_dir)),
  cleandata(read_SHeS_2012(root = root_dir)),
  cleandata(read_SHeS_2013(root = root_dir)),
  cleandata(read_SHeS_2014(root = root_dir)),
  cleandata(read_SHeS_2015(root = root_dir)),
  cleandata(read_SHeS_2016(root = root_dir)),
  cleandata(read_SHeS_2017(root = root_dir)),
  cleandata(read_SHeS_2018(root = root_dir)),
  cleandata(read_SHeS_2019(root = root_dir))
))

# Load population data for Scotland
# from here - X:\ScHARR\PR_Mortality_data_TA\data\Processed pop sizes and death rates from VM

#scot_pops <- fread("05_intermediate_data/pop_sizes_scotland_national_v1_2022-12-13_mort.tools_1.5.0.csv")
#setnames(scot_pops, c("pops"), c("N"))

# adjust the survey weights according to the ratio of the real population to the sampled population
#shes_data <- clean_surveyweights(shes_data, pop_data = scot_pops)

# Make age categories
shes_data[, age_cat := c("16-17",
                         "18-24",
                         "25-34",
                         "35-44",
                         "45-54",
                         "55-64",
                         "65-74",
                         "75-89")[findInterval(age, c(-1, 18, 25, 35, 45, 55, 65, 75, 1000))]]

# Checks on data

shes_data[(spirit_units + wine_units + rtd_units + beer_units) != weekmean]

shes_data[drinker_cat != "abstainer" & weekmean == 0]

# some drinkers have no data for average weekly consumption
# remove these individuals from the dataset - rather than imputing the missing data
shes_data <- shes_data[!(drinker_cat != "abstainer" & weekmean == 0)]

shes_data[drinker_cat != "abstainer" & is.na(weekmean)]

nrow(shes_data)

#shes_data[is.na(drinker_cat)]


######## Write the data

# note the package version so that the data can be tagged with it
ver <- packageVersion("hseclean")

# Create library directory if needed
dir <- "data-checks/Scotland_alcohol_data/20_outputs"
if(!dir.exists(dir)) {dir.create(dir)}

write.table(shes_data, paste0(dir, "/alc_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, ".csv"), row.names = F, sep = ",")
saveRDS(shes_data, paste0(dir, "/alc_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, ".rds"))

