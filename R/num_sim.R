

#' Simulate single years from age/time category
#'
#' Used to overcome the loss of variables (age, time since quit) in single years in the Health Surveys for England 2015+.
#'
#' Takes a category with beginning and end separated by "-" and randomly assigns each observation a number within the age category.
#' Or uses a lookup file to sample from the probability distribution of single values within each category.
#'
#' @param x Character - the age/time category e.g. "15-20".
#' @param lkup Data.table. Defaults to NULL. Must have column names ind, var, p. 
#' E.g. ind = endsmoke_cat, var = years_since_quit, p = probability.
#'
#' @return Returns an integer.
#' @export
#'
#' @examples
#'
#' num_sim("15-20")
#'
num_sim <- function(x, lkup = NULL) {
  
  if(!is.null(lkup)) {
    
    zz <- lkup[ind == x, var]
    p <- lkup[ind == x, p]
    z <- sample(x = zz, size = 1, prob = p)
    
  } else {
    
    x1 <- as.numeric(stringr::str_split_fixed(x, "-", 3)[1])
    x2 <- as.numeric(stringr::str_split_fixed(x, "-", 3)[2])
    z <- sample(x1:x2, 1)
    
  }
  
  return(as.double(z))
}
