
#' Drink frequency \lifecycle{maturing}
#'
#' Convert the surveyed drink frequency to a measure of days per week on which drinking occurred.
#'
#' @param x Drinking frequency
#'
#' @return Returns a numeric translation (days/week) of the categorical drinking frequency variable.
#' \item{Almost every day}{7}
#' \item{Five or six days a week}{5.5}
#' \item{Three or four days a week}{3.5}
#' \item{Once or twice a week}{1.5}
#' \item{Once or twice a month}{0.375}
#' \item{Once every couple of months}{0.188}
#' \item{Once or twice a year}{0.029}
#' 
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

