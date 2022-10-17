
#' Read HSE 2003
#'
#' Reads and does basic cleaning on the Health Survey for England 2003.
#'
#' All private households in the general population sample are eligible for inclusion in the survey
#' (up to a maximum of three households per address).
#' Up to two children aged 0-15 are interviewed in each household,
#' as well as up to 10 adults aged 16 and over. Information was obtained directly
#' from persons aged 13 and over. Information about children under 13 was obtained from a parent with the child present.
#'
#' WEIGHTING
#'
#' In 2003, non-response weighting was introduced to the HSE data. Although the HSE has generally presented a good match to the population, this decision was taken to keep up with the recent changes on many large-scale government sponsored surveys, and with the aim of reducing the possible biases.
#'
#' Non-response weights have been calculated for both adults and children. Four sets of non-response weights have been generated in total. Firstly a household weight was calculated to adjust for non-contact and for refusals of entire households. In addition, three sets of weights have been calculated to adjust (a) non-response among individuals in responding households (b) non-response to the nurse visit stage and (c) refusal to give a blood sample. The aim of each set of weights is that each of the main datasets (households, individuals, individuals who see a nurse, and individuals who give blood) can be treated as broadly representative of the general household population.
#'
#' The household weight (hhld_wt) is the product of household selection weight (to adjust for addresses with more than three households per address) and the calibration weight. These weights were applied separately within Government Office Region to bring the age and sex distribution of adults and children within responding households into line with each region’s population age-sex distribution, but with the constraint that adults and children from the same household are all given the same weight. The rationale behind calibration weighting is that it attaches an estimated probability of response to each household that ‘explains’ any discrepancy between the survey age-sex distribution and the population age-sex distribution.1
#'
#' The population control totals used for this exercise were the ONS projected population estimates for 2003, but with a small adjustment to exclude (our best estimate of) the population aged 65 and over living in communal establishments.
#'
#' At the individual level there are three sets of weights, the interview weight (int_wt), the nurse weight (nurse_wt) and the blood weight (blood_wt). The appropriate weight variable should be used for analysis done using data from the relevant sections.
#'
#' Children aged 0-15: To compensate for limiting the number of children interviewed in a household to two (the sampling fraction therefore being lower in households containing three or more children) it has become necessary to weight the child sample. This ‘child weight’ is the total number of children aged 0-15 in the household divided by the number of selected children in the household. The weighted sample was then adjusted to ensure that the age/sex distribution matched that of all children in co-operating households.
#'
#' The variable child_wt contains the appropriate selection weights for children aged 0-15.
#'
#' The variables int_wt and nurse_wt for children aged 0-15 includes both the child selection weights and non- response weights.
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
#' data_2003 <- read_2003("X:/", "ScHARR/PR_Consumption_TA/HSE/HSE 2003/UKDA-5098-tab/tab/hse03ai.tab")
#'
#' }
#'
read_2003 <- function(
  root = c("X:/", "/Volumes/Shared/"),
  file = "HAR_PR/PR/Consumption_TA/HSE/Health Survey for England (HSE)/HSE 2003/UKDA-5098-tab/tab/hse03ai.tab"
) {

  data <- data.table::fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "N/A")
  )

  setnames(data, names(data), tolower(names(data)))

  alc_vars <- colnames(data[ , 970:1037])
  smk_vars <- colnames(data[ , 912:969])
  health_vars <- paste0("compm", 1:15)

  other_vars <- Hmisc::Cs(
    mintb, addnum,
    area, cluster, int_wt, #child_wt,
    hserial,pserial,
    age, sex,
    ethnici,
    imd2004, econact, nssec3, nssec8,
    #econact2, #paidwk,
    activb, #HHInc,
    children, infants,
    educend, topqual3,
    eqv5,
    #eqvinc,

    marstatb, # marital status inc cohabitees

    # how much they weigh
    htval, wtval)

  names <- c(other_vars, alc_vars, smk_vars, health_vars)

  names <- tolower(names)

  data <- data[ , names, with = F]

  data.table::setnames(data, c("area", "imd2004", "d7unit", "int_wt", "marstatb", "ethnici", "pserial"),
           c("psu", "qimd", "d7unitwg", "wt_int", "marstat", "ethnicity_raw", "hse_id"))

  data[ , psu := paste0("2003_", psu)]
  data[ , cluster := paste0("2003_", cluster)]

  data[ , year := 2003]
  data[ , country := "England"]

  data[ , quarter := c(1:4)[findInterval(mintb, c(1, 4, 7, 10))]]
  data[ , mintb := NULL]

return(data[])
}



