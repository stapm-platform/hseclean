

#' Whether someone drinks and frequency of drinking \lifecycle{maturing}
#'
#' Clean the data on whether someone is a current drinker (drank in last 12 months)
#' and if they did drink how frequently they did so. Several definitions are used for youth drinking (< 16 years).  
#'
#' Combines information from adults and children. In general, someone is classed as a drinker even if they only reported
#' drinking once or twice a year - which is a less strict definition than used by some other surveys. Any missing data is
#' supplemented by responses to if currently drinks or if always non-drinker.   
#' 
#' For youth drinking, variables are also created for: 
#' drinks at least once a week, drinks at least once a month, and drank in the last week.
#'
#' @param data Data table - the Health Survey for England dataset.
#' @importFrom data.table :=
#' @return
#' \describe{
#' \item{drinks_now}{Drank at all in the last 12 months (drinker, non_drinker).}      
#' \item{drink_freq_7d}{Frequency of drinking, expressed in terms of the expected number of drinking ocassions per week (numerical variable calculated from categorical responses to how frequently someone drinks).}       
#' \item{adrinkweek}{Youth drinks at least once a week (yes, no).}
#' \item{adrinkmonth}{Youth drinks at least once a month (yes, no).}   
#' \item{adrinklastweek}{Youth drank in the last week (yes, no).}      
#' }
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
    
    # Assign drink frequency
    data[adrinkof == 1, drink_freq_7d := 7]
    data[adrinkof == 2, drink_freq_7d := 2]
    data[adrinkof == 3, drink_freq_7d := 1]
    data[adrinkof == 4, drink_freq_7d := .5]
    data[adrinkof == 5, drink_freq_7d := .25]
    data[adrinkof == 6, drink_freq_7d := 3 / 52]  
    
    ######
    # Create drinks in the last 12 months variable
    data[adrinkof %in% 1:6, drinks_now := "drinker"]
    data[adrinkof == 7, drinks_now := "non_drinker"]
    
    # If missing, supplement with When last had alcoholic drink
    data[!(adrinkof %in% 1:7) & adrlast %in% 1:6, drinks_now := "drinker"]
    
    # Class 6 months ago or more as non-drinker
    data[!(adrinkof %in% 1:7) & adrlast == 7, drinks_now := "non_drinker"]
    
    ######
    # Create extra youth variables
    
    # Drinks at least once a week
    data[adrinkof %in% 1:3, adrinkweek := "yes"]
    data[adrinkof %in% 4:7, adrinkweek := "no"]
    
    # Drinks at least once a month
    data[adrinkof %in% 1:5, adrinkmonth := "yes"]
    data[adrinkof %in% 6:7, adrinkmonth := "no"]
    
    # Drank in the last week
    data[adrlast %in% 1:3, adrinklastweek := "yes"]
    data[adrlast %in% 4:7, adrinklastweek := "no"]
    
  }

  # If separate section for 8-12 years (just 2001)
  if("cdrinkof" %in% colnames(data)) {

    # Assign drinking frequency
    data[cdrinkof == 1, drink_freq_7d := 7]
    data[cdrinkof == 2, drink_freq_7d := 2]
    data[cdrinkof == 3, drink_freq_7d := 1]
    data[cdrinkof == 4, drink_freq_7d := .5]
    data[cdrinkof == 5, drink_freq_7d := .25]
    data[cdrinkof == 6, drink_freq_7d := 3 / 52]
    data[cdrinkof == -8, drink_freq_7d := NA]
    
    ######
    # Create drinks in the last 12 months variable
    data[cdrinkof %in% 1:6, drinks_now := "drinker"]
    data[cdrinkof == 7, drinks_now := "non_drinker"]

    # If missing, supplement with When last had alcoholic drink
    data[!(cdrinkof %in% 1:7) & cdrlast %in% 1:6, drinks_now := "drinker"]

    # Class 6 months ago or more as non-drinker
    data[!(cdrinkof %in% 1:7) & cdrlast == 7, drinks_now := "non_drinker"]

    ######
    # Create extra youth variables
    
    # Drinks at least once a week
    data[cdrinkof %in% 1:3, adrinkweek := "yes"]
    data[cdrinkof %in% 4:7, adrinkweek := "no"]
    
    # Drinks at least once a month
    data[cdrinkof %in% 1:5, adrinkmonth := "yes"]
    data[cdrinkof %in% 6:7, adrinkmonth := "no"]
    
    # Drank in the last week
    data[cdrlast %in% 1:3, adrinklastweek := "yes"]
    data[cdrlast %in% 4:7, adrinklastweek := "no"]
    
    data[ , `:=`(cdrinkof = NULL, cdrlast = NULL)]

  }

  data[drinks_now == "non_drinker", drink_freq_7d := 0]

  ###################################################################
  # Remove variables no longer needed
  #remove_vars <- c("dnnow", "dnany", "dnevr", "adrinkof", "adrlast",
  #                 colnames(data)[stringr::str_detect(colnames(data), "dnoft")])
  #data[ , (remove_vars) := NULL]

return(data[])
}

