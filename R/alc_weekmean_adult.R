

#' Alcohol average weekly consumption (adults)
#'
#' We estimate the number of
#' UK standard units of alcohol drunk on average in a week from the questions on drinking in the last 12 months.
#'
#' The calculation has the following steps:
#' \itemize{
#' \item Convert the categorical variables to numeric variables for the frequency with which each beverage is typically consumed (normal beer, strong beer, spirits, sherry, wine, alcopops).
#' \item Convert the reported volumes usually consumed (e.g. small glass, large glass) into volumes in ml, using the beverage size assumptions above. In doing so, variations in recording among years and between the interview and self-complete questionnaire are accounted for.
#' \item Combine the volumes (ml) usually consumed with the frequency of consumption to give the average volume of each beverage type drunk each week (assuming constant consumption across the year).
#' \item Convert the expected volumes of each beverage consumed each week to UK standard units of alcohol consumed, using the alcohol content assumptions above.
#' \item Collapse normal and strong beer into a single "beer" variable by summing their units. Collapse wine and sherry into a single "wine" variable by summing their units.
#' \item Calculate total weekly units but summing across beverage categories.
#' \item Calculate the beverage "preference vector" - the percentage of total consumption contributed by the consumption of each of four beverage types (beer, wine, spirits, alcopops).
#' \item Cap the total units consumed in a week at 300 units, assuming that above this already very high level of consumption estimates of variation in consumption are less reliable.
#' \item Categorise average weekly consumption into "abstainer", "lower_risk" (less than 14 units/week), "increasing_risk" (greater than or equal to 14 units/week and less than 35 units/week for women, and less than 50 units/week for men), "higher_risk".
#' \item Categorise beverage preferences - for each of the four beverages, "does_not_drink", "drinks_some" (less than or equal to 50\% of consumption), "mostly_drinks".
#' }
#' In 2007 new questions were added asking which glass size was used when wine was consumed.
#' Therefore the post HSE 2007 unit calculations are not directly comparable to previous years’ data.
#'
#' @param data Data table - the Health Survey for England dataset
#' @param abv_data Data table - our assumptions on the alcohol content of different beverages in (percent units / ml)
#' @param volume_data Data table - our assumptions on the volume of different drinks (ml).
#' @param year - the year of data being processed
#'
#' @return
#' \itemize{
#' \item beer_units - average weekly units of beer
#' \item wine_units - average weekly units of wine
#' \item spirit_units - average weekly units of spirits
#' \item rtd_units - average weekly units of alcopops
#' \item weekmean - total average weekly units
#' \item perc_spirit_units - proportion of consumption that is spirits
#' \item perc_wine_units - proportion of consumption that is wine
#' \item perc_rtd_units - proportion of consumption that is alcopops
#' \item perc_beer_units - proportion of consumption that is beer
#' \item drinker_cat - categories of average weekly consumption
#' \item spirits_pref_cat - whether doesn't drink, drinks some or mostly drinks spirits
#' \item wine_pref_cat - whether doesn't drink, drinks some or mostly drinks wine
#' \item rtd_pref_cat - whether doesn't drink, drinks some or mostly drinks alcopops
#' \item beer_pref_cat - whether doesn't drink, drinks some or mostly drinks beer
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2016()
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- alc_drink_now(data)
#' data <- alc_sevenday(data)
#' data <- alc_weekmean(data)
#'
#' }
#'
alc_weekmean_adult <- function(
  data,
  abv_data = hseclean::abv_data,
  volume_data = hseclean::alc_volume_data,
  year
) {

  year_set1 <- 2001:2002
  year_set2 <- 2011:2016


  #################################################################
  # Frequency of drinking in days per week

  if(year %in% c(year_set1, year_set2)) {

    data[ , nbeer := hseclean::alc_drink_freq(nbeer)] # normal beer
    data[ , sbeer := hseclean::alc_drink_freq(sbeer)] # strong beer
    data[ , spirits := hseclean::alc_drink_freq(spirits)] # spirits
    data[ , sherry := hseclean::alc_drink_freq(sherry)] # sherry
    data[ , wine := hseclean::alc_drink_freq(wine)] # wine
    data[ , pops := hseclean::alc_drink_freq(pops)] # alcopops

  }

  if(year %in% year_set2) {

    setnames(data, "scspirit", "scspirits")

    data[ , scnbeer := hseclean::alc_drink_freq(scnbeer)] # normal beer
    data[ , scsbeer := hseclean::alc_drink_freq(scsbeer)] # strong beer
    data[ , scspirits := hseclean::alc_drink_freq(scspirits)] # spirits
    data[ , scsherry := hseclean::alc_drink_freq(scsherry)] # sherry
    data[ , scwine := hseclean::alc_drink_freq(scwine)] # wine
    data[ , scpops := hseclean::alc_drink_freq(scpops)] # alcopops

  }

  #################################################################
  # Amount usually drunk

  # Convert volumes to natural volumes

  # Normal beer

  if(year %in% c(year_set1, year_set2)) {

    data[ , vol_nbeer := 0]
    data[nbeerm1 == 1 & !is.na(nbeerq1) & nbeerq1 > 0, vol_nbeer := nbeerq1 * volume_data[beverage == "nbeerhalfvol", volume]]
    data[nbeerm2 == 1 & !is.na(nbeerq2) & nbeerq2 > 0, vol_nbeer := vol_nbeer + nbeerq2 * volume_data[beverage == "nbeerscanvol", volume]]
    data[nbeerm3 == 1 & !is.na(nbeerq3) & nbeerq3 > 0, vol_nbeer := vol_nbeer + nbeerq3 * volume_data[beverage == "nbeerlcanvol", volume]]
    data[nbeerm4 == 1 & !is.na(nbeerq4) & nbeerq4 > 0, vol_nbeer := vol_nbeer + nbeerq4 * volume_data[beverage == "nbeerbtlvol", volume]]

    data[nbeerm1 == 1 & nbeerq1 == -8, vol_nbeer := NA]
    data[nbeerm2 == 1 & nbeerq2 == -8, vol_nbeer := NA]
    data[nbeerm3 == 1 & nbeerq3 == -8, vol_nbeer := NA]
    data[nbeerm4 == 1 & nbeerq4 == -8, vol_nbeer := NA]

    data[ , `:=` (nbeerm1 = NULL, nbeerm2 = NULL, nbeerm3 = NULL, nbeerm4 = NULL, nbeerq1 = NULL, nbeerq2 = NULL, nbeerq3 = NULL, nbeerq4 = NULL)]

  }

  if(year %in% year_set1) {

    data[!is.na(nbeerq5) & nbeerq5 > 0, vol_nbeer := vol_nbeer + nbeerq5 * 2 * volume_data[beverage == "nbeerhalfvol", volume]]

    data[nbeerq5 == -8, vol_nbeer := NA]

    data[ , nbeerq5 := NULL]

  }

  # Strong beer

  if(year %in% c(year_set1, year_set2)) {

    data[ , vol_sbeer := 0]
    data[sbeerm1 == 1 & !is.na(sbeerq1) & sbeerq1 > 0, vol_sbeer := sbeerq1 * volume_data[beverage == "sbeerhalfvol", volume]]
    data[sbeerm2 == 1 & !is.na(sbeerq2) & sbeerq2 > 0, vol_sbeer := vol_sbeer + sbeerq2 * volume_data[beverage == "sbeerscanvol", volume]]
    data[sbeerm3 == 1 & !is.na(sbeerq3) & sbeerq3 > 0, vol_sbeer := vol_sbeer + sbeerq3 * volume_data[beverage == "sbeerlcanvol", volume]]
    data[sbeerm4 == 1 & !is.na(sbeerq4) & sbeerq4 > 0, vol_sbeer := vol_sbeer + sbeerq4 * volume_data[beverage == "sbeerbtlvol", volume]]

    data[sbeerm1 == 1 & sbeerq1 == -8, vol_sbeer := NA]
    data[sbeerm2 == 1 & sbeerq2 == -8, vol_sbeer := NA]
    data[sbeerm3 == 1 & sbeerq3 == -8, vol_sbeer := NA]
    data[sbeerm4 == 1 & sbeerq4 == -8, vol_sbeer := NA]

    data[ , `:=` (sbeerm1 = NULL, sbeerm2 = NULL, sbeerm3 = NULL, sbeerm4 = NULL, sbeerq1 = NULL, sbeerq2 = NULL, sbeerq3 = NULL, sbeerq4 = NULL)]

  }

  if(year %in% year_set1) {

    data[!is.na(sbeerq5) & sbeerq5 > 0, vol_sbeer := vol_sbeer + sbeerq5 * 2 * volume_data[beverage == "sbeerhalfvol", volume]]

    data[sbeerq5 == -8, vol_sbeer := NA]

    data[ , sbeerq5 := NULL]

  }

  # Wine

  # If variables are not present, create them with NA so code works

  # For years 2001-2006, assume wine measured in number of 125ml glasses
  if(year %in% year_set1) {

    data[ , vol_wine := 0]

    data[!is.na(wineqgs) & wineqgs > 0, vol_wine := wineqgs * alc_volume_data[beverage == "winesglassvol", volume]]

    data[wineqgs == -8, vol_wine := NA]

    #data[ , wineqgs := NULL]

  }

  if(year %in% year_set2) {

    data[ , vol_wine := 0]
    data[bwineq2 == 1 & !is.na(wineq) & wineq > 0, vol_wine := wineq * volume_data[beverage == "winesglassvol", volume]]
    data[bwineq2 == 2 & !is.na(wineq) & wineq > 0, vol_wine := vol_wine + wineq * volume_data[beverage == "wineglassvol", volume]]
    data[bwineq2 == 3 & !is.na(wineq) & wineq > 0, vol_wine := vol_wine + wineq * volume_data[beverage == "winelglassvol", volume]]
    data[bwineq2 == 4 & !is.na(wineq) & wineq > 0, vol_wine := vol_wine + wineq * volume_data[beverage == "winebtlvol", volume]]

    data[wineq == -8, vol_wine := NA]

    #data[ , `:=` (bwineq2 = NULL, wineq = NULL)]
  }


  # Fortified wine (Sherry)

  if(year %in% c(year_set1, year_set2)) {

    data[ , vol_sherry := 0]

    data[!is.na(sherryq) & sherryq > 0, vol_sherry := sherryq * volume_data[beverage == "sherryvol", volume]]

    data[sherryq == -8, vol_sherry := NA]

    #data[ , sherryq := NULL]

  }

  # Spirits

  if(year %in% c(year_set1, year_set2)) {

    data[ , vol_spirits := 0]

    data[!is.na(spiritsq) & spiritsq > 0, vol_spirits := spiritsq * volume_data[beverage == "spiritsvol", volume]]

    data[spiritsq == -8, vol_spirits := NA]

    data[ , spiritsq := NULL]

  }

  # RTDs

  if(year %in% year_set1) {

    data[ , vol_pops := 0]

    data[!is.na(popsqsm) & popsqsm > 0, vol_pops := popsqsm * alc_volume_data[beverage == "popsscvol", volume]]

    data[popsqsm == -8, vol_pops := NA]

    data[ , popsqsm := NULL]

  }

  if(year %in% year_set2) {

    data[ , vol_pops := 0]
    data[popsly11 == 1 & !is.na(popsq111) & popsq111 > 0, vol_pops := popsq111 * volume_data[beverage == "popsscvol", volume]]
    data[popsly12 == 1 & !is.na(popsq112) & popsq112 > 0, vol_pops := vol_pops + popsq112 * volume_data[beverage == "popssbvol", volume]]
    data[popsly13 == 1 & !is.na(popsq113) & popsq113 > 0, vol_pops := vol_pops + popsq113 * volume_data[beverage == "popslbvol", volume]]

    data[popsly11 == 1 & popsq111 == -8, vol_pops := NA]
    data[popsly12 == 1 & popsq112 == -8, vol_pops := NA]
    data[popsly13 == 1 & popsq113 == -8, vol_pops := NA]

    data[ , `:=` (popsly11 = NULL, popsly12 = NULL, popsly13 = NULL, popsq111 = NULL, popsq112 = NULL, popsq113 = NULL)]

  }

  ##
  # Repeat with self-complete questions

  if(year %in% year_set2) {

    # Normal beer
    data[ , vol_scnbeer := 0]
    data[!is.na(scnbeeq1) & scnbeeq1 > 0, vol_scnbeer := scnbeeq1 * volume_data[beverage == "nbeerhalfvol", volume] * 2]
    data[!is.na(scnbeeq2) & scnbeeq2 > 0, vol_scnbeer := vol_scnbeer + scnbeeq2 * volume_data[beverage == "nbeerscanvol", volume]]
    data[!is.na(scnbeeq3) & scnbeeq3 > 0, vol_scnbeer := vol_scnbeer + scnbeeq3 * volume_data[beverage == "nbeerlcanvol", volume]]

    data[scnbeeq1 == -8, vol_scnbeer := NA]
    data[scnbeeq2 == -8, vol_scnbeer := NA]
    data[scnbeeq3 == -8, vol_scnbeer := NA]

    data[ , `:=` (scnbeeq1 = NULL, scnbeeq2 = NULL, scnbeeq3 = NULL)]


    # Strong beer
    data[ , vol_scsbeer := 0]
    data[!is.na(scsbeeq1) & scsbeeq1 > 0, vol_scsbeer := scsbeeq1 * volume_data[beverage == "sbeerhalfvol", volume] * 2]
    data[!is.na(scsbeeq2) & scsbeeq2 > 0, vol_scsbeer := vol_scsbeer + scsbeeq2 * volume_data[beverage == "sbeerscanvol", volume]]
    data[!is.na(scsbeeq3) & scsbeeq3 > 0, vol_scsbeer := vol_scsbeer + scsbeeq3 * volume_data[beverage == "sbeerlcanvol", volume]]

    data[scsbeeq1 == -8, vol_scsbeer := NA]
    data[scsbeeq2 == -8, vol_scsbeer := NA]
    data[scsbeeq3 == -8, vol_scsbeer := NA]

    data[ , `:=` (scsbeeq1 = NULL, scsbeeq2 = NULL, scsbeeq3 = NULL)]


    # Wine
    data[ , vol_scwine := 0]
    data[!is.na(scwineq1) & scwineq1 > 0, vol_scwine := scwineq1 * volume_data[beverage == "winesglassvol", volume]]
    data[!is.na(scwineq2) & scwineq2 > 0, vol_scwine := vol_scwine + scwineq2 * volume_data[beverage == "wineglassvol", volume]]
    data[!is.na(scwineq3) & scwineq3 > 0, vol_scwine := vol_scwine + scwineq3 * volume_data[beverage == "winelglassvol", volume]]
    data[!is.na(scwineq4) & scwineq4 > 0, vol_scwine := vol_scwine + scwineq4 * volume_data[beverage == "winebtlvol", volume]]

    data[scwineq1 == -8, vol_scwine := NA]
    data[scwineq2 == -8, vol_scwine := NA]
    data[scwineq3 == -8, vol_scwine := NA]
    data[scwineq4 == -8, vol_scwine := NA]

    #data[ , `:=` (scwineq1 = NULL, scwineq2 = NULL, scwineq3 = NULL, scwineq4 = NULL)]


    # Fortified wine (Sherry)
    data[ , vol_scsherry := 0]
    data[!is.na(scsherrq) & scsherrq > 0, vol_scsherry := scsherrq * volume_data[beverage == "sherryvol", volume]]

    data[scsherrq == -8, vol_scsherry := NA]

    #data[ , scsherrq := NULL]


    # Spirits
    data[ , vol_scspirits := 0]
    data[!is.na(scspirq) & scspirq > 0, vol_scspirits := scspirq * volume_data[beverage == "spiritsvol", volume]]

    data[scspirq == -8, vol_scspirits := NA]

    data[ , scspirq := NULL]


    # RTDs
    data[ , vol_scpops := 0]
    data[!is.na(scpopsq1) & scpopsq1 > 0, vol_scpops := scpopsq1 * volume_data[beverage == "popslbvol", volume]]
    data[!is.na(scpopsq2) & scpopsq2 > 0, vol_scpops := vol_scpops + scpopsq2 * volume_data[beverage == "popssbvol", volume]]
    data[!is.na(scpopsq3) & scpopsq3 > 0, vol_scpops := vol_scpops + scpopsq3 * volume_data[beverage == "popsscvol", volume]]

    data[scpopsq1 == -8, vol_scpops := NA]
    data[scpopsq2 == -8, vol_scpops := NA]
    data[scpopsq3 == -8, vol_scpops := NA]

    data[ , `:=`(scpopsq1 = NULL, scpopsq2 = NULL, scpopsq3 = NULL)]

  }

  #################################################################
  # Combine amount usually drunk with frequencies to get natural volumes per week

  if(year %in% c(year_set1, year_set2)) {

    data[ , vol_nbeer := vol_nbeer * nbeer]
    data[ , vol_sbeer := vol_sbeer * sbeer]
    data[ , vol_spirits := vol_spirits * spirits]
    data[ , vol_sherry := vol_sherry * sherry]
    data[ , vol_wine := vol_wine * wine]
    data[ , vol_pops := vol_pops * pops]

    #data[ , `:=`(nbeer = NULL, sbeer = NULL, spirits = NULL, sherry = NULL, wine = NULL, pops = NULL)]

  }

  if(year %in% c(year_set2)) {

    data[ , vol_scnbeer := vol_scnbeer * scnbeer]
    data[ , vol_scsbeer := vol_scsbeer * scsbeer]
    data[ , vol_scspirits := vol_scspirits * scspirits]
    data[ , vol_scsherry := vol_scsherry * scsherry]
    data[ , vol_scwine := vol_scwine * scwine]
    data[ , vol_scpops := vol_scpops * scpops]


    #data[ , `:=`(scnbeer = NULL, scsbeer = NULL, scspirits = NULL, scsherry = NULL, scwine = NULL, scpops = NULL)]


    #################################################################
    # Merge interview data with self complete data

    data[is.na(vol_nbeer) | vol_nbeer == 0, vol_nbeer := vol_scnbeer]
    data[is.na(vol_sbeer) | vol_sbeer == 0, vol_sbeer := vol_scsbeer]
    data[is.na(vol_spirits) | vol_spirits == 0, vol_spirits := vol_scspirits]
    data[is.na(vol_sherry) | vol_sherry == 0, vol_sherry := vol_scsherry]
    data[is.na(vol_wine) | vol_wine == 0, vol_wine := vol_scwine]
    data[is.na(vol_pops) | vol_pops == 0, vol_pops := vol_scpops]

    #data[ , `:=`(vol_scnbeer = NULL, vol_scsbeer = NULL, vol_scspirits = NULL, vol_scsherry = NULL, vol_scwine = NULL, vol_scpops = NULL)]

  }

  #################################################################
  # Convert natural volumes (ml of beverage) into units

  if(year %in% c(year_set1, year_set2)) {

    # divide by 1000 because
    # first divide by 100 to convert % abv into a proportion
    # then divide by 10 because 1 UK standard unit of alcohol is defined as 10ml of pure ethanol

    data[ , nbeer_units := vol_nbeer * abv_data[beverage == "nbeerabv", abv] / 1000]
    data[ , sbeer_units := vol_sbeer * abv_data[beverage == "sbeerabv", abv] / 1000]
    data[ , spirits_units := vol_spirits * abv_data[beverage == "spiritsabv", abv] / 1000]
    data[ , sherry_units := vol_sherry * abv_data[beverage == "sherryabv", abv] / 1000]
    data[ , wine_units := vol_wine * abv_data[beverage == "wineabv", abv] / 1000]
    data[ , pops_units := vol_pops * abv_data[beverage == "popsabv", abv] / 1000]

    #data[ , `:=`(vol_nbeer = NULL, vol_sbeer = NULL, vol_spirits = NULL, vol_sherry = NULL, vol_wine = NULL, vol_pops = NULL)]


    #################################################################
    # Condense into 4 beverage categories

    data[ , beer_units := nbeer_units + sbeer_units]
    data[ , wine_units := wine_units + sherry_units]

    #data[ , `:=`(nbeer_units = NULL, sbeer_units = NULL, sherry_units = NULL)]

    setnames(data, c("spirits_units", "pops_units"), c("spirit_units", "rtd_units"))


    #################################################################
    # Generate weekly total units

    data[ , weekmean := spirit_units + wine_units + rtd_units + beer_units]

    data[weekmean == 0, drinks_now := "non_drinker"]
    data[weekmean > 0, drinks_now := "drinker"]

    # generate preference vector
    data[ , perc_spirit_units := 100 * spirit_units / weekmean]
    data[ , perc_wine_units := 100 * wine_units / weekmean]
    data[ , perc_rtd_units := 100 * rtd_units / weekmean]
    data[ , perc_beer_units := 100 * beer_units / weekmean]

    data[is.na(perc_spirit_units), perc_spirit_units := 0]
    data[is.na(perc_wine_units), perc_wine_units := 0]
    data[is.na(perc_rtd_units), perc_rtd_units := 0]
    data[is.na(perc_beer_units), perc_beer_units := 0]

    # Cap consumption at 300 units
    data[weekmean > 300, weekmean := 300]


    #################################################################
    # Categorise total units per week

    data[ , drinker_cat := NA_character_]
    data[weekmean == 0, drinker_cat := "abstainer"]
    data[weekmean > 0 & weekmean < 14, drinker_cat := "lower_risk"]
    data[weekmean > 0 & weekmean >= 14 & weekmean < 35 & sex == "Female", drinker_cat := "increasing_risk"]
    data[weekmean > 0 & weekmean >= 14 & weekmean < 50 & sex == "Male", drinker_cat := "increasing_risk"]
    data[weekmean > 0 & weekmean >= 35 & sex == "Female", drinker_cat := "higher_risk"]
    data[weekmean > 0 & weekmean >= 50 & sex == "Male", drinker_cat := "higher_risk"]


    #################################################################
    # Categorise beverage preferences

    data[perc_spirit_units == 0, spirits_pref_cat := "does_not_drink_spirits"]
    data[perc_spirit_units > 0 & perc_spirit_units <= .5, spirits_pref_cat := "drinks_some_spirits"]
    data[perc_spirit_units > .5, spirits_pref_cat := "mostly_drinks_spirits"]

    data[perc_wine_units == 0, wine_pref_cat := "does_not_drink_wine"]
    data[perc_wine_units > 0 & perc_wine_units <= .5, wine_pref_cat := "drinks_some_wine"]
    data[perc_wine_units > .5, wine_pref_cat := "mostly_drinks_wine"]

    data[perc_rtd_units == 0, rtd_pref_cat := "does_not_drink_rtds"]
    data[perc_rtd_units > 0 & perc_rtd_units <= .5, rtd_pref_cat := "drinks_some_rtds"]
    data[perc_rtd_units > .5, rtd_pref_cat := "mostly_drinks_rtds"]

    data[perc_beer_units == 0, beer_pref_cat := "does_not_drink_beer"]
    data[perc_beer_units > 0 & perc_beer_units <= .5, beer_pref_cat := "drinks_some_beer"]
    data[perc_beer_units > .5, beer_pref_cat := "mostly_drinks_beer"]

  }

return(data)
}

