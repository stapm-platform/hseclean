

#' Impute missing values of average weekly alcohol consumption
#' 
#' Fills the missing values of average weekly consumption so that 
#' this variable corresponds to the data on whether an individual is a drinker.  
#'
#' For children 13-15 years old, the missing values in the average amount drunk in the last week are filled with the 
#' average value for each year (this average is not stratified). The average weekly alcohol consumption is then calculated 
#' by scaling the amount drunk in the last week by the frequency of drinking.   
#' 
#' For adults >= 16 years, missing values for the average weekly alcohol consumption are filled by the average, 
#' stratified by age category, year, sex, IMD quintile and the frequency of drinking.   
#'
#' @param data Data table - the Health Survey for England dataset.
#' @importFrom data.table :=
#' @return Returns a data table in which the missing values of average weekly consumption have been filled in so that 
#' this variable corresponds to the data on whether an individual is a drinker.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' 
#' library(hseclean)
#' library(data.table)
#' library(magrittr)
#' 
#' data <- read_2017(root = "/Volumes/Shared/")
#' 
#' data %<>%
#'   clean_age %>%
#'   clean_demographic %>% 
#'   clean_education %>%
#'   clean_economic_status %>%
#'   clean_family %>%
#'   clean_income %>%
#'   clean_health_and_bio %>%
#'   alc_drink_now_allages %>%
#'   alc_weekmean_adult %>%
#'   alc_sevenday_adult %>%
#'   alc_sevenday_child
#' 
#' data <- data[age >= 13, c("year", "age", "age_cat", "sex", "imd_quintile", "drinks_now", "drink_freq_7d", "total_units7_ch", "weekmean")]
#' 
#' data <- alc_impute(data)
#' 
#' }
#'
alc_impute <- function(
  data
) {

  # Fill any missing values for drinking frequency
  data <- hseclean::impute_mean(data, "drink_freq_7d", strat_vars = c("year", "sex", "imd_quintile", "age_cat", "drinks_now"))
  
  
  ## Children 13-15 years old
  
  # Calculate the average amount drunk by children who are drinkers over the last 7 days
  # removing zeros
  mean_7d_amount_ch <- mean(data[drinks_now == "drinker" & total_units7_ch > 0 & age >= 13 & age < 16, total_units7_ch], na.rm = T)
  
  # replace zero amounts for drinkers younger than 16 with the average value
  data[drinks_now == "drinker" & total_units7_ch == 0 & age >= 13 & age < 16, total_units7_ch := mean_7d_amount_ch]
  
  # calculate the amount drunk on an average week in a year using information on quantity and frequency
  data[drinks_now == "drinker" & age >= 13 & age < 16, weekmean := (drink_freq_7d * 52 / 7) * total_units7_ch]
  
  
  ## Adults >= 16 years old
  
  # Fill in the average amount drunk by adults who are drinkers
  
  # Make zeros NAs
  data[age >= 16 & drinks_now == "drinker" & weekmean == 0, weekmean := NA]
  
  # Fill the missing values
  data <- hseclean::impute_mean(data, var_names = "weekmean", strat_vars = c("year", "sex", "imd_quintile", "age_cat", "drink_freq_7d"), remove_zeros = FALSE)
  
  
return(data[])
}

