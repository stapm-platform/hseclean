

#' Ages of smoking initiation, quit and censoring
#'
#' Clean the ages that define when smokers started and stopped as recorded in the Health Survey for England data.
#'
#' For each individual smoker, the data recorded in the Health Survey for England implies a single age at which a
#' smoker started to smoke and, if they stopped, an age at which they did so. This provides a simplified view of
#' what might be a complicated life history of smoking, e.g. smoking to different frequencies or levels, or starting and
#' stopping multiple times.
#'
#' Both the start age and stop age will have error in them e.g. due to uncertainty in respondent recall,
#' and, for years 2015+, due to the reporting in categories of time intervals rather than single years, which we then impute
#' introducing random error.
#'
#' Start age is likely to be biased towards earlier ages, because for adults with missing values we use the age first tried
#' a cigarette, and for children the variable for start age does not necessarily mean the start of regular smoking,
#' it is just the age at which they started to smoke.
#'
#' We also create a variable for the age at which an individual was censored from our data sample -
#' this is their age at the survey + 1 year.
#'
#' Any missing data is assigned the average start or stop age for each age, sex and IMD quintile.
#'
#' @param data Data table - the Health Survey for England dataset.
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

  data[cig_ever == "ever_smoker", smk_start_age := as.double(startsmk)]

  data[cig_smoker_status == "former" & is.na(smk_start_age), smk_start_age := as.double(age - years_since_quit - years_reg_smoker)]

  data[cig_ever == "ever_smoker" & is.na(smk_start_age), smk_start_age := as.double(dcigage)]
  data[cig_ever == "ever_smoker" & is.na(smk_start_age), smk_start_age := as.double(kcigage)]

  data[cig_smoker_status == "current" & is.na(smk_start_age) & age < 16, smk_start_age := as.double(age)]


  #############################################
  # Create stop age variable

  data[ , smk_stop_age := NA_real_]

  data[cig_smoker_status == "former", smk_stop_age := as.double(age - years_since_quit)]

  data[cig_smoker_status == "former" & is.na(smk_stop_age) & age < 16, smk_stop_age := as.double(age)]


  #############################################
  # Create censor age variable

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




