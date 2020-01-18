

#' Demographic variables
#'
#' Processes demographic variables.
#'
#' ETHNICITY
#' Previous SAPM modelling has used a simple white/non-white classification. The ONS recommend a harmonised ethnicity measure
#' for use in social surveys (\href{https://gss.civilservice.gov.uk/wp-content/uploads/2017/08/Ethnic-Group-June-17.pdf}{ONS, 2017}).
#' The use of ethnicity measures is also discussed in \href{https://journals.sagepub.com/doi/full/10.1177/2059799116642885}{Connelly et al. 2016},
#' who recommend testing the sensitivity of analyses to different specifications. We try to map the HSE categories to the ONS
#' recommended groups for England. However, over the years, the HSE is not clear or consistent in how they have categorised
#' chinese and arab as 'asian' or 'other'. In an attempt to harmonise, we have pooled the asian and other categories.
#' \itemize{
#' \item White (English, Irish, Scottish, Welsh, other European)
#' \item Mixed / multiple ethnic groups
#' \item Asian / Asian British (includes African-Indian, Indian, Pakistani, Bangladeshi),
#' plus Other ethnic group (includes Chinese, Japanese, Philippino, Vietnamese, Arab)
#' \item Black / African / Caribbean / Black British (includes Caribbean, African)
#' }
#' On the basis of this look at the data, the white/non-white classification does look appropriate, especially given
#' the likely limited sample sizes - so this 2 level variable has also been created.
#'
#' @param data Data table - the Health Survey for England dataset.
#'
#' @return
#' \itemize{
#' \item ethnicity_4cat: 4 level variable (see above).
#' \item ethnicity_2cat: 2 level variable (white/nonwhite).
#' \item sex: m/f
#' \item imd_quintile
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2001 <- read_2001()
#'
#' data_2001 <- clean_demographic(data = data_2001)
#'
#' }
#'
clean_demographic <- function(
  data
) {

  ###################################################
  # Categorise ethnicity

  data[year %in% 2001:2007 & ethnicity_raw == 1, ethnicity := "white"]
  data[year %in% 2001:2007 & ethnicity_raw == 2, ethnicity := "mixed"]

  data[year %in% 2001:2003 & ethnicity_raw %in% c(3, 4), ethnicity := "black"]
  data[year %in% 2001:2003 & ethnicity_raw %in% c(5, 6), ethnicity := "asian_other"]
  data[year %in% 2001:2003 & ethnicity_raw == 7, ethnicity := "asian_other"]

  data[year == 2004 & ethnicity_raw == 3, ethnicity := "black"]
  data[year == 2004 & ethnicity_raw == 4, ethnicity := "asian_other"]

  data[year %in% 2005:2007 & ethnicity_raw == 3, ethnicity := "asian_other"]
  data[year %in% 2005:2007 & ethnicity_raw == 4, ethnicity := "black"]

  data[year %in% 2004:2007 & ethnicity_raw == 5, ethnicity := "asian_other"]

  data[year %in% 2008:2010 & ethnicity_raw %in% 1:3, ethnicity := "white"]
  data[year %in% 2008:2010 & ethnicity_raw %in% 4:7, ethnicity := "mixed"]
  data[year %in% 2008:2010 & ethnicity_raw %in% 8:11, ethnicity := "asian_other"]
  data[year %in% 2008:2010 & ethnicity_raw %in% 12:14, ethnicity := "black"]
  data[year %in% 2008:2010 & ethnicity_raw %in% 15:16, ethnicity := "asian_other"]

  data[year %in% 2011:2014 & ethnicity_raw %in% 1:4, ethnicity := "white"]
  data[year %in% 2011:2014 & ethnicity_raw %in% 5:8, ethnicity := "mixed"]
  data[year %in% 2011:2014 & ethnicity_raw %in% c(9, 10, 11, 13, 17), ethnicity := "asian_other"]
  data[year %in% 2011:2014 & ethnicity_raw %in% 14:16, ethnicity := "black"]
  data[year %in% 2011:2014 & ethnicity_raw == 18, ethnicity := "asian_other"]

  data[year %in% 2015:2100 & ethnicity_raw == 1, ethnicity := "white"]
  data[year %in% 2015:2100 & ethnicity_raw == 4, ethnicity := "mixed"]
  data[year %in% 2015:2100 & ethnicity_raw == 3, ethnicity := "asian_other"]
  data[year %in% 2015:2100 & ethnicity_raw == 2, ethnicity := "black"]
  data[year %in% 2015:2100 & ethnicity_raw == 5, ethnicity := "asian_other"]

  data[ , ethnicity_4cat := ethnicity]
  data[ , ethnicity_2cat := ethnicity]
  data[ethnicity %in% c("mixed", "asian_other", "black"), ethnicity_2cat := "non_white"]

  data[ , `:=`(ethnicity_raw = NULL, ethnicity = NULL)]


  ###################################################
  # Label the sexes

  data[ , sex := c("Male", "Female")[sex]]


  ###################################################
  # Label index of multiple deprivation quintiles

  data[qimd == 5, imd_quintile := "5_most_deprived"]
  data[qimd == 4, imd_quintile := "4"]
  data[qimd == 3, imd_quintile := "3"]
  data[qimd == 2, imd_quintile := "2"]
  data[qimd == 1, imd_quintile := "1_least_deprived"]

  data[ , qimd := NULL]


return(data)
}




