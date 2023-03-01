

#' Process the survey weights
#'
#' Makes new survey weights based on the difference between the HSE sample size and the actual population size
#' by year, age, sex and IMD quintiles.
#'
#' Survey weights are calculated after the survey data has been collected, so that when the weights are
#' applied they make the survey sample representative of the general population by age and sex
#' i.e., if a particular subgroup has been under-sampled, then it receives a higher survey weight.
#' The definition and structure of the survey weights is described in the dataset documentation
#' and a description of the survey weights has been added to the help files of the function that read the survey data.
#' There are different weights for children and adults.
#' The children weights adjusts for the selection of just two children per household and
#' adjusts for differences between responding and non-responding households.
#'
#' Any processing or combining of survey weights is done in the functions that read each year of data.
#' The function `hseclean::clean_surveyweights()` brings in external data on the distribution of the
#' number of people in the population by age, sex and Index of Multiple Deprivation quintile
#' and makes a further adjustment so that the weights reflect the observed poopulation distribution
#' by those subgroups. The weights are then standardised by dividing by the mean weight within each year.
#' The resulting survey weight variable for each year is `wt_int`
#' (reflecting that the main survey weight used corresponds to the main respondent interviews).
#'
#' @param data Data table - the Health Survey for England dataset
#' @param pop_data Data table - population counts
#' @importFrom data.table :=
#' @return Returns data with survey weights updated
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- clean_surveyweights(data, pop_data = stapmr::pop_counts)
#'
#' }
#'
clean_surveyweights <- function(
  data,
  pop_data
) {

  # Fill any missing survey weights
  #data[ , mean_wt_int := mean(wt_int, na.rm = T), by = "year"]
  #data[is.na(mean_wt_int), mean_wt_int := 1]
  #data[is.na(wt_int), wt_int := mean_wt_int]
  #data[ , mean_wt_int := NULL]

  # Make survey weights sum to 1 within each year
  #data[ , wt_int := wt_int / sum(wt_int, na.rm = T), by = "year"]

  # Adjust weights by population size
  data <- merge(data, pop_data, by = c("year", "age", "sex", "imd_quintile"), all.x = T)
  data[ , sample_n := .N, by = c("year", "age", "sex", "imd_quintile")]
  data[ , wt_int := N / sample_n]

  # Standardise weights by dividing by the mean weight in each year
  data[ , wt_int := wt_int / mean(wt_int, na.rm = T), by = "year"]

  # remove variables not needed
  data[ , `:=`(sample_n = NULL, N = NULL)]


return(data[])
}
