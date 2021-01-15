
#' Impute missing values of average weekly alcohol consumption \lifecycle{maturing}
#' 
#' Fills the missing values of whether an individual is a drinker,
#' average weekly consumption, and the percentage beverage preferences.
#'
#' Missing values of whether an individual drinks or not are imputed by 
#' taking a random draw from the age, sex, IMD quintile subgroup. Thus, the 
#' frequency of the imputed categorical values approx matches the frequency 
#' of drinking in that subgroup.  
#' 
#' For children 13-15 years old, the missing values in the median amount drunk in the last week are filled with the 
#' average value for each year (this average is not stratified). The average weekly alcohol consumption is then calculated 
#' by scaling the amount drunk in the last week by the frequency of drinking. For adults >= 16 years, 
#' missing values for the average weekly alcohol consumption are filled by the median, 
#' stratified by age category, year, sex and the frequency of drinking.   
#' 
#' Missing values for how drinkers divide their percentage consumption among five beverage types (beer, wine, spirits, RTDs) 
#' are imputed by first fitting a Dirichlet distribution to the distribution of preferences 
#' within an age, sex, IMD quintile subgroup. The missing values for each individual drinker 
#' are then imputed by taking a random draw from the Dirichlet distribution defined by the 
#' estimated Dirichlet parameters for that subgroup. Note that the HSE data 
#' does not contain any beverage preference info for individuals younger than age 16,
#' so we assume that the underlying distribution of beverage preferences for ages 13-15 years is the same 
#' as for the age group 16-24 years.  
#'
#' @param data Data table - the Health Survey for England dataset.
#' 
#' @importFrom data.table := setDT
#' @importFrom stats predict
#' 
#' @return Returns a data table in which the missing values of average weekly consumption have been filled in so that 
#' this variable corresponds to the data on whether an individual is a drinker.
#' 
#' @export
#'
#' @examples
#'
#' \dontrun{
#' 
#' library(hseclean)
#' library(data.table)
#' library(magrittr)
#' 
#' data <- read_2017(root = "/Volumes/Shared/")
#' 
#' data %<>%
#'   clean_age %>%
#'   clean_demographic %>% 
#'   clean_education %>%
#'   clean_economic_status %>%
#'   clean_family %>%
#'   clean_income %>%
#'   clean_health_and_bio %>%
#'   alc_drink_now_allages %>%
#'   alc_weekmean_adult %>%
#'   alc_sevenday_adult %>%
#'   alc_sevenday_child
#' 
#' data <- data[age >= 13, c(
#'   "year", "age", "age_cat", "sex", "imd_quintile", 
#'   "drinks_now", "drink_freq_7d", "total_units7_ch", "weekmean", "drinker_cat",
#'   "perc_spirit_units", "perc_wine_units", "perc_rtd_units", "perc_beer_units")]
#' 
#' data <- alc_impute(data)
#' 
#' }
#'
alc_impute <- function(
  data
) {
  
  #######################
  ## Impute drinks_now
  
  # missing values of drinks_now spread fairly evenly over years
  # missing values primarily in the under 18s, and mostly under 16s
  # missing values evenly distributed by imd_quintile
  
  # note that these are the age categories
  # 13-15 16-17 18-24 25-34 35-44 45-54 55-64 65-74 75-89
  
  data <- hseclean::impute_cat(data, "drinks_now", 
                               strat_vars = c("age_cat", "sex", "year", "imd_quintile"))
  
  testthat::expect_equal(nrow(data[is.na(drinks_now)]), 0, 
                         info = "imputation error: still some missing values in drinks_now")
  
  #######################
  ## Fill any missing values for drinking frequency
  
  # missing values of drink_freq_7d spread fairly evenly over years
  # missing values primarily in the under 18s, and mostly under 16s
  # missing values evenly distributed by imd_quintile
  
  data <- hseclean::impute_mean(data, "drink_freq_7d", 
                                strat_vars = c("age_cat", "sex", "year", "imd_quintile", "drinks_now"))
  
  testthat::expect_equal(nrow(data[is.na(drink_freq_7d)]), 0, 
                         info = "imputation error: still some missing values in drink_freq_7d")
  
  # note: info on drinking frequency or amount drunk by drinkers is 
  # only considered for years >= 2011
  
  data[year < 2011, drink_freq_7d := NA]
  
  #######################
  ## Average amount consumed by drinkers - Children 13-15 years old
  
  # Due to scarcity of data, do not consider variation by year in this variable
  
  # Calculate the median amount drunk by children who are drinkers over the last 7 days
  # removing zeros
  median_7d_amount_ch <- median(
    
    data[year >= 2011 & drinks_now == "drinker" & total_units7_ch > 0 & age >= 13 & age < 16, total_units7_ch]
    
    , na.rm = T)
  
  # replace zero amounts for drinkers younger than 16 with the average value
  data[drinks_now == "drinker" & total_units7_ch == 0 & age >= 13 & age < 16, 
       total_units7_ch := median_7d_amount_ch]
  
  data[year < 2011, total_units7_ch := NA]
  
  testthat::expect_equal(nrow(
    data[drinks_now == "drinker" & age >= 13 & age < 16 & year >= 2011 & is.na(total_units7_ch)]), 0, 
                         info = "imputation error: still some missing values in total_units7_ch")
  
  
  # calculate the amount drunk on an average week in a year using information on quantity and frequency
  data[year >= 2011 & drinks_now == "drinker" & age >= 13 & age < 16, 
       weekmean := (drink_freq_7d * 52 / 7) * total_units7_ch]
  
  testthat::expect_equal(nrow(
    data[drinks_now == "drinker" & age >= 13 & age < 16 & year >= 2011 & is.na(weekmean)]), 0, 
    info = "imputation error: still some missing values in weekmean for under 16s")
  
  #######################
  ## Average amount consumed by drinkers - Adults >= 16 years old
  
  # Fill in the average amount drunk by adults who are drinkers
  
  # Make zeros NAs
  data[year >= 2011 & age >= 16 & drinks_now == "drinker" & weekmean == 0, 
       `:=`(weekmean = NA, drinker_cat = NA)]
  
  # Fill the missing values
  #data <- hseclean::impute_mean(data, var_names = "weekmean", strat_vars = c("year", "sex", "imd_quintile", "age_cat", "drink_freq_7d"), remove_zeros = FALSE)
  
  # Calculate the subroup means
  # note: not stratified by year
  data[year >= 2011, 
       median_weekmean := median(weekmean, na.rm = T), 
       by = c("sex", "age_cat", "imd_quintile")]
  
  # Replace missing with the subgroup median
  data[year >= 2011 & is.na(weekmean), weekmean := median_weekmean]
  
  testthat::expect_equal(nrow(
    data[drinks_now == "drinker" & age >= 16 & year >= 2011 & is.na(weekmean)]), 0, 
    info = "imputation error: still some missing values in weekmean for over 16s")
  
  data[ , median_weekmean := NULL]
  
  data[year >= 2011 & drinks_now == "non_drinker", weekmean := 0]
  
  # Re-categorise total units per week
  data[ , drinker_cat := NA_character_]
  data[year >= 2011 & drinks_now == "non_drinker", 
       drinker_cat := "abstainer"]
  data[year >= 2011 & drinks_now == "drinker" & weekmean < 14, 
       drinker_cat := "lower_risk"]
  data[year >= 2011 & drinks_now == "drinker" & weekmean >= 14 & weekmean < 35 & sex == "Female", 
       drinker_cat := "increasing_risk"]
  data[year >= 2011 & drinks_now == "drinker" & weekmean >= 14 & weekmean < 50 & sex == "Male", 
       drinker_cat := "increasing_risk"]
  data[year >= 2011 & drinks_now == "drinker" & weekmean >= 35 & sex == "Female", 
       drinker_cat := "higher_risk"]
  data[year >= 2011 & drinks_now == "drinker" & weekmean >= 50 & sex == "Male", 
       drinker_cat := "higher_risk"]
  
  data[ , `:=`(drink_freq_7d = NULL, total_units7_ch = NULL)]
  
  
  ## Impute missing beverage preferences --------
  
  # fit multinomial model to beverage preferences
  # 4 bev types
  
  # add NAs to units where required
  data[year >= 2011 & 
         (perc_spirit_units + perc_wine_units + perc_rtd_units + perc_beer_units) == 0 & 
         drinker_cat != "abstainer", 
       `:=`(perc_spirit_units = NA, perc_wine_units = NA, perc_rtd_units = NA, perc_beer_units = NA)]
  
  # Make a new ageband variable
  # assumes under 16s (for whom no bev pref data is available) have same preferences as over 16-24s
  # this is potentially a strong assumption, 
  # so the imputed data for these variables for below age 16 might have to be ignored
  data[ , ageband := c("<24", "25-34", "35-49", "50-64", "65+")[findInterval(age, c(0, 25, 35, 50, 65))]]
  
  # Fit a Dirichlet regression
  # in order to impute the proportions with each beverage preference with uncertainty
  
  # Prep data
  coln <- c("perc_spirit_units", "perc_wine_units", "perc_rtd_units", "perc_beer_units")
  
  data_fit <- as.data.frame(
    data[year >= 2011 & drinker_cat != "abstainer" & !is.na(perc_beer_units)]
  )
  
  suppressWarnings(
    data_fit$Y <- DirichletReg::DR_data(data_fit[ , which(colnames(data_fit) %in% coln)] / 100)
  )
  
  # Fit regression
  
  # note: no year trend is fitted
  
  res1 <- DirichletReg::DirichReg(Y ~ ageband + sex + imd_quintile, data_fit)
  
  
  # Grab predicted values - set up new standardised data frame
  newdata <- data.frame(expand.grid(
    ageband = c("<24", "25-34", "35-49", "50-64", "65+"),
    sex = c("Male", "Female"),
    imd_quintile = c("1_least_deprived", "2", "3", "4", "5_most_deprived")
  ))
  
  # Grab the predicted values 
  # in the form of the Dirichlet distribution's parameters (alpha values)
  preds <- data.frame(predict(res1, newdata = newdata, alpha = T, mu = F))
  
  colnames(preds) <- paste0(coln, "_alpha")
  newdata <- data.frame(newdata, preds)
  setDT(newdata)
  
  # Merge the predicted values back into the main data table
  
  # this will add values for years < 2011, but these can be deleted later
  
  data <- merge(data, newdata,
                by = c("ageband", "sex", "imd_quintile"),
                all.x = T, all.y = F, sort = F)
  
  
  # Sample replacements for the missing values of beverage preferences
  data[year >= 2011 & is.na(perc_beer_units), bev_pref_samp :=
         mapply(
           function(seed, a, b, c, d) {
             
             set.seed(seed)
             
             list(DirichletReg::rdirichlet(1, c(a, b, c, d)))
             
           },
           seed = weekmean,
           a = perc_spirit_units_alpha, 
           b = perc_wine_units_alpha,
           c = perc_rtd_units_alpha, 
           d = perc_beer_units_alpha
         )]
  
  # Fill the missing values 
  data[year >= 2011 & is.na(perc_beer_units), perc_spirit_units := sapply(bev_pref_samp, function(x) x[1] * 100)]
  data[year >= 2011 & is.na(perc_beer_units), perc_wine_units := sapply(bev_pref_samp, function(x) x[2] * 100)]
  data[year >= 2011 & is.na(perc_beer_units), perc_rtd_units := sapply(bev_pref_samp, function(x) x[3] * 100)]
  data[year >= 2011 & is.na(perc_beer_units), perc_beer_units := sapply(bev_pref_samp, function(x) x[4] * 100)]
  
  # Remove columns not needed
  data[ , `:=`(ageband = NULL, perc_spirit_units_alpha = NULL, perc_wine_units_alpha = NULL, 
               perc_rtd_units_alpha = NULL, perc_beer_units_alpha = NULL, bev_pref_samp = NULL)]
  
  # Make sure that no info on alcohol consumption before 2011 is present
  
  suppressWarnings(
    data[year < 2011, (grep("beer", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("wine", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("spirit", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("rtd", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("n_days_drink", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("weekmean", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("drinker_cat", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("peakday", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("binge_cat", names(data), value = TRUE)) := NA]
  )
  suppressWarnings(
    data[year < 2011, (grep("totalwu", names(data), value = TRUE)) := NA]
  )
  
  
  
  return(data[])
}

