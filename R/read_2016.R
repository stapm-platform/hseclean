
#' Read the Health Survey for England 2016
#'
#' Reads and does basic cleaning on the Health Survey for England 2016.
#'
#' @section Survey details:
#' The HSE 2016 sample comprised of a core general population sample. There was no boost sample in 2016.
#' The sample comprised 9,558 addresses selected at random in 531 postcode sectors,
#' issued over twelve months from January to December 2016.
#' Field work was completed in March 2017. Where an address was found to have multiple dwelling units,
#' one dwelling unit was selected at random. Where there were multiple households at a dwelling unit,
#' one household was selected at random.
#' Adults and children were interviewed at households identified at the selected addresses.
#' Up to four children in each household were selected to take part at random;
#' up to two aged 2 to 12 and up to two aged 13 to 15.
#' A nurse visit was arranged for all participants who consented;
#' this included measurements and the collection of blood and saliva samples,
#' as well as other questions. Height was measured for those aged two and over,
#' and weight for all participants. Nurses measured blood pressure (aged 5 and over)
#' and waist and hip circumference (aged 11 and over). Non-fasting blood samples and urine
#' samples were collected from adults aged 16 and over. Saliva samples for cotinine analysis
#' were collected from all participants aged 4 to 15.
#' Nurses obtained written consent before taking samples from adults,
#' and parents gave written consent for their children’s samples.
#' Consent was also obtained from adults to send results to their GPs,
#' and from parents to send their children’s results to their GPs.
#' A total of 8,011 adults aged 16 and over and 2,056 children aged 0-15 were interviewed,
#' including 5,049 adults and 1,117 children who had a nurse visit.
#' From 2015 HSE data contains the 2015 English index of multiple deprivation, divided into quintiles.
#'
#' @section Weighting:
#' For analyses at the individual level, the weighting variable to use is (wt_int). These weights are generated separately for adults and children:
#' \itemize{
#' \item for adults (aged 16 or more), the interview weights are a combination of the household weight and a component which adjusts the sample to reduce bias from individual non-response within households;
#' \item for children (aged 0 to 15), the weights are generated from the household weights and the child selection weights – the selection weights correct for only including a maximum of two children in a household. The combined household and child selection weight were adjusted to ensure that the weighted age/sex distribution matched that of all children in co-operating households.
#' }
#' For analysis of children aged 0-15 in both the Core and the Boost sample, taking into account child selection only and not adjusting for non-response, the (wt_child) variable can be used. For analysis of children aged 2-15 in the only Boost sample the (wt_childb) variable can
#'
#' @section Missing values:
#'
#' \itemize{
#' \item -1 Not applicable: Used to signify that a particular variable did not apply to a given respondent
#' usually because of internal routing. For example, men in women only questions.
#' \item -8 Don't know, Can't say.
#' \item -9 No answer/ Refused
#' }
#'
#' @template read-data-description
#'
#' @template read-data-args
#'
#' @importFrom data.table :=
#'
#' @return Returns a data table.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2016 <- read_2016("X:/",
#' "ScHARR/PR_Consumption_TA/HSE/HSE 2016/UKDA-8334-tab/tab/hse2016_eul.tab")
#'
#' }
#'
read_2016 <- function(
    root = c("X:/", "/Volumes/Shared/")[1],
    file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2016/UKDA-8334-tab/tab/hse2016_eul.tab",
    select_cols = c("tobalc", "all")[1]
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root, file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "N/A"))

  data.table::setnames(data, names(data), tolower(names(data)))

  if(select_cols == "tobalc") {

    alc_vars <- colnames(data[ , 1400:1625])
    smk_vars <- colnames(data[ , 1219:1398])
    health_vars <- paste0("complst", 1:15)

    other_vars <- Hmisc::Cs(
      qrtint, addnum,
      psu, cluster, wt_int, wt_sc,
      SerialA,
      age16g5, age35g, sex,
      origin2,
      qimd, nssec3, nssec8,
      stwork,
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

  }

  data.table::setnames(data,
                       c("qrtint", "marstatd", "origin2", "activb2", "stwork","seriala", paste0("complst", 1:15)),
                       c("quarter", "marstat", "ethnicity_raw", "activb", "paidwk","hse_id", paste0("compm", 1:15)))

  data[ , psu := paste0("2016_", psu)]
  data[ , cluster := paste0("2016_", cluster)]

  data[ , year := 2016]
  data[ , country := "England"]

  return(data[])
}



