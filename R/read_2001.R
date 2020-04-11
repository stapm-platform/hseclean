
#' Read HSE 2001
#'
#' Reads and does basic cleaning on the Health Survey for England 2001.
#'
#' A sample of the population living in private households. All persons living in the house, including those
#' under 2 years were eligible for inclusion. At addresses where there were more than two children under 16,
#' two children were selected at random. Information was obtained directly from persons aged 13 and
#' over. Information about children aged 0-12 was obtained from a parent, with the child present.
#'
#' WEIGHTING
#'
#' There is no weighted variable for household adult data.
#' For children under 16, the weighted variable Child_Wt should be used.
#'
#' MISSING VALUES
#'
#' \itemize{
#' \item -1 Not applicable: Used to signify that a particular variable did not apply to a given respondent
#' usually because of internal routing. For example, men in women only questions.
#' \item -2 Schedule not applicable: Used mainly for variables on the self-completions when the
#' respondent was not of the given age range, also used for children without legal guardians in the
#' home who could not participate in the nurse schedule.
#' \item -6 Schedule not obtained: Used to signify that a particular variable was not answered because the
#' respondent did not complete or agree to a particular schedule (i.e. nurse schedule or selfcompletions).
#' \item -7 Refused/ not obtained: Used only for variables on the nurse schedules, this code indicates that a
#' respondent refused a particular measurement or test or the measurement was attempted but not
#' obtained or not attempted.
#' \item -8 Don't know, Can't say.
#' \item -9 No answer/ Refused
#' }
#'
#' @param root Character - the root directory.
#' @param file Character - the file path and name.
#'
#' @return Returns a data table. Note that:
#' \itemize{
#' \item Missing data ("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A") is replace with NA,
#' except -8 ("don't know") as this is data.
#' \item All variable names are converted to lower case.
#' \item Each data point is assigned a weight of 1 as there is no weight variable supplied.
#' \item A single sampling cluster is assigned.
#' \item The probabilistic sampling unit have the year appended to them.
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2001 <- read_2001("X:/", "ScHARR/PR_Consumption_TA/HSE/HSE 2001/UKDA-4628-tab/tab/hse01ai.tab")
#'
#' }
#'
read_2001 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2001/UKDA-4628-tab/tab/hse01ai.tab"
) {

  data <- fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A")
  )

  setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 1656:1783])
  smk_vars <- colnames(data[ , 927:984])
  health_vars <- paste0("compm", 1:14)

  other_vars <- Hmisc::Cs(

    mintb,

    area, child_wt, #cluster, #, #wt_int,

     #HHInc,

    eqv5,
    #eqvinc,

    # Education
    educend, topqual3,

    # Occupation
    econact, nssec3, nssec8,
    #econact2, #paidwk,
    activb,

    # Family
    marstatb, # marital status inc cohabitees
    children, # Number of children in HH (2 < age <= 15)
    infants, # Number of infants in HH (age <= 2)

    # demographic
    age,
    ethnici, # there are a number of cultural background variables that could be used
    nimd,
    sex,

    # how much they weigh
    htval, wtval #wtval2,

  )

  names <- c(other_vars, alc_vars, smk_vars, health_vars)

  names <- tolower(names)

  data <- data[ , ..names]

  setnames(data,

           c("area", "nimd", "d7unit", "marstatb", "ethnici",
             "nberf", "sberf", "spirf", "sherf", "winef", "popsf",
             "nberqhp", "nberqsm", "nberqlg", "nberqbt", "nberqpt",
             "sberqhp", "sberqsm", "sberqlg", "sberqbt", "sberqpt",
             "sherqgs", "spirqme"),

           c("psu", "qimd", "d7unitwg", "marstat", "ethnicity_raw",
             "nbeer", "sbeer", "spirits", "sherry", "wine", "pops",
             "nbeerq1", "nbeerq2", "nbeerq3", "nbeerq4", "nbeerq5",
             "sbeerq1", "sbeerq2", "sbeerq3", "sbeerq4", "sbeerq5",
             "sherryq", "spiritsq"))

  # Tidy survey weights
  data[ , wt_int := 1]
  data[age < 16, wt_int := child_wt]
  data[ , child_wt := NULL]

  # Set PSU and cluster
  data[ , psu := paste0("2001_", psu)]
  data[ , cluster := "2001_all"]

  data[ , year := 2001]
  data[ , country := "England"]

  data[ , quarter := c(1:4)[findInterval(mintb, c(1, 4, 7, 10))]]
  data[ , mintb := NULL]

return(data[])
}





