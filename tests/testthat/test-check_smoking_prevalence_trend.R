test_that("smoking prevalence trend looks ok", {
  
  # Load the required packages
  library(hseclean)
  library(magrittr)
  library(data.table)
  library(stapmr)
  library(ggplot2)
  
  # Set the file path to point to the University of Sheffield X drive
  root_dir <- "/Volumes/Shared/"
  
  # Due to poor internet connection, read each year of raw data and save locally
  
  storage_location <- "/Users/duncangillespie/Documents/HSE/"
  
  #saveRDS(read_2001(root = root_dir), paste0(storage_location, "HSE_2001.rds"))
  #saveRDS(read_2002(root = root_dir), paste0(storage_location, "HSE_2002.rds"))
  #saveRDS(read_2003(root = root_dir), paste0(storage_location, "HSE_2003.rds"))
  #saveRDS(read_2004(root = root_dir), paste0(storage_location, "HSE_2004.rds"))
  #saveRDS(read_2005(root = root_dir), paste0(storage_location, "HSE_2005.rds"))
  #saveRDS(read_2006(root = root_dir), paste0(storage_location, "HSE_2006.rds"))
  #saveRDS(read_2007(root = root_dir), paste0(storage_location, "HSE_2007.rds"))
  #saveRDS(read_2008(root = root_dir), paste0(storage_location, "HSE_2008.rds"))
  #saveRDS(read_2009(root = root_dir), paste0(storage_location, "HSE_2009.rds"))
  #saveRDS(read_2010(root = root_dir), paste0(storage_location, "HSE_2010.rds"))
  #saveRDS(read_2011(root = root_dir), paste0(storage_location, "HSE_2011.rds"))
  #saveRDS(read_2012(root = root_dir), paste0(storage_location, "HSE_2012.rds"))
  #saveRDS(read_2013(root = root_dir), paste0(storage_location, "HSE_2013.rds"))
  #saveRDS(read_2014(root = root_dir), paste0(storage_location, "HSE_2014.rds"))
  #saveRDS(read_2015(root = root_dir), paste0(storage_location, "HSE_2015.rds"))
  #saveRDS(read_2016(root = root_dir), paste0(storage_location, "HSE_2016.rds"))
  #saveRDS(read_2017(root = root_dir), paste0(storage_location, "HSE_2017.rds"))
  #saveRDS(read_2018(root = root_dir), paste0(storage_location, "HSE_2018.rds"))
  
  
  # Apply functions to create the variables for analysis and to retain only the required variables
  
  # The variables to retain
  keep_vars = c(
    # Survey design variables
    "wt_int",
    "psu",
    "cluster",
    "year",
    
    # Social / economic / demographic variables
    "age",
    "age_cat",
    "sex",
    "imd_quintile",
    "degree",
    "relationship_status",
    "kids",
    "employ2cat",
    "income5cat",
    
    # Long term health conditions
    "hse_mental",
    
    # Smoking
    "cig_smoker_status",
    "years_since_quit", "years_reg_smoker", "cig_ever",
    "smk_start_age", "smk_stop_age", "censor_age", 
    "cigs_per_day", "smoker_cat", "hand_rolled_per_day", "machine_rolled_per_day", "prop_handrolled", "cig_type"
    
  )
  
  # The variables that must have complete cases
  complete_vars <- c("age", "sex", "imd_quintile", "year", "psu", "cluster", "cig_smoker_status", "censor_age")
  
  
  #-----------------------------------------------------
  # Read and clean the data
  
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
        ages = 11:89,
        years = 2001:2018,
        
        # variables to retain
        keep_vars = keep_vars,
        
        # The variables that must have complete cases
        complete_vars = complete_vars
      )
    
    return(data)
  }
  
  # Read and clean each year of data and bind them together in one big dataset
  data <- combine_years(list(
    cleandata(readRDS(paste0(storage_location, "HSE_2001.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2002.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2003.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2004.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2005.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2006.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2007.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2008.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2009.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2010.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2011.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2012.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2013.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2014.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2015.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2016.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2017.rds"))),
    cleandata(readRDS(paste0(storage_location, "HSE_2018.rds")))
  ))
  
  # clean the survey weights
  data <- clean_surveyweights(data, pop_data = stapmr::pop_counts)
  
  # remake age categories
  data[, age_cat := c("11-15",
                      "16-17",
                      "18-24",
                      "25-34",
                      "35-44",
                      "45-54",
                      "55-64",
                      "65-74",
                      "75-89")[findInterval(age, c(-1, 16, 18, 25, 35, 45, 55, 65, 75, 1000))]]
  
  setnames(data,
           c("smk_start_age", "cig_smoker_status", "years_since_quit"),
           c("start_age", "smk.state", "time_since_quit"))
  
  
  # Estimate the proportion of smokers for each year and sex
  psmk_data <- prop_summary(
    data,
    "smk.state",
    levels_0 = c("former", "never"),
    levels_1 = "current",
    strat_vars = c("year", "sex")
  )
  
  setnames(psmk_data, "smk.state", "prop_smoke")
  
 
  # Plot the observed data
  p <- ggplot() +
    geom_point(data = psmk_data, aes(x = year, y = 100 * prop_smoke), size = 0.1, alpha = 0.5) +
    geom_errorbar(data = psmk_data, aes(x = year, ymin = 100 * (prop_smoke - (se * 1.96)), ymax = 100 * (prop_smoke + (se *1.96))), alpha = 0.5, width = 0) +
    facet_wrap(~ sex, nrow = 1) +
    theme_minimal() +
    ylab("Percentage")
  
})
