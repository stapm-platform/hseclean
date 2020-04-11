

#' Select variables and apply filters
#'
#' Selects the variables required for analysis and selects only the rows without missing data
#' for specified variables.
#'
#' @param data Data table - the Health Survey for England dataset.
#' @param ages Integer vector - the ages in single years to retain (defaults to 8 to 89 years).
#' @param years Integer vector - the years in single years to retain (defaults to 2001 to 2016).
#' @param keep_vars Character vector - the names of the variables to keep.
#' @param complete_vars Character vector - the names of the variables on which the selection of complete cases will be based.
#'
#' @return Returns a reduced version of data
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- select_data(data, keep_vars = c("age", "sex", "imd_quintile", "cig_smoker_status"))
#'
#' }
#'
select_data <- function(
  data,
  ages = 8:89,
  years = 2001:2017,
  keep_vars = c("age", "sex", "imd_quintile"),
  complete_vars = c("age", "sex", "imd_quintile")
) {

  keep_vars <- intersect(names(data), keep_vars)
  
  data <- data[ , ..keep_vars]

  for(cv in complete_vars) {

    data <- data[!is.na(get(cv))]

  }

  data <- data[age %in% ages & year %in% years]


return(data)
}


