
#' Characteristics of smoking
#'
#' Clean the variables that describe how much, what and to what level of addiction people smoke.
#'
#' The main variable is the average number of cigarettes smoked per day. For adults this is calculated
#' from questions about how many cigarettes are smoked typically on a weekday vs. a weekend. For children,
#' this is based on asking how many cigarettes were smoked in the last week. Missing values are imputed as
#' the average amount smoked for an age, sex and IMD quintile subgroup.
#'
#' We categorise cigarette preferences based on the answer to 'what is the main type of cigarette smoked'. In
#' later years of the Health Survey for England, new questions are added that ask how many handrolled vs. machine rolled
#' cigarettes are smoked on a weekday vs. a weekend. We currently don't use those questions because they were not asked in
#' all years.
#'
#' We also categorise the amount smoked, and use information on the time from waking until smoking the first cigarette.
#' This latter variable has a high level of missingness. Together these categorical variables allow calculation of
#'  \href{https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3307335/}{the heaviness of smoking index}.
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return
#' \itemize{
#' \item cigs_per_day - numeric (0+)
#' \item smoker_cat (non_smoker, 10_or_less, 11_to_20, 21_to_30, 31_or_more)
#' \item banded_consumption (non_smoker, light, moderate, heavy)
#' \item cig_type (non_smoker, tipped, plain_untipped, rollups)
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
#' data <- read_2001()
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

  ####################################################
  # Number of cigarettes smoked per day

  # Adults age >= 16 years
  data[cig_smoker_status == "current" & cigwday >= 0 & cigwend >= 0, cigs_per_day := ((5 * cigwday) + (2 * cigwend)) / 7]
  
  # current smokers should have an amount smoked per day that is greater than zero
  data[cig_smoker_status == "current" & cigs_per_day == 0, cigs_per_day := NA]

  # Children 8-15 years
  if(country == "England"){
    
  data[cig_smoker_status == "current" & age < 16 & kcignum > 0, cigs_per_day := kcignum / 7]
  data[cig_smoker_status == "current" & age < 16 & kcignum == 0, cigs_per_day := 1 / 7]

  # I sometimes smoke, but I don't smoke every week
  data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 4, cigs_per_day := .25]

  # I smoke between one and six cigarettes a week
  data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 5, cigs_per_day := 3]

  # I smoke more than six cigarettes a week
  data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 6, cigs_per_day := 7]
  
  data[ , `:=` (kcigreg = NULL, kcignum = NULL, kcigweek = NULL, kcigregg = NULL)]
  
  # For missing, fill with average for each age, sex and IMD quintile
  data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = T)
  
  }
  
  # In SHeS, no smoking data for children
  if(country == "Scotland") {
    
    data[age < 16 , cigs_per_day := NA]
    
    # For missing, fill with average for each age, sex and IMD quintile, above 16
    data <- impute_mean(data, "cigs_per_day", remove_zeros = T)
  }
  


  # For non-smokers = 0
  data[cig_smoker_status %in% c("never", "former"), cigs_per_day := 0]

  remove_vars <- c("cigwday", "cigwend")
  data[ , (remove_vars) := NULL]


  
  
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


  ####################################################
  # Categorise cigarette preferences

  # Do this based on "cigtyp" - the main type of cigarette smoked
  # This variable is the only question on cigarette type that is asked consistently across years
  if(country == "England"){
  data[cig_smoker_status %in% c("never", "former"), cig_type := "non_smoker"]
  data[cig_smoker_status == "current" & cigtyp == 1, cig_type := "tipped"]
  data[cig_smoker_status == "current" & cigtyp == 2, cig_type := "plain_untipped"]
  data[cig_smoker_status == "current" & cigtyp == 3, cig_type := "rollups"]

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

