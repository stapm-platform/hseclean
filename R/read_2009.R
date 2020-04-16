
#' Read HSE 2009
#'
#' Reads and does basic cleaning on the Health Survey for England 2009.
#'
#' The HSE 2009 included a general population sample of adults and children, representative of
#' the whole population at both national and regional level, and a boost sample of children aged
#' 2-15. A sub-sample was identified in which the main survey was supplemented with objective
#' measures of physical activity and fitness. For the general population sample, 4,680 addresses
#' were randomly selected in 360 postcode sectors, issued over twelve months from January to
#' December 2009. Where an address was found to have multiple dwelling units, one was
#' selected at random. Where there were multiple households at a dwelling unit, up to three
#' households were included, and if there were more than three, a random selection was made.
#' At each address, all households, and all persons in them, were eligible for inclusion in the
#' survey. Where there were three or more children aged 0-15 in a household, two of the children
#' were selected at random. A nurse visit was arranged for all participants who consented.
#'
#' In addition to the core general population sample, a boost sample of children aged 2-15 was
#' selected using 12,600 addresses, some in the same postcode sectors as the core sample and
#' some in an additional 180 postcode sectors to supplement the sample obtained in the core
#' sectors. As for the core sample, where there were three or more children in a household, two
#' of the children were selected at random to limit the respondent burden for parents. There was
#' no nurse follow up for this child boost sample.
#'
#' A total of 4,645 adults and 3,957 children were interviewed, with 1,147 children from the
#' core sample and 2,810 from the boost. A household response rate of 68% was achieved for
#' the core sample, and 74% for the boost sample. Among the general population sample,
#' 3,261 adults and 807 children had a nurse visit.
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
#' \item -2 Schedule not applicable: Used mainly for variables on the self-completions when the
#' respondent was not of the given age range, also used for children without legal guardians in the
#' home who could not participate in the nurse schedule.
#' \item -8 Don't know, Can't say.
#' \item -9 No answer/ Refused
#' }
#'
#' @param root Character - the root directory.
#' @param file Character - the file path and name.
#'
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
#' data_2009 <- read_2009("X:/", "ScHARR/PR_Consumption_TA/HSE/HSE 2009/UKDA-6732-tab/tab/hse09ai.tab")
#'
#' }
#'
read_2009 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2009/UKDA-6732-tab/tab/hse09ai.tab"
) {

  ##################################################################################
  # General population

  data <- fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A")
  )

  setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 396:471])
  smk_vars <- colnames(data[ , c(686:695, 921:1048)])
  health_vars <- paste0("compm", 1:14)

  other_vars <- Hmisc::Cs(
    mintb, addnum,
    psu, cluster, wt_int,
    age, sex,
    origin,
    IMD2007, econact, nssec3, nssec8,
    #econact2, #paidwk,
    activb, #HHInc,
    children, infants,
    educend, topqual3,
    eqv5, #eqvinc,

    marstatc, # marital status inc cohabitees

    # how much they weigh
    htval, wtval)

  names <- c(other_vars, alc_vars, smk_vars, health_vars)

  names <- tolower(names)

  data <- data[ , ..names]

  setnames(data, c("imd2007", "marstatc", "origin"), c("qimd", "marstat", "ethnicity_raw"))

  data[ , psu := paste0("2009_", psu)]
  data[ , cluster := paste0("2009_", cluster)]

  data[ , year := 2009]
  data[ , country := "England"]
  
  data[ , quarter := c(1:4)[findInterval(mintb, c(1, 4, 7, 10))]]
  data[ , mintb := NULL]

return(data[])
}




