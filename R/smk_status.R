

#' Cigarette smoking status
#'
#' Categorise cigarette smoking into current, former and never regular cigarette smoker.
#'
#' Note that if some smokes either regularly or ocassionally, then they are classified as a current regular
#'  cigarette smoker. People who used to smoke regularly or ocassionally are classified as former smokers, but
#'  people who have only tried a cigarette once or twice are classified as never smokers.
#'
#'  This variable is created for adults aged >= 16 years, and children aged 8-15 years.
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return Returns two smoking variables:
#' \itemize{
#' \item cig_smoker_status - current, former, never
#' \item cig_ever - ever_smoker, never_smoker, based on current and former smokers from the variable above.
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2016 <- read_2016()
#'
#' data_2016 <- smk_status(data = data_2016)
#'
#' }
#'
#'
smk_status <- function(
  data
) {

  country <- unique(data[ , country][1])
  
  ######################################################################
  # Regular cigarette smoking status (age >= 16)

  ##
  # Never smokers (age >= 16)

  # If never smoked, or never smoked cigarettes
  data[smkevr == 2 | cigevr == 2, cig_smoker_status := "never"]

  # If have ever smoked, but only tried once or twice
  data[cigreg == 3, cig_smoker_status := "never"]

  ##
  # Former smokers (age >= 16)

  # If used to smoke regularly or occassionally
  data[cigreg %in% 1:2, cig_smoker_status := "former"]

  ##
  # Current smokers (age >= 16)

  # If currently smoke cigarettes
  data[cignow == 1, cig_smoker_status := "current"]


  ######################################################################
  # Regular cigarette smoking status (age 8-15)

  ##
  # Never smokers (age 8-15)
  if(country == "England"){
  # If never smoked cigarettes
  data[kcigevr == 2, cig_smoker_status := "never"]

  # If have ever smoked, but only tried once or twice
  data[kcigreg %in% 1:2, cig_smoker_status := "never"]

  ##
  # Former smokers (age 8-15)

  # If used to smoke regularly or occassionally
  data[kcigreg == 3, cig_smoker_status := "former"]

  ##
  # Current smokers (age 8-15)

  # If currently smoke cigarettes
  data[kcigreg %in% 4:6 | kcigweek == 1 | kcignum > 0, cig_smoker_status := "current"]


  # If less than age 8, assume never smoker
  data[age < 8, cig_smoker_status := "never"]
  
  data[ , kcigevr := NULL]
  }
  
  if(country == "Scotland"){
    data[age < 16, cig_smoker_status := NA_real_]
  }

  ######################################################################
  # Ever regular cigarette smoker

  data[cig_smoker_status %in% c("current", "former"), cig_ever := "ever_smoker"]
  data[cig_smoker_status == "never", cig_ever := "never_smoker"]


  # Remove variables no longer needed
  remove_vars <- c("smkevr", "cigevr", "cigreg", "cignow", colnames(data)[stringr::str_detect(colnames(data), "cigst")])
  data[ , (remove_vars) := NULL]


return(data)
}
