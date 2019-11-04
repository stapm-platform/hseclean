

#' Age variables
#'
#' Processes the data on age.
#'
#' From 2015 onwards, the HSE no longer supplies age in single years (to prevent individual identification).
#' For our modelling, we require age in single years, so we apply a method that randomly assigns
#' an age in single years to individuals for whom we only have an age category. The age categories we work with are:
#' 0-1, 2-4, 5-7, 8-10, 11-12, 13-15, 16-17, 18-19, 20-24, 25-29, 30-34, 35-39, 40-44, 45-49,
#'  50-54, 55-59, 60-64, 65-69, 70-74, 75-79, 80-84, 85-89, 90+. These categories are the finest scale version of age
#'  that is available for years 2015+. We then select only individuals younger than 90 years
#'  for our modelling.
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return Returns an updated version of data with the new age variables: age in single years, age in the categories above,
#' and birth cohort.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2016 <- read_2016()
#'
#' data_2016 <- clean_age(data = data_2016)
#'
#' }
#'
clean_age <- function(
  data
) {

  data[ , year := as.double(year)]

  if("age" %in% colnames(data)) {

    data[ , age := as.double(age)]

    # Make agebands
    data[year < 2015, age_cat := c(
      "0-1",
      "2-4",
      "5-7",
      "8-10",
      "11-12",
      "13-15",
      "16-17",
      "18-19",
      "20-24",
      "25-29",
      "30-34",
      "35-39",
      "40-44",
      "45-49",
      "50-54",
      "55-59",
      "60-64",
      "65-69",
      "70-74",
      "75-79",
      "80-84",
      "85-89",
      "90+"
    )[findInterval(age, c(-10, 2, 5, 8, 11, 13, 16, 18, seq(20, 90, 5)))]]

  } else {

    data[ , age := NA_real_]

  }

  if("age16g5" %in% colnames(data)) {

    data[year >= 2015 & age16g5 %in% 1:17, age_cat := c(
      "16-17",
      "18-19",
      "20-24",
      "25-29",
      "30-34",
      "35-39",
      "40-44",
      "45-49",
      "50-54",
      "55-59",
      "60-64",
      "65-69",
      "70-74",
      "75-79",
      "80-84",
      "85-89",
      "90+"
    )[age16g5]]

    data[ , age16g5 := NULL]

  }

  if("age35g" %in% colnames(data)) {

    data[year >= 2015 & age35g %in% 1:6, age_cat := c("0-1", "2-4", "5-7", "8-10", "11-12", "13-15")[age35g]]

    data[ , age35g := NULL]

  }

  # Select ages up to 90 years
  data <- data[age_cat != "90+"]

  # For years 2015+ age is not provided by single years -
  # so assign single years of age by just picking an age within the category given
  data[is.na(age), age := sapply(age_cat, hseclean::num_sim)]

  # Calculate birth cohort
  data[ , cohort := year - age]


return(data)
}
