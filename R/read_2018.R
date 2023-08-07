
#' Read the Health Survey for England 2018
#'
#' Reads and does basic cleaning on the Health Survey for England 2018.
#'
#' @template read-data-description
#'
#' @template read-data-args
#'
#' @importFrom data.table :=
#' @return Returns a data table.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#'
#' }
#'
read_2018 <- function(
    root = c("X:/", "/Volumes/Shared/")[1],
    file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2018/tab/hse_2018_eul_22052020.tab",
    select_cols = c("tobalc", "all")[1]
) {

  ##################################################################################
  # General population

  data <- data.table::fread(
    paste0(root, file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A"))

  data.table::setnames(data, names(data), tolower(names(data)))

  if(select_cols == "tobalc") {

    alc_vars <- colnames(data[ , c(55:58, 70:73, 805:925, 1097:1141)])
    smk_vars <- colnames(data[ , c(24, 25, 49, 64, 75, 76, 655:804, 1057:1096)])
    health_vars <- paste0("complst", 1:15)
    eq5d_vars <- Hmisc::Cs(Mobil17, SelfCa17, UsualA17, Pain17, Anxiet17,
                           Mobil17g3, SelfCa17g3, UsualA17g3, Pain17g3, Anxiet17g3)

    other_vars <- Hmisc::Cs(
      qrtint, #addnum,
      psu_scr, cluster195, wt_int, #wt_sc,
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

    names <- c(other_vars, alc_vars, smk_vars, health_vars, eq5d_vars)

    names <- tolower(names)

    data <- data[ , names, with = F]

  }

  data.table::setnames(data,
                       c("cluster195", "psu_scr", "qrtint", "marstatd", "origin2", "activb2", "stwork","seriala", paste0("complst", 1:15)),
                       c("cluster", "psu", "quarter", "marstat", "ethnicity_raw", "activb", "paidwk","hse_id", paste0("compm", 1:15)))

  data.table::setnames(data,
                       c("mobil17", "selfca17", "usuala17", "pain17", "anxiet17",
                         "mobil17g3", "selfca17g3", "usuala17g3", "pain17g3", "anxiet17g3"),
                       c("MO_5l", "SC_5l", "UA_5l", "PA_5l", "AD_5l",
                         "MO_3l", "SC_3l", "UA_3l", "PA_3l", "AD_3l") )

  data[ , psu := paste0("2018_", psu)]
  data[ , cluster := paste0("2018_", cluster)]

  data[ , year := 2018]
  data[ , country := "England"]

  return(data[])
}



