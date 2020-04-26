
#' Family status
#'
#' Process the data on the number of children in the household and the relationship
#' status of each respondent.
#'
#'
#' NUMBER OF CHILDREN AGE 0-15 YEARS IN THE HOUSEHOLD
#'
#' Categorised into: 0, 1, 2, 3+. The problem with the Health Survey for England is that from 2015 onwards,
#' the number of children in the household is
#' not provided as this information could be identifiable (you can get it if you apply and pay for a secure dataset).
#' Therefore, for years 2015+, the number of children in the household is completely missing and needs to be imputed.
#'
#'
#' RELATIONSHIP STATUS
#'
#' In previous versions of modelling (the SAPM alcohol binge model) relationship status has been described as
#' married/not-married. Here, we include more detail by using:
#' \itemize{
#' \item single
#' \item married, civil partnership or cohabiting
#' \item separated, divorced, widowed
#' }
#'
#' @param data Data table - the Health Survey for England dataset.
#' @importFrom data.table :=
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

  country <- unique(data[ , country][1])
  

  #####################################################
  # Relationship status (England)
  if(country == "England"){
  data[marstat == 1, relationship_status := "single"]

  # Married, civil partnership or cohabiting
  data[marstat == 2, relationship_status := "married"]
  data[marstat == 6, relationship_status := "cohabit"]

  # Separated, divorced or widowed
  data[marstat %in% c(3, 4, 5), relationship_status := "sep_div_wid"]

  # If under 18 and missing, assume single
  data[is.na(relationship_status) & age < 18, relationship_status := "single"]
  data[ , marstat := NULL]
  }

  # Relationship status (Scotland)
  if(country == "Scotland"){
  data[maritalg == 3, relationship_status := "single"]
  
  # Married, civil partnership or cohabiting
  data[maritalg %in% 1:2, relationship_status := "married"]
  
  # Separated, divorced or widowed
  data[maritalg %in% c(4, 5, 6), relationship_status := "sep_div_wid"]
  
  # If under 18 and missing, assume single
  data[is.na(relationship_status) & age < 18, relationship_status := "single"]
  data[ , maritalg := NULL]
  }
  
  #####################################################
  # Number of children in household
  
  # This variable now not possible to get from data 2015+ or from SHeS
  
  # for years 2015+, initially set the number of children and infants to NA
  data[year >= 2015 | country == "Scotland", `:=`(infants = NA, children = NA)]
  
  # Sum the number of infants and children
  data[ , kids := children + infants]
  
  # Change the variable from numeric to 4 categories
  data[kids > 3, kids := 3]
  data[ , kids := as.character(kids)]
  data[kids == "3", kids := "3+"]
  
  # For years < 2015,
  # if number of children is missing and age is less than 16 years,
  # assume no children
  data[country == "England" & year < 2015 & is.na(kids) & age < 16, kids := "0"]
  
  # Remove variables no longer required
  data[ , `:=`(infants = NULL, children = NULL)]
  
  # For years >= 2015, impute the number of kids
  required_vars <- c("age_cat", "sex", "relationship_status", "ethnicity_4cat", "imd_quintile", "eduend4cat", "degree", "nssec3_lab", "employ2cat", "activity_lstweek")
  
  testthat::expect_equal(
    length(required_vars),
    length(intersect(required_vars, colnames(data))),
    info = "one of these variables is missing from data:
  age_cat, sex, relationship_status, ethnicity_4cat, imd_quintile, eduend4cat, degree, nssec3_lab, employ2cat, activity_lstweek"
  )
    
  # impute kids
  data[year >= 2015, kids := predict(hseclean::impute_kids_model, newdata = data)]
  
  
return(data[])
}
