
#' Alcohol Use Disorder Identification Test (AUDIT) 
#'
#' Calculating the AUDIT and AUDIT-C scores. 
#'
#' @param data Data table - the health survey dataset
#'
#' @importFrom data.table := setnames
#'
#' @return
#' \itemize{
#' \item audit1-10 - score for individual AUDIT questions
#' \item audit - full AUDIT score (1-40)
#' \item audit_c - AUDIT-C score (1-12)
#' \item audit_cat - categorisation of AUDIT; low risk (1-7), medium risk (8-15), higher risk (16-19), possible dependence (20-40)
#' \item audit_c_cat - categorisation of AUDIT-C; low risk (1-4), medium risk (5-7), higher risk (8-10), possible dependence (11-12)
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2016()
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- alc_drink_now(data)
#' data <- alc_sevenday(data)
#' data <- alc_weekmean(data)
#'
#' }
#'
alc_audit <- function(
    data
) {
  
  year <- as.integer(unique(data[ , year][1]))
  country <- unique(data[ , country][1])
  
  # =========================================================================
  # 1. SETUP & CONFIGURATION FLAGS
  # =========================================================================
  
  is_england  <- country == "England"
  is_scotland <- country == "Scotland"
  is_wales    <- country == "Wales"
  
  # Year-based logical flags 
  has_audit  <- is_england && year >= 2022
  
  if (has_audit){
  # =========================================================================
  # 2. TIDY UP THE AUDIT VARIABLES
  # =========================================================================
  
  setnames(data,
           c("audoft","audtydy","aud6mre","audstop","audexp","audmrn","audguil","audrem","audinj","audcon"),
           c("audit1","audit2","audit3","audit4","audit5","audit6","audit7","audit8","audit9","audit10"))
  
  data[, audit1 := audit1 - 1]
  data[, audit2 := audit2 - 1]
  data[, audit3 := audit3 - 1]
  data[, audit4 := audit4 - 1]
  data[, audit5 := audit5 - 1]
  data[, audit6 := audit6 - 1]
  data[, audit7 := audit7 - 1]
  data[, audit8 := audit8 - 1]
  data[audit9 == 1, audit9 := 0]
  data[audit9 == 3, audit9 := 4]
  data[audit10 == 1, audit10 := 0]
  data[audit10 == 3, audit10 := 4]
  
  ## If the answer to Audit 1 "How often do you have a drink containing alcohol?" is "Never",l
  ## respondents are re-routed to the next set of questions. If audit1 is 0 and audit2-10 missing, fill 
  ## in the missings as zeroes
  
  data[audit1 == 0 & is.na(audit2), audit2 := 0]
  data[audit1 == 0 & is.na(audit3), audit3 := 0]
  data[audit1 == 0 & is.na(audit4), audit4 := 0]
  data[audit1 == 0 & is.na(audit5), audit5 := 0]
  data[audit1 == 0 & is.na(audit6), audit6 := 0]
  data[audit1 == 0 & is.na(audit7), audit7 := 0]
  data[audit1 == 0 & is.na(audit8), audit8 := 0]
  data[audit1 == 0 & is.na(audit9), audit9 := 0]
  data[audit1 == 0 & is.na(audit10), audit10 := 0]

  
  ## Construct AUDIT (0-40) and AUDIT-C (0-12) scores
  
  data[, audit := audit1 + audit2 + audit3 + audit4 + audit5 + audit6 + audit7 + audit8 + audit9 + audit10]
  data[, audit_c := audit1 + audit2 + audit3]
  
  data[audit %in% 0, audit_cat := "abstainer"]
  data[audit %in% 1:7, audit_cat := "low_risk"]
  data[audit %in% 8:15, audit_cat := "medium_risk"]
  data[audit %in% 16:19, audit_cat := "higher_risk"]
  data[audit %in% 20:40, audit_cat := "possible_dependence"]
  
  data[audit_c %in% 0, audit_c_cat := "abstainer"]
  data[audit_c %in% 1:4, audit_c_cat := "low_risk"]
  data[audit_c %in% 5:7, audit_c_cat := "medium_risk"]
  data[audit_c %in% 8:10, audit_c_cat := "higher_risk"]
  data[audit_c %in% 11:12, audit_c_cat := "possible_dependence"]
  
  }
  
  return(data[])
}