

#' Economic status
#'
#' Process the data on employment and occupation.
#'
#' The issues around using occupation-based social classifications for social survey research are discussed by
#'  \href{https://journals.sagepub.com/doi/full/10.1177/2059799116638003}{Connelly et al. 2016}. They advise using a range of alternative measures,
#'  but not creating new measures beyond what is already established.
#'
#' The classifications considered are:
#'
#' \itemize{
#' \item Employed / in paid work or not.
#' \item The \href{https://www.ons.gov.uk/methodology/classificationsandstandards/otherclassifications/thenationalstatisticssocioeconomicclassificationnssecrebasedonsoc2010}{NS-SEC measure}
#' which was constructed to measure the employment relations and conditions of occupations (i.e. it classifies people based on their employment occupation). It is
#' therefore not that good at classifying people who are not employed for various reasons.
#' \item The \href{https://humanrights.brightblue.org.uk/blog-1/2016/5/6/measuring-social-class}{NRS social grade system}. This measure is the one used in the
#' Tobacco and Alcohol Toolkit studies, but is not reported in the Health Survey for England. We create this variable by recategorising the NS-SEC 8 level variable.
#' This is important to facilitate the link of analysis to the Toolkit Study.
#' \item Manual vs. non-manual occupation. In the 2017 Tobacco control plan for England, there was a specific target to reduce the difference in rates of smoking
#' between people classified with a manual or non-manual occupation. We create this variable from the 3 level NS-SEC classification
#' by grouping Managerial and professional with intermediate occupations to give the non-manual group.
#' \item Economic status - retired / employed / unemployed.
#' \item Activity status for last week that adds more detail such as 'in education' and 'looking after home or family'.
#' }
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return
#' \itemize{
#' \item employ2cat: "employed", "unemployed"
#' \item nssec3_lab: "Managprof", "Intermediate", "Routinemanual", "Other". Social class/occupation based on the NS-SEC system. A four level variable for
#' managerial and professional occupations, intermediate occupations and routine and manual occupations. The fourth level is
#' 'other' that includes anyone (young/old/unemployed) who do not have an occupation.
#' \item social_grade: "ABC1", "C2DE". 2 level social grade classification.
#' \item man_nonman: "Manual", "Non-manual", "Other"
#' \item activity_lstweek: "Managprof" (employed), "Intermediate" (employed), "Routinemanual" (employed), "Unemployed", "In education", "Looking after home or family", "Sickness, injury or disability", "Retired"
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
#' data_2016 <- clean_economic_status(data = data_2016)
#'
#' }
#'
clean_economic_status <- function(
  data
) {

  ####################################################################
  # NS-SEC

  # Label 3 level variable
  data[nssec3 == 1, nssec3_lab := "managprof"]
  data[nssec3 == 2 , nssec3_lab := "intermediate"]
  data[nssec3 == 3 , nssec3_lab := "routinemanual"]
  data[nssec3 == 99 , nssec3_lab := "other"]

  # Fill missing for children with 'other'
  data[is.na(nssec3_lab) & age < 16, nssec3_lab := "other"]


  ####################################################################
  # Employment status

  # For years after 2010, base initially on whether in paid work

  if(max(data[ , year]) >= 2010) {

    data[paidwk == 1, employ2cat := "employed"]
    data[paidwk == 2, employ2cat := "unemployed"]

    data[ , paidwk := NULL]

  }

  data[year < 2010, employ2cat := NA_character_]
  data[year >= 2015, econact := NA_integer_]

  # Fill missing with info from other variables that indicate employment or not
  data[is.na(employ2cat) & (econact == 1 | activb == 2), employ2cat := "employed"]

  data[year < 2015 & is.na(employ2cat) & (econact %in% 2:4 | activb %in% c(1, 3:10)), employ2cat := "unemployed"]
  data[year >= 2015 & is.na(employ2cat) & (econact %in% 2:4 | activb %in% c(1, 3:9)), employ2cat := "unemployed"]

  data[is.na(employ2cat) & age < 16, employ2cat := "unemployed"]


  ####################################################################
  # NRS social grade

  # Match nssec8 to the NRS social grade classification used in the Toolkit study
  data[nssec8 %in% 1:3, social_grade := "ABC1"]
  data[nssec8 %in% 4:99 , social_grade := "C2DE"]


  ####################################################################
  # Manual vs. non-manual occupation

  data[ , man_nonman := nssec3_lab]
  data[nssec3_lab %in% c("managprof", "intermediate"), man_nonman := "nonmanual"]
  data[nssec3_lab == "routinemanual", man_nonman := "manual"]


  ####################################################################
  # Activity status for last week combined with economic activity variable

  data[year < 2015 & activb == 10, activity_lstweek := "home_or_family"]
  data[year >= 2015 & activb == 9, activity_lstweek := "home_or_family"]

  data[year < 2015 & activb %in% c(1, 3), activity_lstweek := "education"]
  data[year >= 2015 & activb == 1, activity_lstweek := "education"]

  data[year < 2015 & (econact == 3 | activb == 9), activity_lstweek := "retired"]
  data[year >= 2015 & (econact == 3 | activb == 8), activity_lstweek := "retired"]

  data[year < 2015 & (econact == 2 | activb %in% c(5, 6)), activity_lstweek := "unemployed"]
  data[year >= 2015 & (econact == 2 | activb %in% c(4, 5)), activity_lstweek := "unemployed"]

  data[year < 2015 & activb %in% 7:8, activity_lstweek := "sick_ill_disab"]
  data[year >= 2015 & activb %in% 6:7, activity_lstweek := "sick_ill_disab"]

  data[year < 2015 & (econact == 1 | activb %in% c(2, 4)), activity_lstweek := "employed"]
  data[year >= 2015 & (econact == 1 | activb %in% c(2, 3)), activity_lstweek := "employed"]

  # Fill missing using information on age
  data[is.na(activity_lstweek) & age < 16, activity_lstweek := "education"]
  data[is.na(activity_lstweek) & age >= 16 & age < 65 & employ2cat == "no", activity_lstweek := "unemployed"]
  data[is.na(activity_lstweek) & age >= 65, activity_lstweek := "retired"]


  # Remove variables not needed
  data[ , `:=`(econact = NULL, activb = NULL, nssec8 = NULL, nssec3 = NULL)]


return(data)
}
