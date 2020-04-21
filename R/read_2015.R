

#' Read HSE 2015
#'
#' Reads and does basic cleaning on the Health Survey for England 2015.
#'
#' The HSE 2015 sample comprised of two main components: the core general population sample and a boost sample of children aged 2 to 15.
#'
#' Core sample
#'
#' The core sample was designed to be representative of the population living in private households in England. 8,832 addresses were randomly selected in 552 postcode sectors, issued over twelve months from January to December 2015. An additional 540 addresses in 27 postcode sectors were issued in January 2016, meaning that in total 9,372 addresses were issued for the core sample. Fieldwork was completed in April 2016. Where an address was found to have multiple dwelling units, one dwelling unit was selected at random. Where there were multiple households at a dwelling unit, one household was selected at random.
#'
#' Adults and children were interviewed at households identified at the selected addresses. Up to four children in each household were selected to take part at random; up to two aged 2 to 12 and up to two aged 13 to 15.
#'
#' A nurse visit was arranged for all participants who consented; this included measurements and the collection of blood and saliva samples, as well as other questions. Height was measured for those aged two and over, and weight for all participants. Nurses measured blood pressure (aged 5 and over) and waist and hip circumference (aged 11 and over). Non-fasting blood samples (for the analysis of total and HDL cholesterol and glycated haemoglobin) and urine samples were collected from adults aged 16 and over. Saliva samples for cotinine analysis were collected from all participants aged 4 and over. Nurses obtained written consent before taking samples from adults, and parents gave written consent for their children’s samples. Consent was also obtained from adults to send results to their GPs, and from parents to send their children’s results to their GPs.
#'
#' A total of 8,034 adults aged 16 and over and 2,123 children aged 0-15 were interviewed, including 5,378 adults and 1,297 children who had a nurse visit.
#'
#' Boost sample
#'
#' In 2015, the child boost sample comprised of 17,252 addresses which were drawn from the same PSUs as the core fieldwork. Households were screened for the presence of children aged 2 to 15. Only children were interviewed in these households, and like the core sample, up to four children in selected households could be interviewed: up to two children aged 2 to 12, and up to two aged 13 to 15. Children in the boost sample were not eligible for a nurse visit. 3,631 households were identified as containing at least one eligible child and a total of 3,591 children were interviewed in the child boost sample.
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
#' data_2015 <- read_2015("X:/", 
#' "ScHARR/PR_Consumption_TA/HSE/HSE 2015/UKDA-8280-tab/tab/hse2015ai.tab")
#'
#' }
#'
read_2015 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2015/UKDA-8280-tab/tab/hse2015ai.tab"
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A")
  )

  data.table::setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 1542:1708])
  smk_vars <- colnames(data[ , 1302:1540])
  health_vars <- paste0("complst", 1:15)

  other_vars <- Hmisc::Cs(
    qrtint, addnum,
    psu, cluster_adults, wt_int, wt_sc, #wt_hhldch,
    age16g5, age35g, sex,
    origin2,
    qimd, nssec3, nssec8,
    paidwk,
    activb2,
    #Ag015g4, #Children, Infants,
    educend, topqual3,
    eqv5, #eqvinc,

    marstatd, # marital status inc cohabitees

    # how much they weigh
    htval, wtval)

  names <- c(other_vars, alc_vars, smk_vars, health_vars)

  names <- tolower(names)

  data <- data[ , names, with = F]

  data.table::setnames(data,
           c("qrtint", "cluster_adults", "marstatd", "origin2", "activb2", paste0("complst", 1:15)),
           c("quarter", "cluster", "marstat", "ethnicity_raw", "activb", paste0("compm", 1:15)))

  data[ , psu := paste0("2015_", psu)]
  data[ , cluster := paste0("2015_", cluster)]

  data[ , year := 2015]
  data[ , country := "England"]
  
return(data[])
}


