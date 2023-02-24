
#' Per capita sales of alcohol for use in upshifting procedure from HMRC data
#' on duty receipts disaggregated by UK nation
#'
#' Code to generate these data is in the "data-raw" folder of the hseclean package.
#' The year of duty take data used is 2018-19. Population counts are for 2018 are used.
#' For England and Wales, population counts were obtained from the
#' Office for National Statistics.
#' For Scotland, population counts were obtained from National Records Scotland.
#'
#' @docType data
#'
#' @format A data table
#'
#' @source HMRC data on duty receipts disaggregated by UK nation: https://www.gov.uk/government/statistics/disaggregation-of-hmrc-tax-receipts
#'
"per_capita_alc_for_upshift"


#' Per capita sales of alcohol for use in upshifting procedure from MESAS data on alcohol sales in Scotland.
#'
#' Code to generate these data is in the "data-raw" folder of the hseclean package.
#' The years data used is 2008 - 2019.
#' For Scotland, population counts were obtained from National Records Scotland.
#'
#' @docType data
#'
#' @format A data table
#'
#' @source MESAS data on alcohol sales in Scotland: https://www.publichealthscotland.scot/publications/mesas-monitoring-report-2022/
#'
"per_capita_alc_for_upshift_scotland"
