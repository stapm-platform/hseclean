
#' Read HSE data
#'
#' Reads and does basic cleaning of a selected year of the Health Survey for England.
#'
#' @param year Character - the file path and name.
#' @param root Character - the root directory.
#'
#' @return Returns a data table of the year of data selected.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2001 <- read_hse(year = 2001, root = "X:/")
#'
#' }
#'
read_hse <- function(
  year,
  root = c("X:/", "/Volumes/Shared/")
) {

  if(year == 2001) data <- hseclean::read_2001(root = root[1])
  if(year == 2002) data <- hseclean::read_2002(root = root[1])
  if(year == 2003) data <- hseclean::read_2003(root = root[1])
  if(year == 2004) data <- hseclean::read_2004(root = root[1])
  if(year == 2005) data <- hseclean::read_2005(root = root[1])
  if(year == 2006) data <- hseclean::read_2006(root = root[1])
  if(year == 2007) data <- hseclean::read_2007(root = root[1])
  if(year == 2008) data <- hseclean::read_2008(root = root[1])
  if(year == 2009) data <- hseclean::read_2009(root = root[1])
  if(year == 2010) data <- hseclean::read_2010(root = root[1])
  if(year == 2011) data <- hseclean::read_2011(root = root[1])
  if(year == 2012) data <- hseclean::read_2012(root = root[1])
  if(year == 2013) data <- hseclean::read_2013(root = root[1])
  if(year == 2014) data <- hseclean::read_2014(root = root[1])
  if(year == 2015) data <- hseclean::read_2015(root = root[1])
  if(year == 2016) data <- hseclean::read_2016(root = root[1])
  if(year == 2017) data <- hseclean::read_2017(root = root[1])

return(data)
}





