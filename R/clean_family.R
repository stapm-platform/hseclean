
#' Family status
#'
#' Process the data on the number of children in the household and the relationship
#' status of each respondent.
#'
#'
#' NUMBER OF CHILDREN IN THE HOUSEHOLD
#'
#' Categorised into: 0, 1, 2, 3+. The problem with the Health Survey for England is that from 2015 onwards,
#' the number of children in the household is
#' not provided as this information could be identifiable (you can get it if you apply and pay for a secure dataset).
#' Therefore, for years 2015+, the number of children in the household is completely missing and needs to be imputed.
#'
#'
#' RELATIONSHIP STATUS
#'
#' In previous versions of modelling (e.g. the alcohol binge model) relationship status has been described as
#' married/not-married. Here, we include more detail by using:
#' \itemize{
#' \item single
#' \item married, civil partnership or cohabiting
#' \item separated, divorced, widowed
#' }
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return Returns an updated version of data with the new family variables:
#' \itemize{
#' \item 'kids' - number of children age <= 15 years in the household (0, 1, 2, 3+)
#' \item 'relationship_status' of the respondent (single, married, cohabit, sep_div_wid)
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2001 <- read_2001()
#'
#' data_2001 <- clean_family(data = data_2001)
#'
#' }
#'
clean_family <- function(
  data
) {

  #####################################################
  # Number of children in household

  # This variable now not possible to get from data 2015+
  # for years 2015+, set the number of children and infants to NA
  data[year >= 2015, `:=`(infants = NA, children = NA)]

  # For other years, if the response was 'don't know', then set this to NA
  data[children == -8, children := NA]
  data[infants == -8, infants := NA]

  # Sum the number of infants and children
  data[ , kids := children + infants]

  # Change the variable from numeric to 4 categories
  data[kids > 3, kids := 3]
  data[ , kids := as.character(kids)]
  data[kids == "3", kids := "3+"]

  # For years < 2015,
  # if number of children is missing and age is less than 16 years,
  # assume no children
  data[is.na(kids) & age < 16, kids := "0"]

  # Remove variables no longer required
  data[ , `:=`(infants = NULL, children = NULL)]


  #####################################################
  # Relationship status

  data[marstat == 1, relationship_status := "single"]

  # Married, civil partnership or cohabiting
  data[marstat == 2, relationship_status := "married"]
  data[marstat == 6, relationship_status := "cohabit"]

  # Separated, divorced or widowed
  data[marstat %in% c(3, 4, 5), relationship_status := "sep_div_wid"]

  # If under 16 and missing, assume single
  data[is.na(relationship_status) & age < 16, relationship_status := "single"]

  data[ , marstat := NULL]



return(data)
}
