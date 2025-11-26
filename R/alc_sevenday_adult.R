#' Alcohol consumption in last seven-days (adults)
#'
#' Processes the information from the questions on drinking in the last seven days - how many times drank and characteristics of the heaviest drinking day.
#'
#' We estimate the number of
#' UK standard units of alcohol drunk on the heaviest drinking day by using the data on how many of what size measures of
#' different beverages were drunk, and combining this with our standard assumptions about beverage volume and alcohol content.
#'
#' In 2007 new questions were added asking which glass size was used when wine was consumed.
#' Therefore the post HSE 2007 unit calculations are not directly comparable to previous years' data.
#'
#' In HSE 2022, cider was split into normal (<6% ABV) and strong (>=6% ABV) cider for the first time.
#' The d7typ variable mapping also changed in 2022:
#' - Pre-2022: d7typ3=spirits, d7typ4=sherry, d7typ5=wine, d7typ6=rtds
#' - HSE 2022+: d7typ3=ncider, d7typ4=scider, d7typ5=spirits, d7typ6=sherry, d7typ7=wine, d7typ8=rtds
#'
#' @param data Data table - the health survey dataset
#' @param abv_data Data table - our assumptions on the alcohol content of different beverages in (percent units / ml)
#' @param alc_volume_data Data table - our assumptions on the volume of different drinks (ml).
#'
#' @importFrom data.table :=
#'
#' @return
#' \itemize{
#' \item n_days_drink - number of days drank in last 7.
#' \item peakday - total units on heaviest drinking day
#' \item d7nbeer_units
#' \item d7sbeer_units
#' \item d7ncider_units (HSE 2022+ only)
#' \item d7scider_units (HSE 2022+ only)
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
#' \dontrun{
#'
#' library(hseclean)
#'
#' data <- read_2017(root = "/Volumes/Shared/")
#' data <- clean_age(data)
#' data <- clean_demographic(data)
#' data <- alc_drink_now_allages(data)
#' data <- alc_sevenday_adult(data)
#' }
#'
alc_sevenday_adult <- function(
  data,
  abv_data = hseclean::abv_data,
  alc_volume_data = hseclean::alc_volume_data
) {
  # Check that drinks_now variable is in the data
  if (sum(colnames(data) == "drinks_now") == 0) {
    message("missing drinks_now variable - run alc_drink_now_allages() first.")
  }

  country <- unique(data[, country][1])
  year <- as.integer(unique(data[, year][1]))


  # Auto-detect and load HSE 2022 ABV data if needed
  if (year == 2022 & country == "England") {
    tryCatch(
      {
        if ("abv_data_2022" %in% getNamespaceExports("hseclean")) {
          abv_data <- hseclean::abv_data_2022
          message("Auto-detected HSE 2022: Using 2022-specific ABV values for 7-day recall...")
        } else if (exists("abv_data_2022", envir = .GlobalEnv)) {
          abv_data <- get("abv_data_2022", envir = .GlobalEnv)
          message("Auto-detected HSE 2022: Using 2022-specific ABV values from global environment...")
        } else {
          message("HSE 2022 detected but abv_data_2022 not found. Using default ABV values.")
        }
      },
      error = function(e) {
        message("Error loading 2022 ABV data: ", e$message, ". Using default ABV values.")
      }
    )
  }


  # Detect HSE 2022+ by presence of cider split (d7typ3 = ncider indicator)
  is_hse_2022 <- "d7typ3" %in% names(data) && year >= 2022


  ### No binge data in NSW post 2019-20
  if (!(country == "Wales" & year > 2019)) {
    if (country == "Wales") {
      data[drinks_now != "non_drinker" & !(d7many %in% 1:7), d7day := 2]
      data[drinks_now == "non_drinker", d7day := 2]
      data[d7many %in% 1:7, d7day := 1]
    }

    #################################################################
    # Adults - Number of days drank in last 7

    # Did you have an alcoholic drink in the seven days ending yesterday?
    data[age >= 16 & d7day == 2, n_days_drink := 0]

    # On how many days out of the last seven did you have an alcoholic drink?

    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values (there is quite a lot of missingness in this variable)
    data[drinks_now == "non_drinker", d7many := 0]


    # data <- hseclean::impute_mean(data, "d7many", remove_zeros = T)
    # data[is.na(drinks_now), d7many := NA]


    data[age >= 16 & d7day == 1, n_days_drink := d7many]

    data[, `:=`(d7day = NULL, d7many = NULL)]

    #################################################################
    # Adults - Consumption on heaviest drinking day in past 7 days

    # Normal beer
    # SHeS 2010 does not have nberqbt7
    if (!("nberqbt7" %in% colnames(data))) {
      data[, nberqbt7 := 0]
    }

    # NSW does not have nberqpt7
    if (!("nberqpt7" %in% colnames(data))) {
      data[, nberqpt7 := 0]
    }

    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values
    data[drinks_now == "non_drinker" & is.na(nberqhp7), `:=`(nberqhp7 = 0)]
    data[drinks_now == "non_drinker" & is.na(nberqsm7), `:=`(nberqsm7 = 0)]
    data[drinks_now == "non_drinker" & is.na(nberqlg7), `:=`(nberqlg7 = 0)]
    data[drinks_now == "non_drinker" & is.na(nberqbt7), `:=`(nberqbt7 = 0)]
    data[drinks_now == "non_drinker" & is.na(nberqpt7), `:=`(nberqpt7 = 0)]


    # data <- hseclean::impute_mean(data, c("nberqhp7", "nberqsm7", "nberqlg7", "nberqbt7", "nberqpt7"))


    data[, d7vol_nbeer := 0]
    data[d7typ1 == 1, d7vol_nbeer := nberqhp7 * alc_volume_data[beverage == "nbeerhalfvol", volume]]
    data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqsm7 * alc_volume_data[beverage == "nbeerscanvol", volume]]
    data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqlg7 * alc_volume_data[beverage == "nbeerlcanvol", volume]]
    data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqbt7 * alc_volume_data[beverage == "nbeerbtlvol", volume]]
    data[d7typ1 == 1, d7vol_nbeer := d7vol_nbeer + nberqpt7 * alc_volume_data[beverage == "nbeerhalfvol", volume] * 2]

    data[, `:=`(nberqhp7 = NULL, nberqsm7 = NULL, nberqlg7 = NULL, nberqbt7 = NULL, nberqpt7 = NULL)]


    # Strong beer
    # SHeS 2010 does not have sberqbt7
    if (!("sberqbt7" %in% colnames(data))) {
      data[, sberqbt7 := 0]
    }
    # NSW does not have nberqpt7
    if (!("sberqpt7" %in% colnames(data))) {
      data[, sberqpt7 := 0]
    }

    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values
    data[drinks_now == "non_drinker" & is.na(sberqhp7), `:=`(sberqhp7 = 0)]
    data[drinks_now == "non_drinker" & is.na(sberqsm7), `:=`(sberqsm7 = 0)]
    data[drinks_now == "non_drinker" & is.na(sberqlg7), `:=`(sberqlg7 = 0)]
    data[drinks_now == "non_drinker" & is.na(sberqbt7), `:=`(sberqbt7 = 0)]
    data[drinks_now == "non_drinker" & is.na(sberqpt7), `:=`(sberqpt7 = 0)]
    # data <- hseclean::impute_mean(data, c("sberqhp7", "sberqsm7", "sberqlg7", "sberqbt7", "sberqpt7"))

    data[, d7vol_sbeer := 0]
    data[d7typ2 == 1, d7vol_sbeer := sberqhp7 * alc_volume_data[beverage == "sbeerhalfvol", volume]]
    data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqsm7 * alc_volume_data[beverage == "sbeerscanvol", volume]]
    data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqlg7 * alc_volume_data[beverage == "sbeerlcanvol", volume]]
    data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqbt7 * alc_volume_data[beverage == "sbeerbtlvol", volume]]
    data[d7typ2 == 1, d7vol_sbeer := d7vol_sbeer + sberqpt7 * alc_volume_data[beverage == "sbeerhalfvol", volume] * 2]

    data[, `:=`(sberqhp7 = NULL, sberqsm7 = NULL, sberqlg7 = NULL, sberqbt7 = NULL, sberqpt7 = NULL)]


    # Normal Cider (HSE 2022+ only)
    if (is_hse_2022) {
      # Variables: ncidqpt7 (pints), ncidsca7 (small cans), ncidlca7 (large cans), ncidbot7 (bottles)


      # Create variables if they don't exist
      if (!("ncidqpt7" %in% colnames(data))) data[, ncidqpt7 := 0]
      if (!("ncidsca7" %in% colnames(data))) data[, ncidsca7 := 0]
      if (!("ncidlca7" %in% colnames(data))) data[, ncidlca7 := 0]
      if (!("ncidbot7" %in% colnames(data))) data[, ncidbot7 := 0]


      # Set to zero for non-drinkers
      data[drinks_now == "non_drinker" & is.na(ncidqpt7), `:=`(ncidqpt7 = 0)]
      data[drinks_now == "non_drinker" & is.na(ncidsca7), `:=`(ncidsca7 = 0)]
      data[drinks_now == "non_drinker" & is.na(ncidlca7), `:=`(ncidlca7 = 0)]
      data[drinks_now == "non_drinker" & is.na(ncidbot7), `:=`(ncidbot7 = 0)]


      data[, d7vol_ncider := 0]
      data[d7typ3 == 1, d7vol_ncider := ncidqpt7 * alc_volume_data[beverage == "nciderpintvol", volume]]
      data[d7typ3 == 1, d7vol_ncider := d7vol_ncider + ncidsca7 * alc_volume_data[beverage == "nciderscanvol", volume]]
      data[d7typ3 == 1, d7vol_ncider := d7vol_ncider + ncidlca7 * alc_volume_data[beverage == "nciderlcanvol", volume]]
      data[d7typ3 == 1, d7vol_ncider := d7vol_ncider + ncidbot7 * alc_volume_data[beverage == "nciderbtlvol", volume]]


      data[, `:=`(ncidqpt7 = NULL, ncidsca7 = NULL, ncidlca7 = NULL, ncidbot7 = NULL)]
    }


    # Strong Cider (HSE 2022+ only)
    if (is_hse_2022) {
      # Variables: scidqpt7 (pints), scidsca7 (small cans), scidlca7 (large cans), scidbot7 (bottles)


      # Create variables if they don't exist
      if (!("scidqpt7" %in% colnames(data))) data[, scidqpt7 := 0]
      if (!("scidsca7" %in% colnames(data))) data[, scidsca7 := 0]
      if (!("scidlca7" %in% colnames(data))) data[, scidlca7 := 0]
      if (!("scidbot7" %in% colnames(data))) data[, scidbot7 := 0]


      # Set to zero for non-drinkers
      data[drinks_now == "non_drinker" & is.na(scidqpt7), `:=`(scidqpt7 = 0)]
      data[drinks_now == "non_drinker" & is.na(scidsca7), `:=`(scidsca7 = 0)]
      data[drinks_now == "non_drinker" & is.na(scidlca7), `:=`(scidlca7 = 0)]
      data[drinks_now == "non_drinker" & is.na(scidbot7), `:=`(scidbot7 = 0)]


      data[, d7vol_scider := 0]
      data[d7typ4 == 1, d7vol_scider := scidqpt7 * alc_volume_data[beverage == "sciderpintvol", volume]]
      data[d7typ4 == 1, d7vol_scider := d7vol_scider + scidsca7 * alc_volume_data[beverage == "sciderscanvol", volume]]
      data[d7typ4 == 1, d7vol_scider := d7vol_scider + scidlca7 * alc_volume_data[beverage == "sciderlcanvol", volume]]
      data[d7typ4 == 1, d7vol_scider := d7vol_scider + scidbot7 * alc_volume_data[beverage == "sciderbtlvol", volume]]


      data[, `:=`(scidqpt7 = NULL, scidsca7 = NULL, scidlca7 = NULL, scidbot7 = NULL)]
    }


    # Wine

    # If variables are not present, create them with NA so code works

    # For years 2001-2006, wine measured in number of 125ml glasses
    if (!("wineqgs7" %in% colnames(data))) {
      data[, wineqgs7 := 0]
    }

    # In 2007, wineqgs7 was replaced by three sizes of glass
    if (!("wgls250ml" %in% colnames(data))) {
      data[, wgls250ml := 0]
      data[, wgls175ml := 0]
      data[, wgls125ml := 0]
    }

    # In 2008, a further variable was introduced to indicate 125ml glasses inferred from a report of drinking all/part of a bottle
    if (!("wbtlgz" %in% colnames(data))) {
      data[, wbtlgz := 0]
    }

    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values
    data[drinks_now == "non_drinker" & is.na(wineqgs7), `:=`(wineqgs7 = 0)]
    data[drinks_now == "non_drinker" & is.na(wgls250ml), `:=`(wgls250ml = 0)]
    data[drinks_now == "non_drinker" & is.na(wgls175ml), `:=`(wgls175ml = 0)]
    data[drinks_now == "non_drinker" & is.na(wgls125ml), `:=`(wgls125ml = 0)]
    data[drinks_now == "non_drinker" & is.na(wbtlgz), `:=`(wbtlgz = 0)]
    # data <- hseclean::impute_mean(data, c("wineqgs7", "wgls250ml", "wgls175ml", "wgls125ml", "wbtlgz"))

    data[, d7vol_wine := 0]


    # HSE 2022+: d7typ7 = wine; Pre-2022: d7typ5 = wine
    wine_typ <- ifelse(is_hse_2022, 7, 5)


    # 175ml glasses
    data[get(paste0("d7typ", wine_typ)) == 1, d7vol_wine := wineqgs7 * alc_volume_data[beverage == "winesglassvol", volume]]


    # 250ml glasses
    data[get(paste0("d7typ", wine_typ)) == 1, d7vol_wine := wgls250ml * alc_volume_data[beverage == "winelglassvol", volume]]


    # 175ml glasses
    data[get(paste0("d7typ", wine_typ)) == 1, d7vol_wine := d7vol_wine + wgls175ml * alc_volume_data[beverage == "wineglassvol", volume]]


    # 125ml glasses
    data[get(paste0("d7typ", wine_typ)) == 1, d7vol_wine := d7vol_wine + wgls125ml * alc_volume_data[beverage == "winesglassvol", volume]]


    # 125ml glasses
    data[get(paste0("d7typ", wine_typ)) == 1, d7vol_wine := d7vol_wine + wbtlgz * alc_volume_data[beverage == "winesglassvol", volume]]

    data[, `:=`(wineqgs7 = NULL, wbtlgz = NULL, wgls250ml = NULL, wgls175ml = NULL, wgls125ml = NULL)]


    # Fortified wine (Sherry)
    # HSE 2022+: d7typ6 = sherry; Pre-2022: d7typ4 = sherry


    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values
    # data <- hseclean::impute_mean(data, "sherqgs7")


    sherry_typ <- ifelse(is_hse_2022, 6, 4)


    if (country == "England" & year >= 2019) {
      data[drinks_now == "non_drinker" & is.na(shergs7), `:=`(shergs7 = 0)]


      data[, d7vol_sherry := 0]
      data[get(paste0("d7typ", sherry_typ)) == 1, d7vol_sherry := shergs7 * alc_volume_data[beverage == "sherryvol", volume]]


      data[, `:=`(shergs7 = NULL)]
    } else {
      data[drinks_now == "non_drinker" & is.na(sherqgs7), `:=`(sherqgs7 = 0)]


      data[, d7vol_sherry := 0]
      data[get(paste0("d7typ", sherry_typ)) == 1, d7vol_sherry := sherqgs7 * alc_volume_data[beverage == "sherryvol", volume]]


      data[, `:=`(sherqgs7 = NULL)]
    }

    # Spirits
    # HSE 2022+: d7typ5 = spirits; Pre-2022: d7typ3 = spirits


    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values


    spirits_typ <- ifelse(is_hse_2022, 5, 3)


    if (country == "England" & year >= 2019) {
      data[drinks_now == "non_drinker" & is.na(spirme7), `:=`(spirme7 = 0)]
      # data <- hseclean::impute_mean(data, "spirqme7")


      data[, d7vol_spirits := 0]
      data[get(paste0("d7typ", spirits_typ)) == 1, d7vol_spirits := spirme7 * alc_volume_data[beverage == "spiritsvol", volume]]


      data[, `:=`(spirme7 = NULL)]
    } else {
      data[drinks_now == "non_drinker" & is.na(spirqme7), `:=`(spirqme7 = 0)]
      # data <- hseclean::impute_mean(data, "spirqme7")


      data[, d7vol_spirits := 0]
      data[get(paste0("d7typ", spirits_typ)) == 1, d7vol_spirits := spirqme7 * alc_volume_data[beverage == "spiritsvol", volume]]


      data[, `:=`(spirqme7 = NULL)]
    }

    # RTDs (alcopops)

    # For years 2001-2010, the only size measure was small cans/bottles

    # In 2011, a new question on large bottles was introduced
    if (!("popsqlg7" %in% colnames(data))) {
      data[, popsqlg7 := 0]
    }

    # In SHeS, there are two separate measures for small cans and small bottles
    if (!("popsqsmc7" %in% colnames(data))) {
      data[, popsqsmc7 := 0]
    }
    # In SHeS, there are two separate measures for small cans and small bottles
    if (!("popsqsm7" %in% colnames(data))) {
      data[, popsqsm7 := 0]
    }

    # In NSW, there is a "standard bottles" measure
    if (!("popsqstb7" %in% colnames(data))) {
      data[, popsqstb7 := 0]
    }

    # Set this as zero is someone already reports being a non-drinker
    # and for drinkers impute the remaining missing values
    data[drinks_now == "non_drinker" & is.na(popsqsm7), `:=`(popsqsm7 = 0)]
    data[drinks_now == "non_drinker" & is.na(popsqlg7), `:=`(popsqlg7 = 0)]
    data[drinks_now == "non_drinker" & is.na(popsqsmc7), `:=`(popsqsmc7 = 0)]
    # data <- hseclean::impute_mean(data, c("popsqsm7", "popsqlg7", "popsqsmc7"))

    data[, d7vol_pops := 0]


    # HSE 2022+: d7typ8 = rtds; Pre-2022: d7typ6 = rtds
    pops_typ <- ifelse(is_hse_2022, 8, 6)


    # Small cans/bottles
    data[get(paste0("d7typ", pops_typ)) == 1, d7vol_pops := popsqsm7 * alc_volume_data[beverage == "popsscvol", volume]]


    # Small cans in SHeS
    data[get(paste0("d7typ", pops_typ)) == 1, d7vol_pops := d7vol_pops + popsqsmc7 * alc_volume_data[beverage == "popsscvol", volume]]


    # Standard bottles in NSW
    data[get(paste0("d7typ", pops_typ)) == 1, d7vol_pops := d7vol_pops + popsqstb7 * alc_volume_data[beverage == "popssbvol", volume]]


    # Large bottles
    data[get(paste0("d7typ", pops_typ)) == 1, d7vol_pops := d7vol_pops + popsqlg7 * alc_volume_data[beverage == "popslbvol", volume]]

    data[, `:=`(popsqsm7 = NULL, popsqlg7 = NULL, popsqsmc7 = NULL, popsqstb7 = NULL)]


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


    # HSE 2022+: Also calculate cider units
    if (is_hse_2022) {
      data[age >= 16, ncider_units7 := d7vol_ncider * abv_data[beverage == "nciderabv", abv] / 1000]
      data[age >= 16, scider_units7 := d7vol_scider * abv_data[beverage == "sciderabv", abv] / 1000]
    }


    # Remove volume variables
    if (is_hse_2022) {
      data[, `:=`(
        d7vol_nbeer = NULL, d7vol_sbeer = NULL, d7vol_ncider = NULL, d7vol_scider = NULL,
        d7vol_spirits = NULL, d7vol_sherry = NULL, d7vol_wine = NULL, d7vol_pops = NULL
      )]
    } else {
      data[, `:=`(
        d7vol_nbeer = NULL, d7vol_sbeer = NULL, d7vol_spirits = NULL,
        d7vol_sherry = NULL, d7vol_wine = NULL, d7vol_pops = NULL
      )]
    }


    #################################################################
    # Generate peakday consumption


    if (is_hse_2022) {
      # Include cider for HSE 2022+
      data[, peakday := nbeer_units7 + sbeer_units7 + ncider_units7 + scider_units7 +
        spirits_units7 + sherry_units7 + wine_units7 + pops_units7]
    } else {
      # Pre-2022: no separate cider (cider included in beer)
      data[, peakday := nbeer_units7 + sbeer_units7 + spirits_units7 + sherry_units7 + wine_units7 + pops_units7]
    }

    data[n_days_drink == 0, peakday := 0]

    data[n_days_drink > 0 & peakday == 0, peakday := NA]

    data[drinks_now == "non_drinker" & is.na(peakday), peakday := 0]
    data[drinks_now == "non_drinker" & is.na(n_days_drink), n_days_drink := 0]

    # Check to see if anyone is marked as a non-drinker but has peakday > 0
    ncheck <- nrow(data[drinks_now == "non_drinker" & peakday > 0])
    if (ncheck > 0) message(paste0("warning - ", ncheck, " people marked as non-drinkers in drinks_now but have peakday > 0"))

    #################################################################
    # Categorise peak consumption


    data[n_days_drink == 0, binge_cat := "did_not_drink"]


    # Note: sex can be either numeric (1=Male, 2=Female) or character
    data[n_days_drink > 0 & peakday < 8 & (sex == "Male" | sex == 1), binge_cat := "no_binge"]
    data[n_days_drink > 0 & peakday < 6 & (sex == "Female" | sex == 2), binge_cat := "no_binge"]
    data[n_days_drink > 0 & peakday >= 8 & (sex == "Male" | sex == 1), binge_cat := "binge"]
    data[n_days_drink > 0 & peakday >= 6 & (sex == "Female" | sex == 2), binge_cat := "binge"]

    data[drinks_now == "non_drinker" & is.na(binge_cat), binge_cat := "did_not_drink"]


    # Remove variables no longer needed
    remove_vars <- c("drnksame", "whichday", colnames(data)[stringr::str_detect(colnames(data), "d7")])
    data[, (remove_vars) := NULL]
  }
  return(data[])
}
