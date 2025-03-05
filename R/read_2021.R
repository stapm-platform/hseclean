
#' Read the Health Survey for England 2019 \lifecycle{maturing}
#'
#' Reads and does basic cleaning on the Health Survey for England 2019.
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
#' data_2019 <- read_2019("X:/",
#' "ScHARR/PR_Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2019/hse_2019_eul_20211006.tab")
#'
#' }
#'
read_2019 <- function(
    root = c("X:/", "/Volumes/Shared/")[1],
    file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2021/UKDA-9319-tab/tab/hse_2021_eul_v1.tab",
    select_cols = c("tobalc", "all")[1]
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root, file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A"))

  data.table::setnames(data, names(data), tolower(names(data)))

  if(select_cols == "tobalc") {

    # Do a scan of the data dictionary to get the column numbers of all drinking variables
    alc_vars <- colnames(data[ , c(120, 125, 1354:1495)]) # done 2019

    # Do a scan of the data dictionary to get the column numbers of all smoking variables
    smk_vars <- colnames(data[ , c(119, 124, 1158:1353)]) # needs review from here

    # health variables do not appear to be present in the 2019 survey
    #health_vars <- paste0("complst", 1:15)

    other_vars <- Hmisc::Cs(
      qrtint, #addnum,
      psu_scr, cluster214, #cluster194, ### no cluster194
      wt_int, #wt_sc,
      seriala,
      age16g5, age35g, sex,
      origin2,
      qimd19, #nssec3, nssec8,
      stwork,
      activb2,
      #Ag015g4, #Children, Infants,
      educend, topqual3,
      eqv5, #eqvinc,

      marstatd, # marital status inc cohabitees

      # # how much they weigh
      # htval, wtval
      htsr, height_adj, # estimated height given in cm, self-reported height adjusted (cm)
      wtsr, weight_adj  # estimated weight given in kg, self-reported weight adjusted (cm)

      )

    names <- c(other_vars, alc_vars, smk_vars)

    names <- tolower(names)

    data <- data[ , names, with = F]

  }

  # remove "_19" suffixes
  data.table::setnames(data, names(data), stringr::str_remove_all(names(data), "_19"))

  # relabel
  data.table::setnames(data,
                       c("cluster214", "psu_scr", "qrtint", "marstatd", "origin2", "activb2", "stwork","seriala", "qimd19", "startsmk19"),
                       c("cluster", "psu", "quarter", "marstat", "ethnicity_raw", "activb", "paidwk","hse_id", "qimd", "startsmk"))

  data[ , psu := paste0("2021_", psu)]
  data[ , cluster := paste0("2021_", cluster)]

  data[ , year := 2021]
  data[ , country := "England"]

  return(data[])
}



