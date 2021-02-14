
#' Characteristics of smoking \lifecycle{maturing}
#'
#' Clean the variables that describe how much, what and to what level of addiction people smoke.
#'
#' The main variable is the average number of cigarettes smoked per day. For adults, this is calculated
#' from questions about how many cigarettes are smoked typically on a weekday vs. a weekend 
#' (this is a weighted average to account for more weekdays in a week than weekends). For children,
#' this is based on asking how many cigarettes were smoked in the last week. Missing values are imputed as
#' the average amount smoked for an age, sex and IMD quintile subgroup.   
#'
#' We categorise cigarette preferences based on the answer to 'what is the main type of cigarette smoked'. In
#' later years of the Health Survey for England, new questions are added from year 2013 that ask how many handrolled vs. machine rolled
#' cigarettes are smoked on a weekday vs. a weekend.    
#'
#' We also categorise the amount smoked, and use information on the time from waking until smoking the first cigarette.
#' This latter variable has a high level of missingness. Together these categorical variables allow calculation of
#'  \href{https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3307335/}{the heaviness of smoking index}.
#'
#' @param data Data table - the Health Survey for England dataset.
#' @importFrom data.table :=
#' @return
#' \itemize{
#' \item cigs_per_day - numeric (0+)
#' \item smoker_cat (non_smoker, 10_or_less, 11_to_20, 21_to_30, 31_or_more)
#' \item banded_consumption (non_smoker, light, moderate, heavy)
#' \item cig_type (non_smoker, hand rolled, machine rolled)
#' \item units_RYO_tob - numeric (0+) (years 2013+)
#' \item units_FM_cigs - numeric (0+) (years 2013+)
#' \item prop_handrolled - numeric (0-1) (years 2013+)
#' \item time_to_first_cig (non_smoker, less_than_5_minutes, five_to_thirty_minutes,
#' thirty_minutes_but_less_than_1_hour, one_hour_or_more)
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' library(hseclean)
#'
#' data <- read_2017(root = "/Volumes/Shared/")
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- smk_status(data)
#' data <- smk_amount(data)
#'
#' }
#'
smk_amount <- function(
  data
) {
  
  country <- unique(data[ , country][1])
  year <- unique(data[ , year][1])
  
  ####################################################
  # Number of cigarettes smoked per day
  
  # Assign missing values for smokers as zeros
  
  # Adults age >= 16 years
  data[is.na(cigwday), cigwday := 0]
  data[is.na(cigwend), cigwend := 0]
  
  #data[cig_smoker_status == "current" & cigwday >= 0 & cigwend >= 0, cigs_per_day := ((5 * cigwday) + (2 * cigwend)) / 7]
  data[cig_smoker_status == "current", cigs_per_day := ((5 * cigwday) + (2 * cigwend)) / 7]
  
  # current smokers should have an amount smoked per day that is greater than zero
  #data[cig_smoker_status == "current" & cigs_per_day == 0, cigs_per_day := NA]
  
  # Children 8-15 years
  if(country == "England"){
    
    # Assign missing values for smokers as zeros
    data[cig_smoker_status == "current" & age < 16, cigs_per_day := 0]
    
    data[cig_smoker_status == "current" & age < 16 & kcignum > 0, cigs_per_day := kcignum / 7]
    #data[cig_smoker_status == "current" & age < 16 & kcignum == 0, cigs_per_day := 1 / 7]
    
    # I sometimes smoke, but I don't smoke every week
    data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 4, cigs_per_day := .25]
    
    # I smoke between one and six cigarettes a week
    data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 5, cigs_per_day := 3]
    
    # I smoke more than six cigarettes a week
    data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 6, cigs_per_day := 7]
    
    data[ , `:=` (kcigreg = NULL, kcignum = NULL, kcigweek = NULL, kcigregg = NULL)]
    
    # For missing, fill with average for each age, sex and IMD quintile
    #data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = T)
    
  }
  
  # In SHeS, no smoking data for children
  if(country == "Scotland") {
    
    data[age < 16, cigs_per_day := NA]
    
    # For missing, fill with average for each age, sex and IMD quintile, above 16
    #data <- impute_mean(data, "cigs_per_day", remove_zeros = T)
  }
  
  # For non-smokers = 0
  data[cig_smoker_status %in% c("never", "former"), cigs_per_day := 0]
  data[is.na(cig_smoker_status), cigs_per_day := NA]
  
  #remove_vars <- c("cigwday", "cigwend")
  #data[ , (remove_vars) := NULL]
  
  
  if(country == "England"){
    
    ####################################################
    # Categorise cigarette preferences
    
    # Do this based on "cigtyp" - the main type of cigarette smoked
    # This variable is the only question on cigarette type that is asked consistently across years
    
    data[cig_smoker_status %in% c("never", "former"), cig_type := "non_smoker"]
    data[cig_smoker_status == "current" & cigtyp == 1, cig_type := "machine_rolled"] # tipped
    data[cig_smoker_status == "current" & cigtyp == 2, cig_type := "machine_rolled"] # untipped
    data[cig_smoker_status == "current" & cigtyp == 3, cig_type := "hand_rolled"]
    
    ####################################################
    # Divide the number of cigarettes smoked per day into factory-made and hand-rolled
    
    if(year >= 2013) {
      
      data[cig_smoker_status == "current" & !is.na(cigs_per_day) & is.na(rollwk), `:=`(rollwk = 0)]
      data[cig_smoker_status == "current" & !is.na(cigs_per_day) & is.na(rollwe), `:=`(rollwe = 0)]
      
      data[cig_smoker_status != "current", `:=`(rollwk = 0, rollwe = 0)]
      data[cig_smoker_status != "current" & is.na(cigs_per_day), `:=`(rollwk = NA, rollwe = NA)]
      
      data[cig_smoker_status == "current", units_RYO_tob := ((5 * rollwk) + (2 * rollwe)) / 7]
      data[cig_smoker_status != "current", units_RYO_tob := 0]
      
      data[ , units_FM_cigs := cigs_per_day - units_RYO_tob]
      
      # There are some inconsistencies in the data
      # it looks like this is often due to a typo - 
      # and all cigs are handrolled but the numbers have not been entered the same 
      # in cigwday and rollwk or cigwend and rollwe
      
      # Fix this by assuming that whenever units_FM_cigs < 0 then all cigarettes are handrolled
      data[units_FM_cigs < 0 & cig_type == "hand_rolled", units_FM_cigs := 0]
      
      data[cigs_per_day == 0 & units_RYO_tob > 0, cigs_per_day := units_RYO_tob]
      
      data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = TRUE, strat_vars = c("year", "sex", "imd_quintile", "age_cat"))
      data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = TRUE, strat_vars = c("year", "imd_quintile"))
      
      data[cigs_per_day > 0 & cig_type == "machine_rolled" & units_FM_cigs == 0, units_FM_cigs := cigs_per_day]
      data[cigs_per_day > 0 & cig_type == "hand_rolled" & units_RYO_tob == 0, units_RYO_tob := cigs_per_day]
      
      # Calculate proportion of handrolled cigarettes
      data[ , prop_handrolled := units_RYO_tob / cigs_per_day]
      
      data <- hseclean::impute_mean(data, "prop_handrolled", remove_zeros = FALSE, strat_vars = c("year", "sex", "imd_quintile", "age_cat"))
      data <- hseclean::impute_mean(data, "prop_handrolled", remove_zeros = FALSE, strat_vars = c("year", "imd_quintile"))
      
      data[!is.na(cigs_per_day) & (is.na(units_RYO_tob) | (units_RYO_tob == 0 & units_FM_cigs == 0)), units_RYO_tob := cigs_per_day * prop_handrolled]
      data[!is.na(cigs_per_day) & (is.na(units_RYO_tob) | (units_RYO_tob == 0 & units_FM_cigs == 0)), units_FM_cigs := cigs_per_day * (1 - prop_handrolled)]
      
      data[cigs_per_day > 0 & units_RYO_tob == 0 & units_FM_cigs == 0, `:=`(units_RYO_tob = NA, units_FM_cigs = NA, prop_handrolled = NA)]
      
      data[cig_smoker_status != "current", `:=`(cigs_per_day = NA, cig_type = NA, units_RYO_tob = NA, units_FM_cigs = NA, prop_handrolled = NA)]
      
      data[is.na(cig_type) & prop_handrolled > .5, cig_type := "hand_rolled"]
      data[is.na(cig_type) & prop_handrolled <= .5, cig_type := "machine_rolled"]
      
      data[prop_handrolled == 1, units_FM_cigs := 0]
      
      data[prop_handrolled > 1, `:=`(units_FM_cigs = 0, prop_handrolled = 1, units_RYO_tob = cigs_per_day)]
    
      # check  
      #data[cig_smoker_status == "current" & cigs_per_day != (units_FM_cigs + units_RYO_tob)]
    
    }
    
    
    if(year < 2013) {
      
      data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = TRUE)
      
      data[cig_smoker_status != "current", `:=`(cigs_per_day = NA, cig_type = NA)]
      
    }
    
    
  }
  
  data[, units_RYO_tob := as.double(round(units_RYO_tob, 3))]
  data[, units_FM_cigs := as.double(round(units_FM_cigs, 3))]
  
  data[ , cigs_per_day := units_RYO_tob + units_FM_cigs]
  
  
  ####################################################
  # Categorise daily smoking
  
  # Version 1
  data[cig_smoker_status %in% c("never", "former"), smoker_cat := "non_smoker"]
  data[cig_smoker_status == "current" & cigs_per_day <= 10, smoker_cat := "10_or_less"]
  data[cig_smoker_status == "current" & cigs_per_day > 10 & cigs_per_day <= 20, smoker_cat := "11_to_20"]
  data[cig_smoker_status == "current" & cigs_per_day > 20 & cigs_per_day <= 30, smoker_cat := "21_to_30"]
  data[cig_smoker_status == "current" & cigs_per_day > 30, smoker_cat := "31_or_more"]
  
  # Version 2
  data[cig_smoker_status %in% c("never", "former"), banded_consumption := "non_smoker"]
  data[cig_smoker_status == "current", banded_consumption := "light"]
  data[smoker_cat == "11_to_20", banded_consumption := "moderate"]
  data[smoker_cat %in% c("21_to_30", "31_or_more"), banded_consumption := "heavy"]
  
  
  
  if(country == "England"){
    
    ####################################################
    # Time from waking until smoking
    
    data[cig_smoker_status %in% c("never", "former"), time_to_first_cig := "non_smoker"]
    data[cig_smoker_status == "current" & firstcig == 1, time_to_first_cig := "less_than_5_minutes"]
    data[cig_smoker_status == "current" & firstcig %in% 2:3, time_to_first_cig := "five_to_thirty_minutes"]
    data[cig_smoker_status == "current" & firstcig == 4, time_to_first_cig := "thirty_minutes_but_less_than_1_hour"]
    data[cig_smoker_status == "current" & firstcig %in% 5:6, time_to_first_cig := "one_hour_or_more"]
    
    # For children, assume time from waking to first cigarette is longest
    data[cig_smoker_status == "current" & age < 16 & is.na(time_to_first_cig), time_to_first_cig := "one_hour_or_more"]
    
    remove_vars <- c("cigdyal", "cigtyp", "firstcig")
    data[ , (remove_vars) := NULL]
    
  }
  
  
  return(data[])
}

