
#' Fills missing values of categorical variables with random draw from subgroup \lifecycle{maturing}
#'
#' Replaces missing (NA) values with a random draw from the subgroup - 
#' the frequency of non-missing values within the subgroup therefore determines the result.
#'
#' If not all NAs can be imputed with the fine scale starting amount of stratification,
#' imputation is attempted again, removing the stratification variable specified last.
#'
#' @param data Data table - the Health Survey for England data
#' @param var_names Character vector - the variable names to be imputed (categorical variables only)
#' @param strat_vars Character vector - the variables by which to stratify the sample to create subgroups
#' 
#' @importFrom data.table :=
#' 
#' @return Returns an updated version of data in which the variables specified have had
#' their missing values imputed with random draws from the subgroups.
#' 
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
#' data <- data[age >= 13, c("year", "age", "age_cat", "sex", "imd_quintile", "drinks_now", "drink_freq_7d", "total_units7_ch", "weekmean", "drinker_cat")]
#' 
#' data[is.na(drinks_now)]
#' 
#' data <- impute_cat(data, var_names = c("drinks_now"))
#'
#' data[is.na(drinks_now)]
#'
#' }
#'
impute_cat <- function(
  data,
  var_names,
  strat_vars = c("year", "sex", "imd_quintile", "age_cat")
) {
  
  for(var_name in var_names) {
    
    # var_name <- "drinks_now"
    
    var_name_samp <- paste0(var_name, "_samp")
    
    check <- 1e8
    n_strat <- length(strat_vars)
    
    while(check > 0) {
      
      data[ , (var_name) := as.character(get(var_name))]
      
      data[ , (var_name_samp) := sample(
        x = get(var_name)[!is.na(get(var_name))], 
        size = length(get(var_name)),
        replace = TRUE), 
        by = c(strat_vars[1:n_strat])]
      
      # Replace missing with the subgroup sampled values
      data[is.na(get(var_name)) & !is.na(get(var_name_samp)), (var_name) := get(var_name_samp)]
      
      check <- nrow(data[is.na(get(var_name))])
      
      n_strat <- n_strat - 1
      
      if(check > 0 & n_strat == 0) {
        break
      }
      
    }
    
    # Remove the mean variable
    data[ , (var_name_samp) := NULL]
    
  }
  
  
  return(data[])
}
