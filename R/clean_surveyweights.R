

#' Process the survey weights
#'
#' @param data Data table - the Health Survey for England dataset
#'
#' @return Returns data with survey weights updated
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- clean_surveyweights(data)
#'
#' }
#'
clean_surveyweights <- function(
  data,
  pop_data = hseclean::pop_counts
) {

  # Fill any missing survey weights
  data[ , mean_wt_int := mean(wt_int, na.rm = T), by = "year"]
  data[is.na(mean_wt_int), mean_wt_int := 1]
  data[is.na(wt_int), wt_int := mean_wt_int]
  data[ , mean_wt_int := NULL]

  # Make survey weights sum to 1 within each year
  data[ , wt_int := wt_int / sum(wt_int, na.rm = T), by = "year"]

  # Adjust weights by population size
  #data <- merge(data, pop_data, by = c("year", "age", "sex", "imd_quintile"), all.x = T)
  #data[ , sample_n := .N, by = c("year", "age", "sex", "imd_quintile")]
  #data[ , wt_pop := sample_n / N]
  #data[ , wt_int := wt_pop * wt_int]
  #data[ , wt_int := wt_int / sum(wt_int, na.rm = T), by = "year"]

  #data[ , `:=`(sample_n = NULL, N = NULL, wt_pop = NULL)]

return(data)
}
