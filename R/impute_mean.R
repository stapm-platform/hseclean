


#' Fills missing values with subgroup mean value
#'
#' Replaces any values < 0 with NA, calculates the subgroup mean,
#' then replaces missing values with the subgroup mean.
#'
#' If not all NAs can be imputed with the fine scale starting amount of stratification,
#' imputation is attempted again, removing the stratification variable specified last.
#'
#' @param data Data table - the Health Survey for England data
#' @param var_names Character vector - the variable names to be imputed
#' @param remove_zeros Logical - should zeros be treated as missing data
#' @param strat_vars Character vector - the variables by which to stratify the subgroup means
#'
#' @return Returns an updated version of data in which the variables specified have had
#' their missing values imputed with the subgroup means.
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2001()
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- impute_mean(data, var_names = c("d7many"))
#'
#' }
#'
impute_mean <- function(
  data,
  var_names,
  remove_zeros = FALSE,
  strat_vars = c("year", "sex", "imd_quintile", "age_cat")
) {

  for(var_name in var_names) {

    # Replace all missing values with NA
    if(isTRUE(remove_zeros)) {

      data[get(var_name) <= 0, (var_name) := NA]

    } else {

      data[get(var_name) < 0, (var_name) := NA]

    }

    # Calculate the subroup means
    var_name_av <- paste0(var_name, "_av")

    check <- 1e8
    n_strat <- length(strat_vars)

    while(check > 0) {

      data[ , (var_name) := as.double(get(var_name))]

      data[ , (var_name_av) := mean(get(var_name), na.rm = T), by = c(strat_vars[1:n_strat])]

      # Replace missing with the subgroup mean
      data[is.na(get(var_name)) & !is.na(get(var_name_av)), (var_name) := get(var_name_av)]

      check <- nrow(data[is.na(get(var_name))])

      n_strat <- n_strat - 1

      if(check > 0 & n_strat == 0) {
        break
      }

    }

    # Remove the mean variable
    data[ , (var_name_av) := NULL]

  }


return(data)
}
