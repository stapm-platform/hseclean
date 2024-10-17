

#' Education variables
#'
#' Process the data on education.
#'
#' The main education variable used is a four category description of the age at which someone finished full-time education.
#' The categories are:
#' \itemize{
#' \item never went to school,
#' \item left at 15 years or younger,
#' \item left at 16-18,
#' \item left at 19 years or over.
#' }
#' If someone was still in full time education at the time of the survey, then if they were younger than 18 years, we
#' assumed they would leave at 16-18, and if they were older than 18 years, we assumed they would leave at 19 years or over.
#'
#' A further education variable is also produced - which indicates whether an individual reached a degree as their top
#' qualification or not. Here a degree is defined as an "NVQ4/NVQ5/Degree or equiv".
#'
#' @param data Data table - the Health Survey for England dataset.
#' @importFrom data.table :=
#' @return Returns an updated version of data with the new education variables:
#' \itemize{
#' \item eduend4cat - 4 categories of when finished education,
#' \item degree - 2 categories for degree or not.
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2016 <- read_2016()
#'
#' data_2016 <- clean_education(data = data_2016)
#'
#' }
#'
clean_education <- function(
  data
) {

  ############################################################
  # Age finished education

  if("educend" %in% colnames(data)){
  data[educend == 2, eduend4cat := "never_went_to_school"]
  data[educend %in% 3:4, eduend4cat := "15_or_under"]
  data[educend %in% 5:7, eduend4cat := "16-18"]
  data[educend == 8, eduend4cat := "19_or_over"]
  data[educend == 1 & age < 18, eduend4cat := "16-18"]
  data[educend == 1 & age >= 18, eduend4cat := "19_or_over"]

  data[is.na(eduend4cat) & age < 18, eduend4cat := "16-18"]

  data[ , educend := NULL]
  }

  ############################################################
  # Top qualification - degree or not
  if("topqual3" %in% colnames(data)){
    data[topqual3 == 1, degree := "degree"]
    data[topqual3 %in% 2:7, degree := "no_degree"]

    data[ , topqual3 := NULL]
  }

  if("hedqul08" %in% colnames(data)){
    data[hedqul08 %in% 1:2, degree := "degree"]
    data[hedqul08 %in% 3:6, degree := "no_degree"]

    data[ , hedqul08 := NULL]
  }

  if("educat" %in% colnames(data)){
    data[educat %in% 1:2, degree := "degree"]
    data[educat %in% 3:7, degree := "no_degree"]

    data[ , educat := NULL]
  }

  # Fill some missing values
  data[is.na(degree) & age < 18, degree := "no_degree"]

  if("eduend4cat" %in% colnames(data)){
  data[is.na(degree) & eduend4cat %in% c("16-18", "15_or_under", "never_went_to_school"), degree := "no_degree"]
  data[is.na(degree) & eduend4cat == "19_or_over", degree := "degree"]
  }


return(data[])
}
