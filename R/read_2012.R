

#' Read HSE 2012
#'
#' Reads and does basic cleaning on the Health Survey for England 2012.
#'
#' The HSE 2012 included a general population sample of adults and children, representative of
#' the whole population at both national and regional level. For the sample, 9,024 addresses
#' were randomly selected in 564 postcode sectors, issued over twelve months from January to
#' December 2013. Where an address was found to have multiple dwelling units, one dwelling
#' unit was selected at random and where there were multiple households at a dwelling unit, one
#' household was selected at random.
#'
#' A total of 8,291 adults aged 16 and over and 2,043 children aged 0-15 were interviewed. A
#' household response rate of 64% was achieved for the core sample. Among the general
#' population sample, 5,470 adults and 1,203 children had a nurse visit.
#'
#' WEIGHTING
#'
#' 5.2 Individual weight
#'
#' For analyses at the individual level, the weighting variable to use is (wt_int). These weights are generated separately for adults and children:
#' \itemize{
#' \item for adults (aged 16 or more), the interview weights are a combination of the householdweight and a component which adjusts the sample to reduce bias from individual non-response within households;
#' \item for children (aged 0 to 15), the weights are generated from the household weights and the child selection weights – the selection weights correct for only including a maximum of two children in a household. The combined household and child selection weight were adjusted to ensure that the weighted age/sex distribution matched that of all children in co-operating households.
#' }
#' For analysis of children aged 0-15 in both the Core and the Boost sample, taking into account child selection only and not adjusting for non-response, the (wt_child) variable can be used. For analysis of children aged 2-15 in the only Boost sample the (wt_childb) variable can
#'
#' MISSING VALUES
#'
#' \itemize{
#' \item -1 Not applicable: Used to signify that a particular variable did not apply to a given respondent
#' usually because of internal routing. For example, men in women only questions.
#' \item -8 Don't know, Can't say.
#' \item -9 No answer/ Refused
#' }
#'
#' @param root Character - the root directory.
#' @param file Character - the file path and name.
#' @importFrom data.table :=
#' @return Returns a data table. Note that:
#' \itemize{
#' \item Missing data ("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A") is replace with NA,
#' except -8 ("don't know") as this is data.
#' \item All variable names are converted to lower case.
#' \item The cluster and probabilistic sampling unit have the year appended to them.
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2012 <- read_2012("X:/", 
#' "ScHARR/PR_Consumption_TA/HSE/HSE 2012/UKDA-7480-tab/tab/hse2012ai.tab")
#'
#' }
#'
read_2012 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2012/UKDA-7480-tab/tab/hse2012ai.tab"
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A")
  )

  data.table::setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 502:652])
  smk_vars <- colnames(data[ , 2117:2254])
  health_vars <- paste0("complst", 1:15)

  other_vars <- Hmisc::Cs(
    mintb, addnum,
    PSU, Cluster, wt_int, #wt_sc,
    Age, Sex,
    Origin,
    qimd, econact, nssec3, nssec8,
    #econact2,
    Paidwk,
    activb, #HHInc,
    Children, Infants,
    EducEnd, topqual3,
    eqv5, #eqvinc,

    marstatc, # marital status inc cohabitees

    # how much they weigh
    htval, wtval)

  names <- c(other_vars, alc_vars, smk_vars, health_vars)

  names <- tolower(names)

  data <- data[ , names, with = F]

  data.table::setnames(data, c("marstatc", "origin", paste0("complst", 1:15)), c("marstat", "ethnicity_raw", paste0("compm", 1:15)))

  data[ , psu := paste0("2012_", psu)]
  data[ , cluster := paste0("2012_", cluster)]

  data[ , year := 2012]
  data[ , country := "England"]
  
  data[ , quarter := c(1:4)[findInterval(mintb, c(1, 4, 7, 10))]]
  data[ , mintb := NULL]

return(data[])
}



