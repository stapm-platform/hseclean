
# Example of multiply imputing missing values in the cleaned HSE data

library(hseclean)
library(magrittr)

#-----------------------------------------------------
# Read and clean the HSE tobacco and alcohol data

root_dir <- "/Volumes/Shared/"

cleandata <- function(data) {
  
  data %<>%
    clean_age %>%
    clean_family %>%
    clean_demographic %>% 
    clean_education %>%
    clean_economic_status %>%
    clean_income %>%
    clean_health_and_bio %>%
    smk_status %>%
    smk_former %>%
    smk_life_history %>%
    smk_amount %>%
    alc_drink_now_allages %>%
    alc_weekmean_adult %>%
    alc_sevenday_adult %>%
    alc_sevenday_child %>%
    
    select_data(
      ages = 12:89,
      years = 2001:2017,
      
      # variables to retain
      keep_vars = c("wt_int", "psu", "cluster", "year", "quarter",
                    "age", "age_cat", "censor_age", "sex", "imd_quintile",
                    "ethnicity_4cat", "ethnicity_2cat",
                    "degree", "relationship_status", "employ2cat", "social_grade", "kids", "income5cat",
                    "nssec3_lab", "man_nonman", "activity_lstweek", "eduend4cat",
                    
                    "hse_cancer", "hse_endocrine", "hse_heart", "hse_mental", "hse_nervous", "hse_eye", "hse_ear", "hse_respir", 
                    "hse_disgest", "hse_urinary", "hse_skin", "hse_muscskel", "hse_infect", "hse_blood",
                    
                    "weight", "height",
                    
                    "cig_smoker_status", "years_since_quit", "years_reg_smoker", "cig_ever",
                    "cigs_per_day", "smoker_cat", "banded_consumption", "cig_type", "time_to_first_cig",
                    "smk_start_age", "smk_stop_age", "censor_age",
                    
                    "drinks_now", 
                    "drink_freq_7d", "n_days_drink", "peakday", "binge_cat",
                    "beer_units", "wine_units", "spirit_units", "rtd_units", 
                    "weekmean", 
                    "perc_spirit_units", "perc_wine_units", "perc_rtd_units", "perc_beer_units", 
                    "drinker_cat", 
                    "spirits_pref_cat", "wine_pref_cat", "rtd_pref_cat", "beer_pref_cat", 
                    "total_units7_ch"
      ),
      
      # The variables that must have complete cases
      complete_vars = c("age", "sex", "year", "quarter", "psu", "cluster")
    )
  
  return(data)
}

# Read and clean each year of data and bind them together in one big dataset
data <- combine_years(list(
  cleandata(read_2001(root = root_dir)),
  cleandata(read_2002(root = root_dir)),
  cleandata(read_2003(root = root_dir)),
  cleandata(read_2004(root = root_dir)),
  cleandata(read_2005(root = root_dir)),
  cleandata(read_2006(root = root_dir)),
  cleandata(read_2007(root = root_dir)),
  cleandata(read_2008(root = root_dir)),
  cleandata(read_2009(root = root_dir)),
  cleandata(read_2010(root = root_dir)),
  cleandata(read_2011(root = root_dir)),
  cleandata(read_2012(root = root_dir)),
  cleandata(read_2013(root = root_dir)),
  cleandata(read_2014(root = root_dir)),
  cleandata(read_2015(root = root_dir)),
  cleandata(read_2016(root = root_dir)),
  cleandata(read_2017(root = root_dir))
))

# clean the survey weights
data <- clean_surveyweights(data)


#-----------------------------------------------------
# Impute missing values

# variables with missingness
table(data$kids, useNA = "ifany")
table(data$relationship_status, useNA = "ifany")
table(data$ethnicity_4cat, useNA = "ifany")
table(data$imd_quintile, useNA = "ifany")
table(data$eduend4cat, useNA = "ifany")
table(data$degree, useNA = "ifany")


table(data$employ2cat, useNA = "ifany")
table(data$social_grade, useNA = "ifany")


summary(data$weight)

# Set a broader age category variable
data[ , agegroup := c("12-16", "16-17", "18-24", "25-34", "35-49", "50-64", "65-74", "75-89")[findInterval(age, c(-10, 16, 18, 25, 35, 50, 65, 75, 1000))]]

imp <- impute_data_mice(data = data,
                        var_names = c("smk.state", "agegroup", "sex", "imd_quintile", "degree", "kids", "income5cat",
                                      "relationship_status", "employ2cat", "social_grade"),
                        var_methods = c("", "", "", "polr", "logreg", "polr", "polr",
                                        "polyreg", "logreg", "logreg"),
                        n_imputations = 5)


data_imp <- copy(imp$data)

# write imputed data
write.table(data_imp, paste0(root_dir, "ScHARR/PR_Consumption_TA/Projects/Clean HSE data/output/", Sys.Date(), "HSE_2001_to_2017_imputed.txt"), sep = "\t", row.names = F)





