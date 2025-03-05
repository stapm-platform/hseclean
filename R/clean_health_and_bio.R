

#' Health and biometric variables
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

  country <- unique(data[ , country][1])
  year <- unique(data[ , year][1])

  ################################################################
  # Presence / absence of certain categories of health condition

  if("compm1" %in% colnames(data)){

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

  }

  # WHS

  if(country == "Wales" & year <= 2015) {

    data[mental == 0, hse_mental := "no_mental"]
    data[mental == 1, hse_mental := "mental"]

    # Limiting long term illness ICD Chapter
    if("lltich1" %in% colnames(data)) {

      data[ , hse_cancer_lim := "no_cancer"]
      data[lltich1 == 1 | lltich2 == 1 | lltich3 == 1 | lltich4 == 1, hse_cancer_lim := "cancer"]

      data[ , hse_endocrine_lim := "no_endocrine"]
      data[lltich1 == 2 | lltich2 == 2 | lltich3 == 2 | lltich4 == 2, hse_endocrine_lim := "endocrine"]

      data[ , hse_mental_lim := "no_mental"]
      data[lltich1 == 3 | lltich2 == 3 | lltich3 == 3 | lltich4 == 3, hse_mental_lim := "mental"]

      data[ , hse_nervous_lim := "no_nervous"]
      data[lltich1 == 4 | lltich2 == 4 | lltich3 == 4 | lltich4 == 4, hse_nervous_lim := "nervous"]

      data[ , hse_eye_lim := "no_eye"]
      data[lltich1 == 5 | lltich2 == 5 | lltich3 == 5 | lltich4 == 5, hse_eye_lim := "eye"]

      data[ , hse_ear_lim := "no_ear"]
      data[lltich1 == 6 | lltich2 == 6 | lltich3 == 6 | lltich4 == 6, hse_ear_lim := "ear"]

      data[ , hse_heart_lim := "no_heart"]
      data[lltich1 == 7 | lltich2 == 7 | lltich3 == 7 | lltich4 == 7, hse_heart_lim := "heart"]

      data[ , hse_respir_lim := "no_respir"]
      data[lltich1 == 8 | lltich2 == 8 | lltich3 == 8 | lltich4 == 8, hse_respir_lim := "respir"]

      data[ , hse_digest_lim := "no_digest"]
      data[lltich1 == 9 | lltich2 == 9 | lltich3 == 9 | lltich4 == 9, hse_digest_lim := "digest"]

      data[ , hse_urinary_lim := "no_urinary"]
      data[lltich1 == 10 | lltich2 == 10 | lltich3 == 10 | lltich4 == 10, hse_urinary_lim := "urinary"]

      data[ , hse_muscskel_lim := "no_muscskel"]
      data[lltich1 == 11 | lltich2 == 11 | lltich3 == 11 | lltich4 == 11, hse_muscskel_lim := "muscskel"]

      data[ , hse_infect_lim := "no_infect"]
      data[lltich1 == 12 | lltich2 == 12 | lltich3 == 12 | lltich4 == 12, hse_infect_lim := "infect"]

      data[ , hse_blood_lim := "no_blood"]
      data[lltich1 == 13 | lltich2 == 13 | lltich3 == 13 | lltich4 == 13, hse_blood_lim := "blood"]

      data[ , hse_skin_lim := "no_skin"]
      data[lltich1 == 14 | lltich2 == 14 | lltich3 == 14 | lltich4 == 14, hse_skin_lim := "skin"]

      #data[ , `:=`(lltich1 = NULL, lltich2 = NULL, lltich3 = NULL, lltich4 = NULL, llti = NULL, lltibi = NULL,
      #             lltiicd1 = NULL, lltiicd2 = NULL, lltiicd3 = NULL, lltiicd4 = NULL)]

    }
  }
  ################################################################
  # Height and weight

  # Replace missing values for weight and height with the subgroup mean value

  if(country == "Wales"){

    if(year <= 2015) {

      setnames(data, c("wtkg", "htcm", "bmi2"), c("weight", "height", "bmi"))

    } else if (year > 2015) {

      setnames(data, c("dvwtkg", "dvhtcm", "dvbmi2"), c("weight", "height", "bmi"))

    }

  } else {

    data <- hseclean::impute_mean(data, c("wtval", "htval"), remove_zeros = TRUE,
                                  strat_vars = c("year", "sex", "imd_quintile", "age_cat"))

    setnames(data, c("wtval", "htval"), c("weight", "height"))

    # Calculate BMI
    data[ , bmi := weight / ((.01 * height)^2)]

  }

  return(data[])
}


