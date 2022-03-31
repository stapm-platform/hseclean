

#' Health and biometric variables \lifecycle{maturing}
#'
#' Cleans data on presence/absence of certain categories of health condition, and on height and weight.
#'
#' HEATH CONDITIONS
#'
#' There are a set of 15 categories of conditions that are ascertained consistently across all years of the Heath Survey for England.
#'  These are:
#'  \itemize{
#'  \item Cancer
#'  \item Endocrine or metabolic condition
#'  \item Mental health condition
#'  \item Nervous system condition
#'  \item Eye condition
#'  \item Ear condition
#'  \item Heart or circulatory system condition
#'  \item Respiratory condition
#'  \item Digestive condition
#'  \item Genito-urinary condition
#'  \item Skin condition
#'  \item Musculo-skeletal condition
#'  \item Infectious disease
#'  \item Blood and related organs condition
#'  \item Other
#'  }
#'
#'  HEIGHT AND WEIGHT
#'
#'  Height (cm) and weight (kg). Weight is estimated above 130kg. Missing values of height and weight are
#'  replaced by the mean height and weight for each age, sex and IMD quintile.
#'  BMI is calculated according to kg / m^2.
#'
#'
#' @param data The Health Survey for England dataset.
#' @importFrom data.table :=
#' @return
#' \itemize{
#' \item Returns a variable indicating the presence/absence of each
#' health condition (hse_cancer, hse_endocrine, hse_heart, hse_mental, hse_nervous, hse_eye, hse_ear, hse_respir,
#' hse_disgest, hse_urinary, hse_skin, hse_muscskel, hse_infect, hse_blood, hse_other).
#' \item height and weight.
#' \item BMI (numeric)
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2001 <- read_2001()
#'
#' data_2001 <- clean_health_and_bio(data = data_2001)
#'
#' }
#'
clean_health_and_bio <- function(
  data
) {


  ################################################################
  # Presence / absence of certain categories of health condition

  data[compm1 == 0, hse_cancer := "no_cancer"]
  data[compm1 == 1, hse_cancer := "cancer"]

  if("compm2" %in% colnames(data)){
    data[compm2 == 0, hse_endocrine := "no_endocrine"]
    data[compm2 == 1, hse_endocrine := "endocrine"]

    data[compm7 == 0, hse_heart := "no_heart"]
    data[compm7 == 1, hse_heart := "heart"]

    data[ , `:=`(compm2 = NULL, compm7 = NULL)]

  }

  if("compm2a" %in% colnames(data)){
    data[compm2a == 0 | compm2b == 0, hse_endocrine := "no_endocrine"]
    data[compm2a == 1 | compm2b == 1, hse_endocrine := "endocrine"]

    data[compm7a == 0 | compm7b == 0 | compm7c == 0 | compm7d == 0 | compm7e == 0, hse_heart := "no_heart"]
    data[compm7a == 1 | compm7b == 1 | compm7c == 1 | compm7d == 1 | compm7e == 1, hse_heart := "heart"]

    data[ , `:=`(compm2a = NULL, compm2b = NULL, compm7a = NULL, compm7b = NULL, compm7c = NULL, compm7d = NULL, compm7e = NULL)]

  }

  data[compm3 == 0, hse_mental := "no_mental"]
  data[compm3 == 1, hse_mental := "mental"]

  data[compm4 == 0, hse_nervous := "no_nervous"]
  data[compm4 == 1, hse_nervous := "nervous"]

  data[compm5 == 0, hse_eye := "no_eye"]
  data[compm5 == 1, hse_eye := "eye"]

  data[compm6 == 0, hse_ear := "no_ear"]
  data[compm6 == 1, hse_ear := "ear"]

  data[compm8 == 0, hse_respir := "no_respir"]
  data[compm8 == 1, hse_respir := "respir"]

  data[compm9 == 0, hse_disgest := "no_disgest"]
  data[compm9 == 1, hse_disgest := "disgest"]

  data[compm10 == 0, hse_urinary := "no_urinary"]
  data[compm10 == 1, hse_urinary := "urinary"]

  data[compm11 == 0, hse_skin := "no_skin"]
  data[compm11 == 1, hse_skin := "skin"]

  data[compm12 == 0, hse_muscskel := "no_muscskel"]
  data[compm12 == 1, hse_muscskel := "muscskel"]

  data[compm13 == 0, hse_infect := "no_infect"]
  data[compm13 == 1, hse_infect := "infect"]

  data[compm14 == 0, hse_blood := "no_blood"]
  data[compm14 == 1, hse_blood := "blood"]

  if("compm15" %in% colnames(data)) {

    data[compm15 == 0, hse_other := "no_other"]
    data[compm15 == 1, hse_other := "other"]

    # Remove variables no longer needed
    data[ , `:=`(compm1 = NULL, compm3 = NULL, compm4 = NULL, compm5 = NULL, compm6 = NULL)]
    data[ , `:=`(paste0("compm", 8:15), NULL)]

  } else {

    # Remove variables no longer needed
    data[ , `:=`(compm1 = NULL, compm3 = NULL, compm4 = NULL, compm5 = NULL, compm6 = NULL)]
    data[ , `:=`(paste0("compm", 8:14), NULL)]

  }

  ################################################################
  # Height and weight

  # Replace missing values for weight and height with the subgroup mean value

  #data <- hseclean::impute_mean(data, c("wtval", "htval"), remove_zeros = TRUE,
  #                    strat_vars = c("year", "sex", "imd_quintile", "age_cat"))

  setnames(data, c("wtval", "htval"), c("weight", "height"))

  # Calculate BMI
  data[ , bmi := weight / ((.01 * height)^2)]


  return(data[])
}


