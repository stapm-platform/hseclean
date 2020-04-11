

#' Read HSE 2011
#'
#' Reads and does basic cleaning on the Health Survey for England 2011.
#'
#' The HSE 2011 included a general population sample of adults and children, representative of
#' the whole population at both national and regional level. For the sample, 8,992 addresses
#' were randomly selected in 562 postcode sectors, issued over twelve months from January to
#' December 2011. Where an address was found to have multiple dwelling units, one dwelling
#' unit was selected at random and where there were multiple households at a dwelling unit, one
#' household was selected at random.
#'
#' In each selected household, all individuals were eligible for inclusion in the survey. Where
#' there were three or more children aged 0-15 in a household, two of the children were selected
#' at random. A nurse visit was arranged for all participants who consented.
#'
#' A total of 8,610 adults aged 16 and over and 2,007 children aged 0-15 were interviewed. A
#' household response rate of 66% was achieved for the core sample. Among the general
#' population sample, 5,715 adults and 1,257 children had a nurse visit.
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
#' 5.6 Drinking diary weight
#'
#' The drinking diary was given to all participants aged 18 and over who completed the main
#' HSE interview and had had an alcoholic drink in the previous 12 months. A drinking diary
#' weight has been generated for all adults eligible for the drinking diary. This weight
#' (wt_drink) should be used on all analysis of drinking diary questions.
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
#' data_2011 <- read_2011("X:/", "ScHARR/PR_Consumption_TA/HSE/HSE 2011/UKDA-7260-tab/tab/hse2011ai.tab")
#'
#' }
#'
read_2011 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2011/UKDA-7260-tab/tab/hse2011ai.tab"
) {

  ##################################################################################
  # General population

  data <- fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A")
  )

  setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 680:1796])
  smk_vars <- colnames(data[ , 2217:2361])
  health_vars <- paste0("compm", 1:14)

  other_vars <- Hmisc::Cs(
    mintb,
    PSU, Cluster, wt_int, wt_drink,
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

  data <- data[ , ..names]

  setnames(data, c("marstatc", "origin"), c("marstat", "ethnicity_raw"))

  data[ , psu := paste0("2011_", psu)]
  data[ , cluster := paste0("2011_", cluster)]

  data[ , year := 2011]
  data[ , country := "England"]

  data[ , quarter := c(1:4)[findInterval(mintb, c(1, 4, 7, 10))]]
  data[ , mintb := NULL]

return(data[])
}







