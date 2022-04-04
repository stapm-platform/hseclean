

#' Demographic variables
#'
#' Processes demographic variables.
#'
#' ETHNICITY
#' In an attempt to harmonise different years of data to the recommended definitions, we have pooled the Asian and other categories.
#' \itemize{
#' \item White (English, Irish, Scottish, Welsh, other European)
#' \item Mixed / multiple ethnic groups
#' \item Asian / Asian British (includes African-Indian, Indian, Pakistani, Bangladeshi), plus Other ethnic group (includes Chinese, Japanese, Philippino, Vietnamese, Arab)
#' \item Black / African / Caribbean / Black British (includes Caribbean, African)
#' }
#' Following inspection of the data, the white/non-white classification does look appropriate,
#' especially given the likely limited sample sizes - so the 2 level variable has also been created.
#'
#' For 2008-2013 of the Scottish Health Survey, we can create the same 4-category variable as for the HSE, however for 2014 onwards,
#' the Scottish Health Survey 2018 only identifies 5 groups of ethnicity:
#' \itemize{
#' \item White (Scottish)
#' \item White (Other British)
#' \item White (Other)
#' \item Asian
#' \item Other minority ethnic
#' }
#' On the basis of this, only the 2 level variable (white/non-white) has been created for all years for Scotland.
#'
#' @param data Data table - the Health Survey for England/Scotland Health Survey dataset.
#' @importFrom data.table :=
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

  country <- unique(data[ , country][1])

  ###################################################
  # Categorise ethnicity
  if(country == "England"){

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

  }

  if(country == "Scotland"){
    data[year == 2008 & ethnicity_raw %in% 1:4, ethnicity := "white"]
    data[year == 2008 & ethnicity_raw == 5 , ethnicity := "mixed"]
    data[year == 2008 & ethnicity_raw %in% c(6:9, 13) , ethnicity := "asian_other"]
    data[year == 2008 & ethnicity_raw %in% 10:12, ethnicity := "black"]

    data[year %in% 2009:2011 & ethnicity_raw %in% 1:9, ethnicity := "white"]
    data[year %in% 2009:2011 & ethnicity_raw == 10 , ethnicity := "mixed"]
    data[year %in% 2009:2011 & ethnicity_raw %in% c(11:15, 20:21) , ethnicity := "asian_other"]
    data[year %in% 2009:2011 & ethnicity_raw %in% 16:19, ethnicity := "black"]

    data[year %in% 2012:2013 & ethnicity_raw %in% 1:6, ethnicity := "white"]
    data[year %in% 2012:2013 & ethnicity_raw == 7 , ethnicity := "mixed"]
    data[year %in% 2012:2013 & ethnicity_raw %in% c(8:12, 18:19) , ethnicity := "asian_other"]
    data[year %in% 2012:2013 & ethnicity_raw %in% 13:17, ethnicity := "black"]

    data[year %in% 2014:2100, ethnicity := NA]

    data[ , ethnicity_4cat := ethnicity]
    data[ , ethnicity_2cat := ethnicity]

    data[year %in% 2014:2100 & ethnicity_raw %in% 1:3, ethnicity_2cat := "white"]
    data[year %in% 2014:2100 & ethnicity_raw %in% 4:5, ethnicity_2cat := "non_white"]
    data[ethnicity %in% c("mixed", "asian_other", "black"), ethnicity_2cat := "non_white"]

  }

  data[ , `:=`(ethnicity_raw = NULL,  ethnicity = NULL)]

  ###################################################
  # Label the sexes

  data[ , sex := c("Male", "Female")[sex]]


  ###################################################
  # Label index of multiple deprivation quintiles
  if(country == "England"){
    data[qimd == 5, imd_quintile := "5_most_deprived"]
    data[qimd == 4, imd_quintile := "4"]
    data[qimd == 3, imd_quintile := "3"]
    data[qimd == 2, imd_quintile := "2"]
    data[qimd == 1, imd_quintile := "1_least_deprived"]

    data[ , qimd := NULL]
  }

  # Scottish IMD quintiles
  if(country == "Scotland"){
    data[simd == 5, imd_quintile := "5_most_deprived"]
    data[simd == 4, imd_quintile := "4"]
    data[simd == 3, imd_quintile := "3"]
    data[simd == 2, imd_quintile := "2"]
    data[simd == 1, imd_quintile := "1_least_deprived"]

    data[ , simd := NULL]
  }

return(data[])
}




