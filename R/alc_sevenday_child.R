

#' Alcohol consumption in last seven-days (children)
#'
#' Processes the information from the questions on drinking in the last seven days -
#' whether different types of beverages have been drunk in last 7 days,
#' and if so, how much of each was drunk.
#'
#' We estimate the number of
#' UK standard units of alcohol drunk in the last 7 days by using the data on how many of what size measures of
#' different beverages were drunk, and combining this with our standard assumptions about beverage volume and alcohol content.
#'
#'
#' MISSING DATA
#'
#' Normally, if one of the constituent variables was missing, the whole variable would be marked as missing.
#' However, due to high missingness, we just assume any missing = 0, and so are likely to make underestimates.
#'
#' @param data Data table - the Health Survey for England dataset
#' @param abv_data Data table - our assumptions on the alcohol content of different beverages in (percent units / ml)
#' @param volume_data Data table - our assumptions on the volume of different drinks (ml).
#'
#' @return
#' \itemize{
#' \item total_units7_ch - total units drunk in last 7 days
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
#' data <- alc_drink_now_allages(data)
#' data <- alc_weekmean_adult(data)
#' data <- alc_sevenday_adult(data)
#' data <- alc_sevenday_child(data)
#'
#' }
#'
alc_sevenday_child <- function(
  data,
  abv_data = hseclean::abv_data,
  alc_volume_data = hseclean::alc_volume_data
) {

  year <- as.integer(unique(data[ , year][1]))
  
  yearset1 <- c(2001:2006, 2008:2100)
  yearset2 <- 2007

  # Beer

  data[ , d7vol_beer_ch := 0]
  data[aber2w == 1, d7vol_beer_ch := aber2qpt * 2 * alc_volume_data[beverage == "nbeerhalfvol", volume]]
  data[aber2w == 1, d7vol_beer_ch := d7vol_beer_ch + aber2qlg * alc_volume_data[beverage == "nbeerlcanvol", volume]]
  data[aber2w == 1, d7vol_beer_ch := d7vol_beer_ch + aber2qsm * alc_volume_data[beverage == "nbeerscanvol", volume]]

  data[ , `:=`(aber2qpt = NULL, aber2qlg = NULL, aber2qsm = NULL, aber2w = NULL)]


  # Wine

  data[ , d7vol_wine_ch := 0]

  if(year %in% yearset1) {

  data[awinew == 1, d7vol_wine_ch := awineqgs * alc_volume_data[beverage == "winesglassvol", volume]]

  data[ , `:=`(awineqgs = NULL, awinew = NULL)]

  }

  if(year %in% yearset2) {

    data[awinew == 1, d7vol_wine_ch := aw125ml * alc_volume_data[beverage == "winesglassvol", volume]]
    data[awinew == 1, d7vol_wine_ch := d7vol_wine_ch + aw175ml * alc_volume_data[beverage == "wineglassvol", volume]]
    data[awinew == 1, d7vol_wine_ch := d7vol_wine_ch + aw250ml * alc_volume_data[beverage == "winelglassvol", volume]]
    data[awinew == 1, d7vol_wine_ch := d7vol_wine_ch + awbtl * alc_volume_data[beverage == "winebtlvol", volume]]

    data[ , `:=`(aw125ml = NULL, aw175ml = NULL, aw250ml = NULL, awbtl = NULL, awinew = NULL)]

  }

  # Fortified wine (Sherry)

  data[ , d7vol_sherry_ch := 0]
  data[asherw == 1, d7vol_sherry_ch := asherqgs * alc_volume_data[beverage == "sherryvol", volume]]

  data[ , `:=`(asherqgs = NULL, asherw = NULL)]


  # Spirits

  data[ , d7vol_spirits_ch := 0]
  data[aspirw == 1, d7vol_spirits_ch := aspirqgs * alc_volume_data[beverage == "spiritsvol", volume]]

  data[ , `:=`(aspirqgs = NULL, aspirw = NULL)]


  # RTDs (alcopops)

  data[ , d7vol_pops_ch := 0]
  data[apopsw == 1, d7vol_pops_ch := apopsqsm * alc_volume_data[beverage == "popsscvol", volume]]

  if("apopsqlg" %in% colnames(data)) {

    data[apopsw == 1, d7vol_pops_ch := d7vol_pops_ch + apopsqlg * alc_volume_data[beverage == "popslbvol", volume]]

    data[ , `:=`(apopsqlg = NULL)]

  }

  data[ , `:=`(apopsqsm = NULL, apopsw = NULL)]


  #################################################################
  # Convert natural volumes into units

  # divide by 1000 because
  # first divide by 100 to convert % abv into a proportion
  # then divide by 10 because 1 UK standard unit of alcohol is defined as 10ml of pure ethanol

  data[ , beer_units7_ch := d7vol_beer_ch * abv_data[beverage == "nbeerabv", abv] / 1000]
  data[ , wine_units7_ch := d7vol_wine_ch * abv_data[beverage == "wineabv", abv] / 1000]
  data[ , sherry_units7_ch := d7vol_sherry_ch * abv_data[beverage == "sherryabv", abv] / 1000]
  data[ , spirits_units7_ch := d7vol_spirits_ch * abv_data[beverage == "spiritsabv", abv] / 1000]
  data[ , pops_units7_ch := d7vol_pops_ch * abv_data[beverage == "popsabv", abv] / 1000]

  data[ , `:=`(d7vol_beer_ch = NULL, d7vol_wine_ch = NULL, d7vol_sherry_ch = NULL, d7vol_spirits_ch = NULL, d7vol_pops_ch = NULL)]

  # Combine wine and sherry units
  data[ , wine_units7_ch := wine_units7_ch + sherry_units7_ch]
  data[ , sherry_units7_ch := NULL]

  #################################################################
  # Generate total consumption

  data[is.na(beer_units7_ch) | beer_units7_ch < 0, beer_units7_ch := 0]
  data[is.na(wine_units7_ch) | wine_units7_ch < 0, wine_units7_ch := 0]
  data[is.na(spirits_units7_ch) | spirits_units7_ch < 0, spirits_units7_ch := 0]
  data[is.na(pops_units7_ch) | pops_units7_ch < 0, pops_units7_ch := 0]

  data[ , total_units7_ch := beer_units7_ch + wine_units7_ch + spirits_units7_ch + pops_units7_ch]

  data[total_units7_ch > 0, drinks_now := "drinker"]


return(data)
}

