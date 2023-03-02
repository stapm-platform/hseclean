

#' @section How the data is read and processed:
#' The data is read by the function [data.table::fread]. The 'root' and 'file' arguments are
#' pasted together to form the file path. The following are converted to NA:
#' c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A").
#' All variable names are converted to lower case.
#' The cluster and probabilistic sampling unit have the year appended to them.
#' Some renaming of variables is done for consistency with other years.
#'
#'
#'
