
#' Characteristics of smoking
#'
#' Clean the variables that describe how many cigarettes per day people smoke on average, and to what level of addiction people smoke.
#'
#' The main variable is the average number of cigarettes smoked per day. For adults, this is calculated
#' from questions about how many cigarettes are smoked typically on a weekday vs. a weekend
#' (this is a weighted average to account for more weekdays in a week than weekends). For children,
#' this is based on asking how many cigarettes were smoked in the last week. Missing values are imputed as
#' the average amount smoked for an age, sex and Index of Multiple Deprivation quintile subgroup.
#'
#' For England, cigarette preferences are categorised based on the answer to 'what is the main type of cigarette smoked'. In
#' later years of the Health Survey for England, new questions are added from year 2013 that ask how many handrolled vs. machine rolled
#' cigarettes are smoked on a weekday vs. a weekend.
#'
#' For England, information on the time from waking until smoking the first cigarette of the day is used.
#' The time from waking until first smoking has a high level of missingness. Together with data on the number of cigarettes smoked per day
#' these data allow calculation of
#'  \href{https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3307335/}{the heaviness of smoking index}.
#'
#' For Scotland, people who smoke handrolled cigarettes so cannot give the amount that they typically smoke per day in terms of cigarettes
#' report the amount smoked in either grams or ounces of tobacco typically smoked per day. In these cases, a conversion rate of
#' 0.5g tobacco per cigarette it used. The corresponding number of cigarettes smoked per day is calculated and added to any
#' machine rolled cigarette consumption recorded for that smoker.
#'
#' For Scotland, the health survey data do not allow the estimation of the proportional split in tobacco consumption
#' between machine rolled and handrolled cigarettes.
#'
#' The average number of cigarettes per day is capped at a theoretical maximum of 60 per day.
#'
#' @param data Data table - the health survey dataset.
#' @importFrom data.table :=
#' @return
#' \itemize{
#' \item cigs_per_day - numeric (0+)
#' \item smoker_cat (non_smoker, 10_or_less, 11_to_20, 21_to_30, 31_or_more)
#' \item banded_consumption (non_smoker, light, moderate, heavy)
#' \item cig_type (non_smoker, hand rolled, machine rolled)
#' \item units_RYO_tob - numeric (0+) (years 2013+)
#' \item units_FM_cigs - numeric (0+) (years 2013+)
#' \item prop_handrolled - numeric (0-1) (years 2013+)
#' \item time_to_first_cig (non_smoker, less_than_5_minutes, five_to_thirty_minutes,
#' thirty_minutes_but_less_than_1_hour, one_hour_or_more)
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' library(hseclean)
#'
#' data <- read_2017(root = "/Volumes/Shared/")
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- smk_status(data)
#' data <- smk_amount(data)
#'
#' }
#'
smk_amount <- function(
    data
) {

  country <- unique(data[ , country][1])
  year <- unique(data[ , year][1])

  ####################################################
  # Number of cigarettes smoked per day

  # Assign missing values for smokers as zeros

  # Adults age >= 16 years

  # cigwend and cigwday are in both the England and Scotland data
  # the result could be compared against the cigdyal variable -
  # which is the estimate of the average number of cigarettes per day calculated by the data providers

  # Scotland has a different method of recording the amount of handrolling tobacco smoked compared to England

  # for Scotland, the cigwday and cigwend variables already merge data from the CAPI interviews and self completion questionnaire

  data[is.na(cigwday), cigwday := 0]
  data[is.na(cigwend), cigwend := 0]

  #data[cig_smoker_status == "current" & cigwday >= 0 & cigwend >= 0, cigs_per_day := ((5 * cigwday) + (2 * cigwend)) / 7]
  data[cig_smoker_status == "current", cigs_per_day := ((5 * cigwday) + (2 * cigwend)) / 7]

  # current smokers should have an amount smoked per day that is greater than zero
  #data[cig_smoker_status == "current" & cigs_per_day == 0, cigs_per_day := NA]

  if(country == "Scotland"){

    # Add in handrolled cigarettes smoked by people who primarily smoke handrolled cigarettes

    ounce_to_gram_conversion <- 28.3495
    grams_per_cigarette <- 0.5

    data[is.na(dlyg), dlyg := 0]
    data[is.na(wkndg), wkndg := 0]

    data[is.na(dlyoz), dlyoz := 0]
    data[is.na(wkndoz), wkndoz := 0]

    data[ , dlyg := dlyg + (dlyoz * ounce_to_gram_conversion)]
    data[ , wkndg := wkndg + (wkndoz * ounce_to_gram_conversion)]

    data[cig_smoker_status == "current", cigs_per_day := cigs_per_day + (((5 * dlyg * (1 / grams_per_cigarette)) + (2 * wkndg * (1 / grams_per_cigarette))) / 7)]

  }

  # Children 8-15 years
  if(country == "England"){

    # Assign missing values for smokers as zeros
    data[cig_smoker_status == "current" & age < 16, cigs_per_day := 0]

    data[cig_smoker_status == "current" & age < 16 & kcignum > 0, cigs_per_day := kcignum / 7]
    #data[cig_smoker_status == "current" & age < 16 & kcignum == 0, cigs_per_day := 1 / 7]

    # I sometimes smoke, but I don't smoke every week
    data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 4, cigs_per_day := .25]

    # I smoke between one and six cigarettes a week
    data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 5, cigs_per_day := 3]

    # I smoke more than six cigarettes a week
    data[cig_smoker_status == "current" & age < 16 & is.na(cigs_per_day) & kcigreg == 6, cigs_per_day := 7]

    data[ , `:=` (kcigreg = NULL, kcignum = NULL, kcigweek = NULL, kcigregg = NULL)]

    # For missing, fill with average for each age, sex and IMD quintile
    #data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = T)

  }

  # In SHeS, no smoking data for children
  if(country == "Scotland") {

    data[age < 16, cigs_per_day := NA]

    # For missing, fill with average for each age, sex and IMD quintile, above 16
    #data <- impute_mean(data, "cigs_per_day", remove_zeros = T)
  }

  # For non-smokers = 0
  data[cig_smoker_status %in% c("never", "former"), cigs_per_day := 0]
  data[is.na(cig_smoker_status), cigs_per_day := NA]

  #remove_vars <- c("cigwday", "cigwend")
  #data[ , (remove_vars) := NULL]


  if(country == "England"){

    ####################################################
    # Categorise cigarette preferences

    # Do this based on "cigtyp" - the main type of cigarette smoked
    # This variable is the only question on cigarette type that is asked consistently across years

    data[cig_smoker_status %in% c("never", "former"), cig_type := "non_smoker"]
    data[cig_smoker_status == "current" & cigtyp == 1, cig_type := "machine_rolled"] # tipped
    data[cig_smoker_status == "current" & cigtyp == 2, cig_type := "machine_rolled"] # untipped
    data[cig_smoker_status == "current" & cigtyp == 3, cig_type := "hand_rolled"]

    ####################################################
    # Divide the number of cigarettes smoked per day into factory-made and hand-rolled


    # Note that the data for Scotland has a different form to that for England and extensions to this function
    # will be needed to process that


    if(year < 2013) {

      # Fill any missing values of cigs per day
      data[ , ageband := c("<13", "13-17", "18-24", "25-34", "35-54", "55+")[findInterval(age, c(-1, 13, 18, 25, 35, 55, 1000))]]

      data[, cigs_per_day_av := mean(cigs_per_day, na.rm = T), by = c("year", "sex", "imd_quintile", "ageband")]
      data[(is.na(cigs_per_day) | cigs_per_day == 0) & cig_smoker_status == "current", cigs_per_day := cigs_per_day_av]

      data[, cigs_per_day_av := mean(cigs_per_day[cigs_per_day > 0], na.rm = T), by = c("year", "sex", "ageband")]
      data[(is.na(cigs_per_day) | cigs_per_day == 0) & cig_smoker_status == "current", cigs_per_day := cigs_per_day_av]

      data[, cigs_per_day_av := NULL]
      data[, ageband := NULL]

      #data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = TRUE)

      data[cig_smoker_status != "current", `:=`(cigs_per_day = NA, cig_type = NA)]

    }


    if(year >= 2013) {

      data[cig_smoker_status == "current" & !is.na(cigs_per_day) & is.na(rollwk), `:=`(rollwk = 0)]
      data[cig_smoker_status == "current" & !is.na(cigs_per_day) & is.na(rollwe), `:=`(rollwe = 0)]

      data[cig_smoker_status != "current", `:=`(rollwk = 0, rollwe = 0)]
      data[cig_smoker_status != "current" & is.na(cigs_per_day), `:=`(rollwk = NA, rollwe = NA)]

      data[cig_smoker_status == "current", units_RYO_tob := ((5 * rollwk) + (2 * rollwe)) / 7]
      data[cig_smoker_status != "current", units_RYO_tob := 0]

      data[ , units_FM_cigs := cigs_per_day - units_RYO_tob]

      # There are some inconsistencies in the data
      # it looks like this is often due to a typo -
      # and all cigs are handrolled but the numbers have not been entered the same
      # in cigwday and rollwk or cigwend and rollwe

      # Fix this by assuming that whenever units_FM_cigs < 0 then all cigarettes are handrolled
      data[units_FM_cigs < 0 & cig_type == "hand_rolled", units_FM_cigs := 0]

      data[cigs_per_day == 0 & units_RYO_tob > 0, cigs_per_day := units_RYO_tob]


      # Fill any missing values of cigs per day
      data[ , ageband := c("<13", "13-17", "18-24", "25-34", "35-54", "55+")[findInterval(age, c(-1, 13, 18, 25, 35, 55, 1000))]]

      data[, cigs_per_day_av := mean(cigs_per_day[cigs_per_day > 0], na.rm = T), by = c("year", "sex", "imd_quintile", "ageband")]
      data[(is.na(cigs_per_day) | cigs_per_day == 0) & cig_smoker_status == "current", cigs_per_day := cigs_per_day_av]

      data[, cigs_per_day_av := mean(cigs_per_day[cigs_per_day > 0], na.rm = T), by = c("year", "sex", "ageband")]
      data[(is.na(cigs_per_day) | cigs_per_day == 0) & cig_smoker_status == "current", cigs_per_day := cigs_per_day_av]

      data[, cigs_per_day_av := NULL]
      data[, ageband := NULL]

      #data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = TRUE, strat_vars = c("year", "sex", "imd_quintile", "age_cat"))
      #data <- hseclean::impute_mean(data, "cigs_per_day", remove_zeros = TRUE, strat_vars = c("year", "imd_quintile"))



      data[cigs_per_day > 0 & cig_type == "machine_rolled" & units_FM_cigs == 0, units_FM_cigs := cigs_per_day]
      data[cigs_per_day > 0 & cig_type == "hand_rolled" & units_RYO_tob == 0, units_RYO_tob := cigs_per_day]


      # Calculate proportion of handrolled cigarettes
      data[ , prop_handrolled := units_RYO_tob / cigs_per_day]

      # Fill any missing values of prop handrolled
      # assume <18s share the same product preferences as 18-24
      data[ , ageband := c("<25", "25-34", "35-54", "55+")[findInterval(age, c(-1, 25, 35, 55, 1000))]]
      data[, prop_handrolled_av := mean(prop_handrolled, na.rm = T), by = c("year", "sex", "imd_quintile", "ageband")]
      data[is.na(prop_handrolled) & cig_smoker_status == "current", prop_handrolled := prop_handrolled_av]
      data[, prop_handrolled_av := NULL]
      data[, ageband := NULL]

      #data <- hseclean::impute_mean(data, "prop_handrolled", remove_zeros = FALSE, strat_vars = c("year", "sex", "imd_quintile", "age_cat"))
      #data <- hseclean::impute_mean(data, "prop_handrolled", remove_zeros = FALSE, strat_vars = c("year", "imd_quintile"))


      data[!is.na(cigs_per_day) & (is.na(units_RYO_tob) | (units_RYO_tob == 0 & units_FM_cigs == 0)), units_RYO_tob := cigs_per_day * prop_handrolled]
      data[!is.na(cigs_per_day) & (is.na(units_RYO_tob) | (units_RYO_tob == 0 & units_FM_cigs == 0)), units_FM_cigs := cigs_per_day * (1 - prop_handrolled)]

      data[cigs_per_day > 0 & units_RYO_tob == 0 & units_FM_cigs == 0, `:=`(units_RYO_tob = NA, units_FM_cigs = NA, prop_handrolled = NA)]

      data[cig_smoker_status != "current", `:=`(cigs_per_day = NA, cig_type = NA, units_RYO_tob = NA, units_FM_cigs = NA, prop_handrolled = NA)]

      data[is.na(cig_type) & prop_handrolled > 0.5, cig_type := "hand_rolled"]
      data[is.na(cig_type) & prop_handrolled <= 0.5, cig_type := "machine_rolled"]

      data[prop_handrolled == 1, units_FM_cigs := 0]

      data[prop_handrolled > 1, `:=`(units_FM_cigs = 0, prop_handrolled = 1, units_RYO_tob = cigs_per_day)]

      # check
      #data[cig_smoker_status == "current" & cigs_per_day != (units_FM_cigs + units_RYO_tob)]


      data[, units_RYO_tob := as.double(round(units_RYO_tob, 3))]
      data[, units_FM_cigs := as.double(round(units_FM_cigs, 3))]


      data[ , cigs_per_day := units_RYO_tob + units_FM_cigs]

    }

  }


  ####################################################
  # Categorise daily smoking

  # Version 1
  data[cig_smoker_status %in% c("never", "former"), smoker_cat := "non_smoker"]
  data[cig_smoker_status == "current" & cigs_per_day > 0 & cigs_per_day <= 10, smoker_cat := "10_or_less"]
  data[cig_smoker_status == "current" & cigs_per_day > 10 & cigs_per_day <= 20, smoker_cat := "11_to_20"]
  data[cig_smoker_status == "current" & cigs_per_day > 20 & cigs_per_day <= 30, smoker_cat := "21_to_30"]
  data[cig_smoker_status == "current" & cigs_per_day > 30, smoker_cat := "31_or_more"]

  # Version 2
  data[cig_smoker_status %in% c("never", "former"), banded_consumption := "non_smoker"]
  data[smoker_cat == "10_or_less", banded_consumption := "light"]
  data[smoker_cat == "11_to_20", banded_consumption := "moderate"]
  data[smoker_cat %in% c("21_to_30", "31_or_more"), banded_consumption := "heavy"]


  ####################################################
  # Truncate the distribution of amount smoked to
  # help make the project more reliable by removing extreme / uncertain positive skew

  # Cap cigs per day at 60

  data[cigs_per_day > 60, cigs_per_day := 60]

  if("prop_handrolled" %in% names(data)) {

    data[, units_RYO_tob := cigs_per_day * prop_handrolled]
    data[, units_FM_cigs := cigs_per_day * (1 - prop_handrolled)]

  }

  ####################################################

  # Check if someone has been recorded as a smoker
  # but due to the way NAs are treated as zeros in the processing code above
  # have been assigned as smoking 0 cigarettes per day due to having missing data
  # for the amount smoked per day

  data[smoker_cat != "non_smoker" & cigs_per_day == 0, cigs_per_day := NA]

  if("prop_handrolled" %in% names(data)) {

    data[is.na(cigs_per_day), units_RYO_tob := NA]
    data[is.na(cigs_per_day), units_FM_cigs := NA]
    data[is.na(cigs_per_day), prop_handrolled := NA]

  }

  ####################################################

  if(country == "England"){


    # Time from waking until smoking

    data[cig_smoker_status %in% c("never", "former"), time_to_first_cig := "non_smoker"]
    data[cig_smoker_status == "current" & firstcig == 1, time_to_first_cig := "less_than_5_minutes"]
    data[cig_smoker_status == "current" & firstcig %in% 2:3, time_to_first_cig := "five_to_thirty_minutes"]
    data[cig_smoker_status == "current" & firstcig == 4, time_to_first_cig := "thirty_minutes_but_less_than_1_hour"]
    data[cig_smoker_status == "current" & firstcig %in% 5:6, time_to_first_cig := "one_hour_or_more"]

    # For children, assume time from waking to first cigarette is longest
    data[cig_smoker_status == "current" & age < 16 & is.na(time_to_first_cig), time_to_first_cig := "one_hour_or_more"]

    remove_vars <- c("cigdyal", "cigtyp", "firstcig")
    data[ , (remove_vars) := NULL]

  }


  return(data[])
}

