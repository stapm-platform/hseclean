
#' Use the Townsend Index of Deprivation
#'
#' Produce a version of the Health Survey for England data that has the Townsend Index in it,
#' based on the probabilistic mapping between the 2015 English Index of Multiple Deprivation and
#' the Townsend Index from the 2001 census.
#'
#' @param data Data table - the Health Survey for England dataset
#' @param imdq_to_townsend_map Data table - laid out as a matrix that gives the probability that someone from each IMD quintile
#' will be in each Townsend quintile.
#'
#' @return Returns a re-sampled version of the Health Survey for England data,
#' in which each data point is duplicated 5 times (once for each Townsend quintile) and the survey weights adjusted accordingly.
#' @export
#'
#' @examples
#'
#' kn <- 1e3
#'
#' test_data <- data.table(
#'   imd_quintile = sample(c("5_most_deprived", "4", "3", "2", "1_least_deprived"), kn, replace = T),
#'   wt_int = runif(kn)
#' )
#'
#' data_with_townsend <- use_townsend(test_data)
#'
use_townsend <- function(
  data,
  imdq_to_townsend_map = hseclean::imdq_to_townsend
) {

  # Make sure data has complete information for IMD quintile
  kn <- nrow(data)
  data <- data[!is.na(imd_quintile)]
  if(kn > nrow(data)) warning(nrow(data) - kn, " rows removed due to missing IMD quintile")

  # Merge in the IMD to Townsend lookup
  data <- merge(data, imdq_to_townsend_map, by = "imd_quintile")

  # Calculate the required number of duplicates by Townsend
  data[ , townsend1 := wt_int * townsend1]
  data[ , townsend2 := wt_int * townsend2]
  data[ , townsend3 := wt_int * townsend3]
  data[ , townsend4 := wt_int * townsend4]
  data[ , townsend5 := wt_int * townsend5]

  # Convert the data from wide to long form (duplicating each row 5x)
  wt1 <- sum(data$wt_int)

  keepvars <- colnames(data)[!(colnames(data) %in% c(paste0("townsend", 1:5)))]

  data <- melt(data, id.vars = keepvars, value.name = "wt_int1", variable.name = "townsend_quintile")

  wt2 <- sum(data$wt_int1)

  if(wt1 != wt2) warning("Expansion by Townsend has changed the sum of the survey weights")

  data[ , wt_int := NULL]
  setnames(data, "wt_int1", "wt_int")

return(data)
}

