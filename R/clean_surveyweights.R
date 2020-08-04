

#' Process the survey weights
#' 
#' Makes new survey weights based on the difference between the HSE sample size and the actual population size 
#' by year, age, sex and IMD quintiles.   
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
  data[ , wt_int := wt_int / mean(wt_int, na.rm = T), by = "year"]

  data[ , `:=`(sample_n = NULL, N = NULL)]
  

return(data[])
}
