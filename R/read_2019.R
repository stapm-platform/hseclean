
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
    file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2019/hse_2019_eul_20211006.tab",
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
    alc_vars <- colnames(data[ , c(53:56, 67:70, 1081:1196, 1365:1438, 1479:1504)]) # done 2019
    
    # Do a scan of the data dictionary to get the column numbers of all smoking variables
    smk_vars <- colnames(data[ , c(24, 25, 49, 63, 73:74, 920:1080, 1332:1364, 1439:1478, 1598:1623)]) # needs review from here
    
    # health variables do not appear to be present in the 2019 survey
    #health_vars <- paste0("complst", 1:15)
    
    other_vars <- Hmisc::Cs(
      qrtint, #addnum,
      psu_scr, cluster194, wt_int, #wt_sc,
      seriala,
      age16g5, age35g, sex,
      origin2,
      qimd19, nssec3, nssec8,
      stwork,
      activb2,
      #Ag015g4, #Children, Infants,
      educend, topqual3,
      eqv5, #eqvinc,
      
      marstatd, # marital status inc cohabitees
      
      # how much they weigh
      htval, wtval)
    
    names <- c(other_vars, alc_vars, smk_vars)
    
    names <- tolower(names)
    
    data <- data[ , names, with = F]
    
  }
  
  # remove "_19" suffixes
  data.table::setnames(data, names(data), stringr::str_remove_all(names(data), "_19"))
  
  # relabel
  data.table::setnames(data,
                       c("cluster194", "psu_scr", "qrtint", "marstatd", "origin2", "activb2", "stwork","seriala", "qimd19", "startsmk19",
                         "moth_totalwug2", "moth_totalwug3", "fath_totalwug2", "fath_totalwug3", 
                         "drnktype1", "drnktype2", "drnktype3", "drnktype4", "drnktype5", "drnktype6", "drnktype7", "drnktype8", 
                         "nbrl7191", "nbrl7192", "nbrl7193", "nbrl7194", "nberpt7", "nbersm7", "nberlg7", "nberbt7", "l7ncod",
                         "sbrl7191", "sbrl7192", "sbrl7193", "sbrl7194", "sberpt7", "sbersm7", "sberlg7", "sberbt7", "l7scod",
                         "winel7191", "winel7192", "wgl250ml", "wgl175ml", "wgl125ml",
                         "nbeerm191", "nbeerm192", "nbeerm193", "nbeerm194", "nbeerq19a", "nbeerq19b", "nbeerq19c", "nbeerq19d",
                         "sbeerm191", "sbeerm192", "sbeerm193", "sbeerm194", "sbeerq19a", "sbeerq19b", "sbeerq19c", "sbeerq19d",
                         "wdrink7b", "mdrink7b", "alclimit7b", "totalwug2", "totalwug5", "alcbsmt", "menwug", "womwug2", "menwug2",
                         "cnbeer", "cnbeerm1", "cnbeerm2", "cnbeerm3", "cnbeerm4", "cnbeerqa", "cnbeerqb", "cnbeerqc", "cnbeerqd",
                         "csbeer", "csbeerm1", "csbeerm2", "csbeerm3", "csbeerm4", "csbeerqa", "csbeerqb", "csbeerqc", "csbeerqd",
                         "cspirits", "cspiritsq", "csherry", "csherryq", "cwine", "cwineq1", "cwineq2", "cbwineq19",
                         "cpops", "cpopsq111", "cpopsq112", "cpopsq113"),
                       
                       c("cluster", "psu", "quarter", "marstat", "ethnicity_raw", "activb", "paidwk","hse_id", "qimd", "startsmk",
                         "moth_totalwug215", "moth_totalwug315", "fath_totalwug215", "fath_totalwug315",
                         "d7typ1", "d7typ2", "d7typ3", "d7typ4", "d7typ5", "d7typ6", "d7typ7", "d7typ8",
                         "nbrl71", "nbrl72", "nbrl73", "nbrL74", "nberqhp7", "nberqsm7", "nberqlg7", "nberqbt7", "l7ncodeq", 
                         "sbrl71", "sbrl72", "sbrl73", "sbrL74", "sberqhp7", "sberqsm7", "sberqlg7", "sberqbt7", "l7scodeq",
                         "winel71", "winel72", "wgls250ml", "wgls175ml", "wgls125ml", 
                         "nbeerm1", "nbeerm2", "nbeerm3", "nbeerm4", "nbeerq1", "nbeerq2", "nbeerq3", "nbeerq4",
                         "sbeerm1", "sbeerm2", "sbeerm3", "sbeerm4", "sbeerq1", "sbeerq2", "sbeerq3", "sbeerq4",
                         "wdrink07b", "mdrink07b", "alclimit07b", "totalwug215", "totalwug2", "alcbsmt15", "menwug15", "womenwugg2", "menwugg215",
                         "scnbeer", "scnbeerm1", "scnbeerm2", "scnbeerm3", "scnbeerm4", "scnbeeq1", "scnbeeq2", "scnbeeq3", "scnbeeq4",
                         "scsbeer", "scsbeerm1", "scsbeerm2", "scsbeerm3", "scsbeerm4", "scsbeeq1", "scsbeeq2", "scsbeeq3", "scsbeeq4",
                         "scspirit", "scspirq", "scsherry", "scsherrq", "scwine", "scwineq5", "scwineq6", "scbwineq",
                         "scpops", "scpopsq1", "scpopsq2", "scpopsq3"))
  
  data[ , psu := paste0("2019_", psu)]
  data[ , cluster := paste0("2019_", cluster)]
  
  data[ , year := 2019]
  data[ , country := "England"]
  
  # remove 98.0 as don't know and return NA
  cols_98 <- c("scnbeer", "scnbeeq1", "scnbeeq2", "scnbeeq3", "scnbeeq4",
               "scsbeer", "scsbeeq1", "scsbeeq2", "scsbeeq3", "scsbeeq4",
               "scspirit", "scspirq", "scsherry", "scsherrq", 
               "scwine", "cwineqbt", "scbwineq",
               "scpops", "scpopsq1", "scpopsq2", "scpopsq3")
  data[, (cols_98) := lapply(.SD, function(x) {
    x[x == 98.0] <- NA
    return(x)
  }), .SDcols = cols_98]
  
  return(data[])
}

