#' Read the Health Survey for England 2022 \lifecycle{maturing}
#'
#' Reads and does basic cleaning on the Health Survey for England 2022.
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
#' \dontrun{
#'
#' }
#'
read_2022 <- function(
  root = c("X:/", "/Volumes/Shared/")[1],
  file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab",
  select_cols = c("tobalc", "all")[1]
) {
  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root, file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A")
  )

  data.table::setnames(data, names(data), tolower(names(data)))

  if (select_cols == "tobalc") {
    # Do a scan of the data dictionary to get the column numbers of all drinking variables
    alc_vars <- colnames(data[, c(125, 894:1084, 1173:1278, 1313:1328, 1840, 1841, 1842, 1845, 1846, 1847, 1867)]) # updated for 2022

    # Do a scan of the data dictionary to get the column numbers of all smoking variables
    smk_vars <- colnames(data[, c(124, 696:893, 1279:1312, 1543:1568, 1723:1731, 1838, 1839, 1844, 1868, 1869)]) # updated for 2022

    # health variables do not appear to be present in the 2022 survey
    # health_vars <- paste0("complst", 1:15)

    other_vars <- Hmisc::Cs(
      qrtint, # addnum,
      psu_scr, cluster302, # cluster214 in 2021, cluster302 in 2022
      wt_int, # wt_sc,
      seriala,
      age16g5, age35g, sex,
      origin2,
      qimd19, # nssec3, nssec8,
      stwork,
      activb2,
      # Ag015g4, #Children, Infants,
      educend, topqual3,
      eqv5, # eqvinc,

      marstatd_22, # marital status inc cohabitees

      # # how much they weigh
      # htval, wtval
      htsr, height_adj, # estimated height given in cm, self-reported height adjusted (cm)
      wtsr, weight_adj # estimated weight given in kg, self-reported weight adjusted (cm)
    )

    names <- c(other_vars, alc_vars, smk_vars)

    names <- tolower(names)

    data <- data[, names, with = F]
  }

  # remove "_22" and "_19" suffixes
  data.table::setnames(data, names(data), stringr::str_remove_all(names(data), "_22"))
  data.table::setnames(data, names(data), stringr::str_remove_all(names(data), "_19"))

  # relabel
  data.table::setnames(
    data,
    c("cluster302", "psu_scr", "qrtint", "marstatd", "origin2", "activb2", "stwork", "seriala", "qimd19", "startsmk19"),
    c("cluster", "psu", "quarter", "marstat", "ethnicity_raw", "activb", "paidwk", "hse_id", "qimd", "startsmk")
  )

  data[, psu := paste0("2022_", psu)]
  data[, cluster := paste0("2022_", cluster)]

  data[, year := 2022]
  data[, country := "England"]

  return(data[])
}
