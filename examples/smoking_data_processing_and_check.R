
# Example of processing tobacco data from the Health Survey for England

library(hseclean)

cleandata <- function(data) {
  
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
  
  data <- select_data(
    data,
    ages = 12:89,
    years = 2001:2017,
    keep_vars = c("age", "sex", "imd_quintile", "wt_int", "psu", "cluster", "year", "age_cat", "cig_smoker_status",
                  "smk_start_age", "censor_age",
                  "years_since_quit", "degree", "relationship_status", "employ2cat", "hse_mental", "hse_heart", "hse_respir", "hse_endocrine", "kids", "income5cat"),
    complete_vars = c("age", "sex", "imd_quintile", "cig_smoker_status", "psu", "cluster", "year", "censor_age")
  )
  
  return(data)
}

hse_data <- combine_years(list(
  cleandata(read_2001(root = "/Volumes/Shared/")),
  cleandata(read_2002(root = "/Volumes/Shared/")),
  cleandata(read_2003(root = "/Volumes/Shared/")),
  cleandata(read_2004(root = "/Volumes/Shared/")),
  cleandata(read_2005(root = "/Volumes/Shared/")),
  cleandata(read_2006(root = "/Volumes/Shared/")),
  cleandata(read_2007(root = "/Volumes/Shared/")),
  cleandata(read_2008(root = "/Volumes/Shared/")),
  cleandata(read_2009(root = "/Volumes/Shared/")),
  cleandata(read_2010(root = "/Volumes/Shared/")),
  cleandata(read_2011(root = "/Volumes/Shared/")),
  cleandata(read_2012(root = "/Volumes/Shared/")),
  cleandata(read_2013(root = "/Volumes/Shared/")),
  cleandata(read_2014(root = "/Volumes/Shared/")),
  cleandata(read_2015(root = "/Volumes/Shared/")),
  cleandata(read_2016(root = "/Volumes/Shared/")),
  cleandata(read_2017(root = "/Volumes/Shared/"))
))

hse_data <- clean_surveyweights(hse_data)

setnames(hse_data,
         c("smk_start_age", "cig_smoker_status", "years_since_quit"),
         c("start_age", "smk.state", "time_since_quit"))








