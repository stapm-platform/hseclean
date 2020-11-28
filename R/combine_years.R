

#' Combine years of data \lifecycle{maturing}
#'
#' Combines years of data when provided as a list of data tables.
#'
#' @param data_list List of data tables to combine.
#'
#' @return Returns data table of combined data.
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_all <- combine_years(list(data1, data2, data3))
#'
#' }
#'
combine_years <- function(
  data_list
) {

  data <- data.table::rbindlist(data_list, use.names = T, fill = T)

return(data)
}



