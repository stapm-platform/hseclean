
#' Read HSE 2017
#'
#' Reads and does basic cleaning on the Health Survey for England 2017.
#'
#' The HSE 2017 sample comprised of a core general population sample. There was no boost sample in 2017.
#' 
#' The sample comprised 9,612 addresses selected at random in 534 postcode sectors, issued over twelve months from January to December 2017. Field work was completed in March 2018.
#'
#' Adults and children were interviewed at households identified at the selected addresses. Up to four children in each household were selected to take part at random; up to two aged 2 to 12 and up to two aged 13 to 15.
#'
#' A total of 7,997 adults aged 16 and over and 1,985 children aged 0-15 were interviewed, including 5,196 adults and 1,195 children who had a nurse visit.#'
#'
#' From 2015 HSE data contains the 2015 English index of multiple deprivation, divided into quintiles.
#'
#' @param root Character - the root directory.
#' @param file Character - the file path and name.
#' @importFrom data.table :=
#' @return Returns a data table. Note that:
#' \itemize{
#' \item Missing data ("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "N/A") is replaced with NA.
#' \item All variable names are converted to lower case.
#' \item The cluster and probabilistic sampling unit have the year appended to them.
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2017 <- read_2017("X:/", 
#' "ScHARR/PR_Consumption_TA/HSE/HSE 2017/UKDA-8334-tab/tab/hse2016_eul.tab")
#'
#' }
#'
read_2017 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2017/UKDA-8488-tab/tab/hse17i_eul_v1.tab"
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "N/A")
  )

  data.table::setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , c(50, 61, 749:801, 925:969, 1180:1203, 1535:1578)])
  smk_vars <- colnames(data[ , c(19, 20, 44, 55, 62, 727:748, 905:924, 1019:1043, 1204:1332, 1579:1592)])
  health_vars <- paste0("complst", 1:15)

  other_vars <- Hmisc::Cs(
    qrtint, addnum,
    psu, cluster, wt_int, #wt_sc,
    seriala,
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

  data.table::setnames(data,
           c("qrtint", "marstatd", "origin2", "activb2", "stwork","seriala", paste0("complst", 1:15)),
           c("quarter", "marstat", "ethnicity_raw", "activb", "paidwk","hse_id", paste0("compm", 1:15)))

  data[ , psu := paste0("2017_", psu)]
  data[ , cluster := paste0("2017_", cluster)]

  data[ , year := 2017]
  data[ , country := "England"]
  
return(data[])
}



