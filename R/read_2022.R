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
      htval, wtval
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
    c(
      "cluster302", "psu_scr", "qrtint", "marstatd", "origin2", "activb2", "stwork", "seriala", "qimd19", "startsmk19",
      "moth_totalwug2", "fath_totalwug2",
      "drktyp221", "drktyp222", "drktyp223", "drktyp224", "drktyp225", "drktyp226", "drktyp227", "drktyp228", "drktyp229", "drktyp2210",
      "nbrl7221", "nbrl7222", "nbrl7223", "nbrl7224", "nberpt7", "nbersm7", "nberlg7", "nberbt7", "l7nber",
      "sbrl7221", "sbrl7222", "sbrl7223", "sbrl7224", "sberpt7", "sbersm7", "sberlg7", "sberbt7", "l7ber",
      "ncidl7221", "ncidl7222", "ncidl7223", "ncidl7224", "ncidpt7", "ncidsm7", "ncidlg7", "ncidbt7", "l7ncid",
      "scidl7221", "scidl7222", "scidl7223", "scidl7224", "scidpt7", "scidsm7", "scidlg7", "scidbt7", "l7scid",
      "winel7191", "winel7192", "wgl250ml", "wgl175ml", "wgl125ml",
      "nbeer22", "nbeerm221", "nbeerm222", "nbeerm223", "nbeerm224", "nbeerq22a", "nbeerq22b", "nbeerq22c", "nbeerq22d",
      "sbeer22", "sbeerm221", "sbeerm222", "sbeerm223", "sbeerm224", "sbeerq22a", "sbeerq22b", "sbeerq22c", "sbeerq22d",
      "ncider22", "ncidm221", "ncidm222", "ncidm223", "ncidm224", "ncid22a", "ncid22b", "ncid22c", "ncid22d",
      "scider22", "scidm221", "scidm222", "scidm223", "scidm224", "scid22a", "scid22b", "scid22c", "scid22d",
      "wdrink7b", "mdrink7b", "alclimit7b", "totalwug2", "totalwug5", "alcbsmt", "menwug", "womwug2", "menwug2",
      "cnbeer22", "cnbeerm221", "cnbeerm222", "cnbeerm223", "cnbeerm224", "cnbeerm2298", "cnbeerq22a", "cnbeerq22b", "cnbeerq22c", "cnbeerq22d",
      "csbeer22", "csbeerm221", "csbeerm222", "csbeerm223", "csbeerm224", "csbeerm2298", "csbeerq22a", "csbeerq22b", "csbeerq22c", "csbeerq22d",
      "cncider22", "cncidm221", "cncidm222", "cncidm223", "cncidm224", "cncidm2298", "cncid22a", "cncid22b", "cncid22c", "cncid22d",
      "cscider22", "cscidm221", "cscidm222", "cscidm223", "cscidm224", "cscidm2298", "cscid22a", "cscid22b", "cscid22c", "cscid22d",
      "cspirits", "cspiritsq", "csherry", "csherryq", "cwine", "cwineq1", "cwineq2", "cbwineq19",
      "cpops", "cpopsq111", "cpopsq112", "cpopsq113"
    ),
    c(
      "cluster", "psu", "quarter", "marstat", "ethnicity_raw", "activb", "paidwk", "hse_id", "qimd", "startsmk",
      "moth_totalwug215", "fath_totalwug215",
      "d7typ1", "d7typ2", "d7typ3", "d7typ4", "d7typ5", "d7typ6", "d7typ7", "d7typ8", "d7typ9", "d7typ10",
      "nbrl71", "nbrl72", "nbrl73", "nbrL74", "nberqhp7", "nberqsm7", "nberqlg7", "nberqbt7", "l7ncodeq",
      "sbrl71", "sbrl72", "sbrl73", "sbrL74", "sberqhp7", "sberqsm7", "sberqlg7", "sberqbt7", "l7scodeq",
      "ncidl71", "ncidl72", "ncidl73", "ncidl74", "ncidpt7", "ncidsm7", "ncidlg7", "ncidbt7", "l7ncid",
      "scidl71", "scidl72", "scidl73", "scidl74", "scidpt7", "scidsm7", "scidlg7", "scidbt7", "l7scid",
      "winel71", "winel72", "wgls250ml", "wgls175ml", "wgls125ml",
      "nbeer", "nbeerm1", "nbeerm2", "nbeerm3", "nbeerm4", "nbeerq1", "nbeerq2", "nbeerq3", "nbeerq4",
      "sbeer", "sbeerm1", "sbeerm2", "sbeerm3", "sbeerm4", "sbeerq1", "sbeerq2", "sbeerq3", "sbeerq4",
      "ncider", "ncidm1", "ncidm2", "ncidm3", "ncidm4", "ncida", "ncidb", "ncidc", "ncidd",
      "scider", "scidm1", "scidm2", "scidm3", "scidm4", "scida", "scidb", "scidc", "scidd",
      "wdrink07b", "mdrink07b", "alclimit07b", "totalwug215", "totalwug2", "alcbsmt15", "menwug15", "womenwugg2", "menwugg215",
      "scnbeer", "scnbeerm1", "scnbeerm2", "scnbeerm3", "scnbeerm4", "scnbeerm98", "scnbeeq1", "scnbeeq2", "scnbeeq3", "scnbeeq4",
      "scsbeer", "scsbeerm1", "scsbeerm2", "scsbeerm3", "scsbeerm4", "scsbeerm98", "scsbeeq1", "scsbeeq2", "scsbeeq3", "scsbeeq4",
      "scncider", "scnciderm1", "scnciderm2", "scnciderm3", "scnciderm4", "scncidm98", "scncidq1", "scncidq2", "scncidq3", "scncidq4",
      "scscider", "scsciderm1", "scsciderm2", "scsciderm3", "scsciderm4", "scscidm98", "scscidq1", "scscidq2", "scscidq3", "scscidq4",
      "scspirit", "scspirq", "scsherry", "scsherrq", "scwine", "scwineq5", "scwineq6", "scbwineq",
      "scpops", "scpopsq1", "scpopsq2", "scpopsq3"
    )
  )

  data[, psu := paste0("2022_", psu)]
  data[, cluster := paste0("2022_", cluster)]

  data[, year := 2022]
  data[, country := "England"]

  return(data[])
}
