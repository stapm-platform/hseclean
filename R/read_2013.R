
#' Read HSE 2013
#'
#' Reads and does basic cleaning on the Health Survey for England 2013.
#'
#' The HSE 2013 included a general population sample of adults and children, representative of the whole population at both national and regional level. For the sample, 9,408 addresses were randomly selected in 588 postcode sectors, issued over twelve months from January to December 2013. Where an address was found to have multiple dwelling units, one dwelling unit was selected at random and where there were multiple households at a dwelling unit, one household was selected at random.
#'
#' In each selected household, all individuals were eligible for inclusion in the survey. Where there were three or more children aged 0-15 in a household, two of the children were selected at random. A nurse visit was arranged for all participants who consented.
#'
#' A total of 8,795 adults aged 16 and over and 2,185 children aged 0-15 were interviewed. A household response rate of 64% was achieved. Of those where a full interview was achieved, 6,183 adults and 1,455 children also had a nurse visit.
#'
#' Height was measured for those aged two and over and weight for all participants. Nurses measured blood pressure (aged 5 and over) and waist and hip circumference (aged 11 and over). Non-fasting blood samples (for the analysis of total and HDL cholesterol and glycated haemoglobin) were collected from adults aged 16 and over. Saliva samples for cotinine analysis were collected from all participants aged 4 and over. Nurses obtained written consent before taking samples from adults, and parents gave written consent for their children’s samples. Consent was also obtained from adults to send results to their GPs, and from parents to send their children’s results to their GPs.
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
#' data_2013 <- read_2013("X:/", 
#' "ScHARR/PR_Consumption_TA/HSE/HSE 2013/UKDA-7649-tab/tab/hse2013ai.tab")
#'
#' }
#'
read_2013 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2013/UKDA-7649-tab/tab/hse2013ai.tab"
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A")
  )

  data.table::setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 677:836])
  smk_vars <- colnames(data[ , 1335:1578])
  health_vars <- paste0("complst", 1:15)

  other_vars <- Hmisc::Cs(
    mintb, addnum,
    PSU, Cluster, wt_int,
    Age, Sex,
    Origin,
    qimd, econact, nssec3, nssec8,
    #econact2,
    Paidwk,
    Activb, #HHInc,
    Children, Infants,
    EducEnd, topqual3,
    eqv5, #eqvinc,

    marstatd, # marital status inc cohabitees

    # how much they weigh
    Htval, Wtval)

  names <- c(other_vars, alc_vars, smk_vars, health_vars)

  names <- tolower(names)

  data <- data[ , names, with = F]

  data.table::setnames(data, c("longend2", "marstatd", "origin", paste0("complst", 1:15)), c("longend", "marstat", "ethnicity_raw", paste0("compm", 1:15)))

  data[ , psu := paste0("2013_", psu)]
  data[ , cluster := paste0("2013_", cluster)]

  data[ , year := 2013]
  data[ , country := "England"]
  
  data[ , quarter := c(1:4)[findInterval(mintb, c(1, 4, 7, 10))]]
  data[ , mintb := NULL]

return(data[])
}



