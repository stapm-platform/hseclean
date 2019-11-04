

#' Simulate single years from age/time category
#'
#' Used to overcome the loss of variables (age, time since quit) in single years in the Health Surveys for England 2015+.
#'
#' Takes a category with beginning and end separated by "-" and randomly assigns each observation a number within the age category.
#'
#' @param x Character - the age/time category e.g. "15-20".
#'
#' @return Returns an integer.
#' @export
#'
#' @examples
#'
#' num_sim("15-20")
#'
num_sim <- function(x) {

  x1 <- as.numeric(stringr::str_split_fixed(x, "-", 3)[1])
  x2 <- as.numeric(stringr::str_split_fixed(x, "-", 3)[2])
  z <- sample(x1:x2, 1)

return(as.double(z))
}
