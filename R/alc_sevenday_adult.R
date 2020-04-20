

#' Alcohol consumption in last seven-days (adults)
#'
#' Processes the information from the questions on drinking in the last seven days - how many times drank and characteristics of the heaviest drinking day.
#'
#' We estimate the number of
#' UK standard units of alcohol drunk on the heaviest drinking day by using the data on how many of what size measures of
#' different beverages were drunk, and combining this with our standard assumptions about beverage volume and alcohol content.
#'
#' In 2007 new questions were added asking which glass size was used when wine was consumed.
#' Therefore the post HSE 2007 unit calculations are not directly comparable to previous years’ data.
#'
#'
#' @param data Data table - the health survey dataset
#' @param abv_data Data table - our assumptions on the alcohol content of different beverages in (percent units / ml)
#' @param alc_volume_data Data table - our assumptions on the volume of different drinks (ml).
#' @importFrom data.table :=
#' @return
#' \itemize{
#' \item n_days_drink - number of days drank in last 7.
#' \item peakday - total units on heaviest drinking day
#' \item d7nbeer_units
#' \item d7sbeer_units
#' \item d7spirits_units
#' \item d7sherry_units
#' \item d7wine_units
#' \item d7pops_units
#' \item binge_cat (did_not_drink, binge, no_binge)
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2001()
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- alc_drink_now(data)
#' data <- alc_sevenday(data)
#'
#' }
#'
alc_sevenday_adult <- function(
  data,
  abv_data = hseclean::abv_data,
  alc_volume_data = hseclean::alc_volume_data
) {


  #################################################################
  # Adults - Number of days drank in last 7

  # Did you have an alcoholic drink in the seven days ending yesterday?
  data[age >= 16 & d7day == 2, n_days_drink := 0]

  # On how many days out of the last seven did you have an alcoholic drink?
  data <- hseclean::impute_mean(data, "d7many", remove_zeros = T)

  data[age >= 16 & d7day == 1, n_days_drink := d7many]

  data[ , `:=`(d7day = NULL, d7many = NULL)]

  #################################################################
  # Adults - Consumption on heaviest drinking day in past 7 days

  # Normal beer
  # SHeS 2010 does not have nberqbt7
  if(!("nberqbt7" %in% colnames(data))){
    data[, nberqbt7 := 0] 
  }  
  
  data <- hseclean::impute_mean(data, c("nberqhp7", "nberqsm7", "nberqlg7", "nberqbt7", "nberqpt7"))
  
  data[ , d7vol_nbeer := 0]
  data[d7typ1 == 1, d7vol_nbeer := nberqhp7 * alc_volume_data[beverage == "nbeerhalfvol", volume]]
  data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqsm7 * alc_volume_data[beverage == "nbeerscanvol", volume]]
  data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqlg7 * alc_volume_data[beverage == "nbeerlcanvol", volume]]
  data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqbt7 * alc_volume_data[beverage == "nbeerbtlvol", volume]]
  data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqpt7 * alc_volume_data[beverage == "nbeerhalfvol", volume] * 2]

  data[ , `:=`(nberqhp7 = NULL, nberqsm7 = NULL, nberqlg7 = NULL, nberqbt7 = NULL, nberqpt7 = NULL)]


  # Strong beer
  # SHeS 2010 does not have sberqbt7
  if(!("sberqbt7" %in% colnames(data))){
    data[, sberqbt7 := 0] 
  }  
  
  data <- hseclean::impute_mean(data, c("sberqhp7", "sberqsm7", "sberqlg7", "sberqbt7", "sberqpt7"))

  data[ , d7vol_sbeer := 0]
  data[d7typ2 == 1, d7vol_sbeer := sberqhp7 * alc_volume_data[beverage == "sbeerhalfvol", volume]]
  data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqsm7 * alc_volume_data[beverage == "sbeerscanvol", volume]]
  data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqlg7 * alc_volume_data[beverage == "sbeerlcanvol", volume]]
  data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqbt7 * alc_volume_data[beverage == "sbeerbtlvol", volume]]
  data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqpt7 * alc_volume_data[beverage == "sbeerhalfvol", volume] * 2]

  data[ , `:=`(sberqhp7 = NULL, sberqsm7 = NULL, sberqlg7 = NULL, sberqbt7 = NULL, sberqpt7 = NULL)]


  # Wine

  # If variables are not present, create them with NA so code works

  # For years 2001-2006, wine measured in number of 125ml glasses
  if(!("wineqgs7" %in% colnames(data))) {

    data[ , wineqgs7 := 0]

  }

  # In 2007, wineqgs7 was replaced by three sizes of glass
  if(!("wgls250ml" %in% colnames(data))) {

    data[ , wgls250ml := 0]
    data[ , wgls175ml := 0]
    data[ , wgls125ml := 0]

  }

  # In 2008, a further variable was introduced to indicate 125ml glasses inferred from a report of drinking all/part of a bottle
  if(!("wbtlgz" %in% colnames(data))) {

    data[ , wbtlgz := 0]

  }

  data <- hseclean::impute_mean(data, c("wineqgs7", "wgls250ml", "wgls175ml", "wgls125ml", "wbtlgz"))

  data[ , d7vol_wine := 0]

  # 175ml glasses
  data[d7typ5 == 1, d7vol_wine := wineqgs7 * alc_volume_data[beverage == "winesglassvol", volume]]

  # 250ml glasses
  data[d7typ5 == 1, d7vol_wine := wgls250ml * alc_volume_data[beverage == "winelglassvol", volume]]

  # 175ml glasses
  data[d7typ5 == 1, d7vol_wine := d7vol_wine + wgls175ml * alc_volume_data[beverage == "wineglassvol", volume]]

  # 125ml glasses
  data[d7typ5 == 1, d7vol_wine := d7vol_wine + wgls125ml * alc_volume_data[beverage == "winesglassvol", volume]]

  # 125ml glasses
  data[d7typ5 == 1, d7vol_wine := d7vol_wine + wbtlgz * alc_volume_data[beverage == "winesglassvol", volume]]

  data[ , `:=`(wineqgs7 = NULL, wbtlgz = NULL, wgls250ml = NULL, wgls175ml = NULL, wgls125ml = NULL)]


  # Fortified wine (Sherry)
  data <- hseclean::impute_mean(data, "sherqgs7")

  data[ , d7vol_sherry := 0]
  data[d7typ4 == 1, d7vol_sherry := sherqgs7 * alc_volume_data[beverage == "sherryvol", volume]]

  data[ , `:=`(sherqgs7 = NULL)]


  # Spirits
  data <- hseclean::impute_mean(data, "spirqme7")

  data[ , d7vol_spirits := 0]
  data[d7typ3 == 1, d7vol_spirits := spirqme7 * alc_volume_data[beverage == "spiritsvol", volume]]

  data[ , `:=`(spirqme7 = NULL)]


  # RTDs (alcopops)

  # For years 2001-2010, the only size measure was small cans/bottles

  # In 2011, a new question on large bottles was introduced
  if(!("popsqlg7" %in% colnames(data))) {

    data[ , popsqlg7 := 0]

  }
  
  # In SHeS, there are two separate measures for small cans and small bottles 
  if(!("popsqsmc7" %in% colnames(data))) {
    
    data[ , popsqsmc7 := 0]
    
  }
  

  data <- hseclean::impute_mean(data, c("popsqsm7", "popsqlg7", "popsqsmc7"))

  data[ , d7vol_pops := 0]

  # Small cans/bottles
  data[d7typ6 == 1, d7vol_pops := popsqsm7 * alc_volume_data[beverage == "popsscvol", volume]]

  # Small cans in SHeS
  data[d7typ6 == 1, d7vol_pops := d7vol_pops + popsqsmc7 * alc_volume_data[beverage == "popsscvol", volume]]
  
  # Large bottles
  data[d7typ6 == 1, d7vol_pops := d7vol_pops + popsqlg7 * alc_volume_data[beverage == "popslbvol", volume]]

  data[ , `:=`(popsqsm7 = NULL, popsqlg7 = NULL, popsqsmc7 = NULL)]


  #################################################################
  # Convert natural volumes into units

  # divide by 1000 because
  # first divide by 100 to convert % abv into a proportion
  # then divide by 10 because 1 UK standard unit of alcohol is defined as 10ml of pure ethanol

  data[age >= 16, nbeer_units7 := d7vol_nbeer * abv_data[beverage == "nbeerabv", abv] / 1000]
  data[age >= 16, sbeer_units7 := d7vol_sbeer * abv_data[beverage == "sbeerabv", abv] / 1000]
  data[age >= 16, spirits_units7 := d7vol_spirits * abv_data[beverage == "spiritsabv", abv] / 1000]
  data[age >= 16, sherry_units7 := d7vol_sherry * abv_data[beverage == "sherryabv", abv] / 1000]
  data[age >= 16, wine_units7 := d7vol_wine * abv_data[beverage == "wineabv", abv] / 1000]
  data[age >= 16, pops_units7 := d7vol_pops * abv_data[beverage == "popsabv", abv] / 1000]

  data[ , `:=`(d7vol_nbeer = NULL, d7vol_sbeer = NULL, d7vol_spirits = NULL, d7vol_sherry = NULL, d7vol_wine = NULL, d7vol_pops = NULL)]


  #################################################################
  # Generate peakday consumption

  data[ , peakday := nbeer_units7 + sbeer_units7 + spirits_units7 + sherry_units7 + wine_units7 + pops_units7]

  data[n_days_drink == 0, peakday := 0]

  data[n_days_drink > 0 & peakday == 0, peakday := NA]


  #################################################################
  # Categorise peak consumption

  data[n_days_drink == 0, binge_cat := "did_not_drink"]

  data[n_days_drink > 0 & peakday < 8 & sex == "Male", binge_cat := "no_binge"]
  data[n_days_drink > 0 & peakday < 6 & sex == "Female", binge_cat := "no_binge"]
  data[n_days_drink > 0 & peakday >= 8 & sex == "Male", binge_cat := "binge"]
  data[n_days_drink > 0 & peakday >= 6 & sex == "Female", binge_cat := "binge"]

  if("weekmean" %in% colnames(data) & "drinker_cat" %in% colnames(data)) {
    
    data[is.na(binge_cat) & (weekmean == 0 | drinker_cat == "abstainer"), binge_cat := "did_not_drink"]
  
  }
  
  # Remove variables no longer needed
  remove_vars <- c("drnksame", "whichday", colnames(data)[stringr::str_detect(colnames(data), "d7")])
  data[ , (remove_vars) := NULL]


return(data[])
}

