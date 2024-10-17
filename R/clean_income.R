
#' Income
#'
#' Process the data on income.
#'
#' There are a few different options for classifying income - the need to have a measure that is
#' consistent across years of the Health Survey for England has led us to use equivalised income quintiles only.
#' Past SAPM modelling has used years of the Health Survey for England for which a continuous variable for
#' equivalised income was provided. From this, we calculated our own income groups. In later years, this continuous
#' income variable is not available (except if we were to apply for a secure access version of the data).
#'
#' In the past a measure of in poverty / not in poverty has been used, where the poverty threshold is defined as
#' 60% of the median income for any year. For years in which we only have income quintiles available, it is not possible
#' to make an exact calculation of poverty. But it will coincide approximately with the lowest 2 income quintiles.
#'
#' It would also be possible from the Health Survey for England to classify people as being in receipt of benefits or not.
#' This is not done currently, and would have to have some thought on how to
#' deal with the changing definitions of benefits over time.
#'
#' @param data Data table - the Health Survey for England dataset.
#' @importFrom data.table :=
#' @return
#' \itemize{
#' \item income5cat: quintiles of equivalised household income.
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2004()
#' data <- clean_income(data = data)
#'
#' }
#'
clean_income <- function(
  data
) {

  country <- unique(data[ , country][1])

  if("eqv5" %in% colnames(data)) {

    data[eqv5 == 5, income5cat := "5_highest_income"]
    data[eqv5 == 4, income5cat := "4"]
    data[eqv5 == 3, income5cat := "3"]
    data[eqv5 == 2, income5cat := "2"]
    data[eqv5 == 1, income5cat := "1_lowest_income"]

    data[ , eqv5 := NULL]

  }


  if("eqvinc" %in% colnames(data) & !("eqv5" %in% colnames(data))) {

    setorderv(data, c("year", "eqvinc"), c(1, 1))

    data[!is.na(eqvinc), eqvinc_cum := cumsum(wt_int) / max(cumsum(wt_int), na.rm = T), by = "year"]

    data[eqvinc_cum >= .8, income5cat := "5_highest_income"]
    data[eqvinc_cum >= .6 & eqvinc_cum < .8, income5cat := "4"]
    data[eqvinc_cum >= .4 & eqvinc_cum < .6, income5cat := "3"]
    data[eqvinc_cum >= .2 & eqvinc_cum < .4, income5cat := "2"]
    data[eqvinc_cum < .2, income5cat := "1_lowest_income"]

    data[ , `:=`(eqvinc_cum = NULL, eqvinc = NULL)]

  }


  if("eqv5_15" %in% colnames(data)) {

    data[eqv5_15 == 1, income5cat := "5_highest_income"]
    data[eqv5_15 == 2, income5cat := "4"]
    data[eqv5_15 == 3, income5cat := "3"]
    data[eqv5_15 == 4, income5cat := "2"]
    data[eqv5_15 == 5, income5cat := "1_lowest_income"]

    data[ , eqv5_15 := NULL]

  }

  ####################################
  #### Income data for Wales

  if(country == "Wales"){

  if("incresp" %in% colnames(data)) {

    data[incresp == 5, income5cat := "5_highest_income"]
    data[incresp == 4, income5cat := "4"]
    data[incresp == 3, income5cat := "3"]
    data[incresp == 2, income5cat := "2"]
    data[incresp == 1, income5cat := "1_lowest_income"]

    data[ , incresp := NULL]

  } else {

    data[, income5cat := NA]
  }

  }


return(data[])
}



