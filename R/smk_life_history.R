

#' Ages of smoking initiation, quit and censoring
#'
#' Clean the ages that define when smokers started and stopped as recorded in the health survey data.
#'
#' For each individual smoker, the data recorded in the health survey implies a single age at which a
#' smoker started to smoke and, if they stopped, an age at which they did so. This provides a simplified view of
#' what might be a complicated life history of smoking, e.g. smoking to different frequencies or levels, or starting and
#' stopping multiple times.
#'
#' Both the start age and stop age will have error in them e.g. due to uncertainty in respondent recall,
#' and, for England in years 2015+, due to the reporting in categories of time intervals rather than single years, which we then impute
#' introducing random error.
#'
#' Start age is likely to be biased towards earlier ages, because for adults with missing values we use the age first tried
#' a cigarette, and for children the variable for start age does not necessarily mean the start of regular smoking,
#' it is just the age at which they started to smoke.
#'
#' We also create a variable for the age at which an individual was censored from our data sample -
#' this is their age at the survey + 1 year.
#'
#' # The variables computed using this function are used to reconstruct a simple life history of smoking for each individual who has
#' ever smoked regularly. This information is then used by the smktrans R package to estimate the
#' age-specific probabilities of smoking initiation or quitting smoking.
#'
#' Any missing data is assigned the average start or stop age for each age, sex and IMD quintile.
#'
#' @param data Data table - the health survey dataset.
#' @importFrom data.table :=
#' @return
#' \itemize{
#' \item smk_start_age
#' \item smk_stop_age
#' \item censor_age
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2001()
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- smk_status(data)
#' data <- smk_former(data)
#' data <- smk_life_history(data)
#'
#' }
#'
smk_life_history <- function(
    data
) {


  #############################################
  # Basic tidying

  if(!("kcigage" %in% colnames(data))) {

    data[ , kcigage := NA_real_]

  }

  if(!("dcigage" %in% colnames(data))) {

    data[ , dcigage := NA_real_]

  }

  data[ , startsmk := as.double(startsmk)]
  data[ , dcigage := as.double(dcigage)]
  data[ , kcigage := as.double(kcigage)]

  data[startsmk < 0 | startsmk >= 97, startsmk := NA_real_]
  data[dcigage < 0 | dcigage >= 97, dcigage := NA_real_]
  data[kcigage < 0 | kcigage >= 97, kcigage := NA_real_]


  #############################################
  # Create start age variable

  data[ , smk_start_age := NA_real_]

  # using the variable directly collected by the survey
  data[cig_ever == "ever_smoker", smk_start_age := as.double(startsmk)]

  # inferring the variable from the self report data on other timings
  # this method is less reliable
  # limit this to disallow calculated ages younger than age 8
  data[cig_smoker_status == "former" & is.na(smk_start_age), smk_start_age :=
         ifelse(as.double(age - years_since_quit - years_reg_smoker) >= 8,
                as.double(age - years_since_quit - years_reg_smoker), NA_real_)]

  # Age first tried a cigarette
  data[cig_ever == "ever_smoker" & is.na(smk_start_age), smk_start_age :=
         ifelse(as.double(dcigage) >= 8,
                as.double(dcigage), NA_real_)]

  # Age first tried a cigarette (8-15s) (SC)
  data[cig_ever == "ever_smoker" & is.na(smk_start_age), smk_start_age :=
         ifelse(as.double(kcigage) >= 8,
                as.double(kcigage), NA_real_)]

  # If someone is younger than 16 years and still doesn't have a recorded age of starting to smoke
  # then assume that they started to smoke at the age they currently are
  data[cig_smoker_status == "current" & is.na(smk_start_age) & age < 16, smk_start_age := as.double(age)]

  # disallow ages of starting to smoke less than 8 years old
  data[smk_start_age < 8, smk_start_age := NA_real_]

  #############################################
  # Create stop age variable

  data[ , smk_stop_age := NA_real_]

  data[cig_smoker_status == "former", smk_stop_age := as.double(age - years_since_quit)]

  data[cig_smoker_status == "former" & is.na(smk_stop_age) & age < 16, smk_stop_age := as.double(age)]

  # if stop age is younger than the estimated start age, make this the same as the start age
  data[cig_smoker_status == "former" & (smk_stop_age < smk_start_age), smk_stop_age := smk_start_age]

  #############################################
  # Create censor age variable

  # this is just the age at the survey plus 1

  data[ , censor_age := as.double(age + 1)]

  remove_vars <- c("startsmk", "dcigage", "kcigage")
  data[ , (remove_vars) := NULL]


  #############################################
  # Missing data
  #data <- hseclean::impute_mean(data, c("smk_start_age", "smk_stop_age"), remove_zeros = T)


  data[is.na(cig_smoker_status) | cig_smoker_status %in% c("current", "never"), smk_stop_age := NA_real_]
  data[is.na(cig_smoker_status) | cig_smoker_status == "never", smk_start_age := NA_real_]


  return(data[])
}




