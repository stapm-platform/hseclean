
#' Summarise the percentages of people with certain levels of a variable
#'
#' Uses the 'survey' package to estimate the percentages with uncertainty that accounts for survey sampling
#' error and survey design.
#'
#' @param data Data table of individual characteristics.
#' @param var_name Character - the name of the variable to be summarised.
#' @param levels_1 Character vector - the levels that should be assigned 1 in the binary variable
#' @param levels_0 Character vector - the levels that should be assigned 0 in the binary variable
#' @param strat_vars Character vector - the variables by which to stratify the estimates
#' @importFrom data.table :=
#' @importFrom survey svymean
#' @return Returns the estimate and standard error.
#
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' prop_smokers <- prop_summary(
#'   data = data,
#'   var_name = "cig_smoker_status",
#'   levels_1 = "current",
#'   levels_0 = c("former", "never"),
#'   strat_vars = c("sex", "imd_quintile")
#' )
#'
#' }
#'
prop_summary <- function(
  data,
  var_name,
  levels_1,
  levels_0,
  strat_vars = NULL
) {

  data_p <- copy(data)

  # Create the variable to be summarised
  data_p[ , bin_var := NA_real_]
  data_p[get(var_name) %in% levels_1, bin_var := 1]
  data_p[get(var_name) %in% levels_0, bin_var := 0]

  data_p[ , cluster := as.factor(cluster)]

  # Lonely PSU (center any single-PSU strata around the sample grand mean rather than the stratum mean)
  options(survey.lonely.psu = "adjust")

  # Convert data to a survey object
  srv.int <- survey::svydesign(
    id =  ~ psu,
    strata =  ~ cluster,
    weights = ~ wt_int,
    nest = TRUE,
    data = data_p)

  if(!is.null(strat_vars)) {
    form <- paste("~ ", paste(strat_vars, collapse = " + "))
  } else {
    form <- 1
  }

  # Estimate the proportions
  prop_data <- survey::svyby(~ bin_var, by = formula(form), design = srv.int, svymean)

  rownames(prop_data) <- NULL

  data.table::setDT(prop_data)

  data.table::setnames(prop_data, "bin_var", var_name)

return(prop_data)
}
