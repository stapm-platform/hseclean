
#' Drink frequency
#'
#' Convert the surveyed drink frequency to a measure of days per week on which drinking occurred.
#'
#' @param x Drinking frequency
#'
#' @return Returns a numeric translation of the categorical drinking frequency variable.
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' alc_drink_freq(1)
#'
#' }
#'
alc_drink_freq <- function(x) {

  x1 <- rep(0, length(x))

  x1[x == 1] <- 7 # Almost every day
  x1[x == 2] <- 5.5 # Five or six days a week
  x1[x == 3] <- 3.5 # Three or four days a week
  x1[x == 4] <- 1.5 # Once or twice a week
  x1[x == 5] <- 0.375 # Once or twice a month
  x1[x == 6] <- 0.188 # Once every couple of months
  x1[x == 7] <- 0.029 # Once or twice a year

  return(x1)
}

