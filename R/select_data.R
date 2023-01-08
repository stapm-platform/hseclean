

#' Select variables and apply filters
#'
#' Selects the variables required for analysis and selects only the rows without missing data
#' for specified variables.
#'
#' @param data Data table - the Health Survey for England dataset.
#' @param ages Integer vector - the ages in single years to retain (defaults to 8 to 89 years).
#' @param years Integer vector - the years in single years to retain.
#' @param keep_vars Character vector - the names of the variables to keep.
#' @param complete_vars Character vector - the names of the variables on which the selection of complete cases will be based.
#' @importFrom data.table :=
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
  years = 2001:2018,
  keep_vars = c("age", "sex", "imd_quintile"),
  complete_vars = c("age", "sex", "imd_quintile")
) {

  keep_vars <- intersect(colnames(data), keep_vars)

  if(!("age" %in% keep_vars)) {
    warning("age not in keep_vars - put it in")
  }

  if(!("year" %in% keep_vars)) {
    warning("year not in keep_vars - put it in")
  }

  data <- data[ , keep_vars, with = F]

  for(cv in complete_vars) {

    print(cv)

    if(cv %in% colnames(data)) {

      data <- data[!is.na(get(cv))]

    } else {

      warning(cv, " not a column in the data")

    }

  }

  data <- data[age %in% ages & year %in% years]


  return(data[])
}


