

#' Whether someone drinks and frequency of drinking
#'
#' Clean the data on whether someone is a current drinker (drank in last 12 months)
#' and if they did drink how frequently they did so.
#'
#' Combines information from adults and children. Someone is classed as a drinker even if they only reported
#' drinking once or twice a year. Any missing data is
#' supplemented by responses to if currently drinks or if always non-drinker.
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return
#' \itemize{
#' \item drinks_now (drinker, non_drinker).
#' \item drink_freq_7d (numerical variable calculated from categorical responses to how frequently someone drinks)
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' data <- read_2017()
#' data <- clean_age(data)
#' data <- alc_drink_now_allages(data)
#' }
#'
alc_drink_now_allages <- function(
  data
) {

  # Categorise someone as a current drinker or not

  ###################################################################
  # Adults age >= 16 years

  # Frequency drank any alcoholic drink last 12 mths
  data[dnoft %in% 1:7, drinks_now := "drinker"]

  # Assign drink frequency
  data[dnoft %in% 1:8, drink_freq_7d := hseclean::alc_drink_freq(dnoft)]

  # Class not having drink in last 12 months as non-drinker
  data[dnoft == 8, drinks_now := "non_drinker"]

  # If missing, supplement with whether drink nowadays
  data[is.na(drinks_now) & dnnow == 1, drinks_now := "drinker"]
  data[is.na(drinks_now) & dnnow == 2, drinks_now := "non_drinker"]

  # If missing, supplement with whether drinks very occasionally or never drinks
  data[is.na(drinks_now) & dnany == 1, drinks_now := "drinker"]
  data[is.na(drinks_now) & dnany == 2, drinks_now := "non_drinker"]

  # If missing, supplement with whether always non-drinker
  data[is.na(drinks_now) & dnevr %in% 1:2, drinks_now := "non_drinker"]

  ###################################################################
  # Children age 8-15 years
  # No alcohol data for children in SHeS
  
  if("adrinkof" %in% colnames(data)){
    
  # How often alcoholic drink
  data[is.na(drinks_now) & adrinkof %in% 1:6, drinks_now := "drinker"]
  data[is.na(drinks_now) & adrinkof == 7, drinks_now := "non_drinker"]

  # Assign drink frequency
  data[is.na(drink_freq_7d) & adrinkof == 1, drink_freq_7d := 7]
  data[is.na(drink_freq_7d) & adrinkof == 2, drink_freq_7d := 2]
  data[is.na(drink_freq_7d) & adrinkof == 3, drink_freq_7d := 1]
  data[is.na(drink_freq_7d) & adrinkof == 4, drink_freq_7d := .5]
  data[is.na(drink_freq_7d) & adrinkof == 5, drink_freq_7d := .25]
  data[is.na(drink_freq_7d) & adrinkof == 6, drink_freq_7d := 3 / 52]

  # If missing, supplement with When last had alcoholic drink
  data[is.na(drinks_now) & adrlast %in% 1:6, drinks_now := "drinker"]

  # Class 6 months ago or more as non-drinker
  data[is.na(drinks_now) & adrlast == 7, drinks_now := "non_drinker"]
  }

  # If separate section for 8-12 years (just 2001)
  if("cdrinkof" %in% colnames(data)) {

    # How often alcoholic drink
    data[is.na(drinks_now) & cdrinkof %in% 1:6, drinks_now := "drinker"]
    data[is.na(drinks_now) & cdrinkof == 7, drinks_now := "non_drinker"]

    data[is.na(drink_freq_7d) & cdrinkof == 1, drink_freq_7d := 7]
    data[is.na(drink_freq_7d) & cdrinkof == 2, drink_freq_7d := 2]
    data[is.na(drink_freq_7d) & cdrinkof == 3, drink_freq_7d := 1]
    data[is.na(drink_freq_7d) & cdrinkof == 4, drink_freq_7d := .5]
    data[is.na(drink_freq_7d) & cdrinkof == 5, drink_freq_7d := .25]
    data[is.na(drink_freq_7d) & cdrinkof == 6, drink_freq_7d := 3 / 52]
    data[is.na(drink_freq_7d) & cdrinkof == -8, drink_freq_7d := NA]

    # If missing, supplement with When last had alcoholic drink
    data[is.na(drinks_now) & cdrlast %in% 1:6, drinks_now := "drinker"]

    # Class 6 months ago or more as non-drinker
    data[is.na(drinks_now) & cdrlast == 7, drinks_now := "non_drinker"]

    data[ , `:=`(cdrinkof = NULL, cdrlast = NULL)]

  }

  data[drinks_now == "non_drinker", drink_freq_7d := 0]

  ###################################################################
  # Remove variables no longer needed
  #remove_vars <- c("dnnow", "dnany", "dnevr", "adrinkof", "adrlast",
  #                 colnames(data)[stringr::str_detect(colnames(data), "dnoft")])
  #data[ , (remove_vars) := NULL]

return(data)
}

