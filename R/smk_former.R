
#' Former smokers: time since quit and time as smoker
#'
#' Cleans the data on the time since quitting and time spent as a regular smoker among former smokers.
#'
#' The main issue to be overcome is that in the Health Surveys for England 2015+, time since quit and time
#' spent as a smoker is provided in categories rather than single years. We simulate the single years
#' by just picking a value at random within the time interval.
#'
#' We also fill missing data: for children 8-15 years, we assume that missing values for former smokers = 1 year.
#' For adults, we fill missing values with the average value for each age, sex and IMD quintile subgroup.
#'
#' @param data Data table - the Health Survey for England data.
#' @importFrom data.table :=
#' @return Returns an updated data table with:
#' \itemize{
#' \item years_since_quit
#' \item years_reg_smoker
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
#'
#' }
#'
smk_former <- function(
  data
) {

  country <- unique(data[ , country][1])
  
  #############################################################
  # How long ago did you stop smoking cigarettes?
  # Asked to former smokers who smoked regularly or ocassionally
  # If less than 1 year = 0
  data[year >= 2015 & country == "England", endsmoke := NA_real_]
  data[ , endsmoke := as.double(endsmoke)]
  data[(year < 2015 | country == "Scotland") & (endsmoke >= 97 | endsmoke < 0), endsmoke := NA_real_]

  data[cig_smoker_status == "former", years_since_quit := endsmoke]
  
  data[ , endsmoke := NULL]

  #############################################################
  # For approximately how many years did you smoke cigarettes regularly?
  # If less than 1 year = 0
  data[year >= 2015 & country == "England", smokyrs := NA_real_]
  data[ , smokyrs := as.double(smokyrs)]
  data[(year < 2015 | country == "Scotland") & (smokyrs >= 97 | smokyrs < 0), smokyrs := NA_real_]

  data[cig_smoker_status == "former", years_reg_smoker := smokyrs]

  data[ , smokyrs := NULL]

  #############################################################
  # For years 2015+ endsmoke and smkyrs are not provided by single years

  # endsmoke

  data[ , endsmoke_cat := NA_character_]
  data[year < 2015 | country == "Scotland", endsmokg := NA]

  data[endsmokg == 1 & cig_smoker_status == "former", endsmoke_cat := "0-4"]
  data[endsmokg == 2 & cig_smoker_status == "former", endsmoke_cat := "5-9"]
  data[endsmokg == 3 & cig_smoker_status == "former", endsmoke_cat := "10-14"]
  data[endsmokg == 4 & cig_smoker_status == "former", endsmoke_cat := "15-19"]
  data[endsmokg == 5 & cig_smoker_status == "former", endsmoke_cat := "20-29"]
  data[endsmokg == 6 & cig_smoker_status == "former", endsmoke_cat := "30-39"]
  data[endsmokg == 7 & cig_smoker_status == "former", endsmoke_cat := "40-49"]
  data[endsmokg == 8 & cig_smoker_status == "former", endsmoke_cat := "50-59"]

  data[ , endsmokg := NULL]

  # Assign single years of time since quit by just picking an age within the category given
  data[!is.na(endsmoke_cat), years_since_quit := sapply(endsmoke_cat, hseclean::num_sim)]

  data[ , endsmoke_cat := NULL]

  # smokyrs

  data[ , smokyrs_cat := NA_character_]
  data[year < 2015 | country == "Scotland", smokyrsg := NA]

  data[smokyrsg == 1 & cig_smoker_status == "former", smokyrs_cat := "0-4"]
  data[smokyrsg == 2 & cig_smoker_status == "former", smokyrs_cat := "5-9"]
  data[smokyrsg == 3 & cig_smoker_status == "former", smokyrs_cat := "10-14"]
  data[smokyrsg == 4 & cig_smoker_status == "former", smokyrs_cat := "15-19"]
  data[smokyrsg == 5 & cig_smoker_status == "former", smokyrs_cat := "20-29"]
  data[smokyrsg == 6 & cig_smoker_status == "former", smokyrs_cat := "30-39"]
  data[smokyrsg == 7 & cig_smoker_status == "former", smokyrs_cat := "40-49"]
  data[smokyrsg == 8 & cig_smoker_status == "former", smokyrs_cat := "50-59"]

  data[ , smokyrsg := NULL]

  # Assign single years of time since quit by just picking an age within the category given
  data[!is.na(smokyrs_cat), years_reg_smoker := sapply(smokyrs_cat, hseclean::num_sim)]

  data[ , smokyrs_cat := NULL]

  #############################################################
  # Missing data

  # For children 8-15, assume any missing time since quit is 1 year
  data[is.na(years_since_quit) & cig_smoker_status == "former" & age < 16, years_since_quit := 1]

  # For children 8-15, assume any missing time as smoker is 1 year
  data[is.na(years_reg_smoker) & cig_smoker_status == "former" & age < 16, years_reg_smoker := 1]

  # Years since quitting
  data[years_since_quit < 1, years_since_quit := NA]
  data[cig_smoker_status == "former" & years_since_quit < .5, cig_smoker_status := "current"]
  data[cig_smoker_status == "former" & years_since_quit >= .5 & years_since_quit < 1, years_since_quit := 1]
  
  # Back-fill missing data in smoker status
  data[is.na(cig_smoker_status) & years_since_quit >= 1, cig_smoker_status := "former"]
  data[is.na(cig_smoker_status) & years_reg_smoker >= 1, cig_smoker_status := "former"]
  
  # Mean-impute missing values for years since quitting and years regular smoker
  data <- hseclean::impute_mean(data, c("years_since_quit", "years_reg_smoker"))

  data[is.na(cig_smoker_status) | cig_smoker_status %in% c("current", "never"), `:=`(years_since_quit = NA, years_reg_smoker = NA)]

  data[, years_since_quit := as.double(ceiling(years_since_quit))]
  data[, years_reg_smoker := as.double(ceiling(years_reg_smoker))]

  
return(data[])
}



