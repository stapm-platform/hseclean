
#' Upshifting alcohol consumption
#'
#' Upshift the average weekly units of alcohol consumed to adjust for
#' the under-reporting of alcohol consumption in survey data.
#'
#' A function of the form f(PCC, Proportion, Population) where PCC=the 'true'
#' Per Capita Consumption being aimed for in units of per capita litres of pure ethanol per year,
#' Proportion=the proportion of this
#' 'true' value to shift consumption data up to
#' (default is 80 percent, taken from \insertCite{stockwell2018underestimation;textual}{hseclean} which is based
#' on World Health Organisation assumptions)
#' and Population=the population whose consumption is to be
#' upshifted.
#'
#' The fixed values used to generate the standard deviations of the gamma distributions
#' are taken from \insertCite{kehoe2012determining;textual}{hseclean}.
#'
#' Note that the result could be an upshift or a downshift depending
#' on the reference pcc value and the distribution of consumption in the survey data.
#'
#' @param data Data.table - "Population" - the individual level data on alcohol consumption to be upshifted.
#' The variable to be upshifted should be named "weekmean" and contain
#' the average weekly alcohol consumption of an individual in UK standard units of ethanol.
#' @param country Character string - either "England" or "Scotland".
#' @param year_select Integer - Year for which upshifting will be done
#' @param pcc_data Data.table - "PCC" - the values of per capita alcohol consumption
#' calculated from HMRC data on duty receipts disaggregated by UK nation or MESAS monitoring report on alcohol sales 2022 (Scotland only)
#' Stored as package data in hseclean::per_capita_alc_for_upshift.
#' @param proportion Numeric - the proportion of this 'true' value to shift consumption data up to
#' (default is 80 percent \insertCite{stockwell2018underestimation}{hseclean}).
#'
#' @importFrom data.table :=
#' @importFrom Rdpack reprompt
#'
#' @return Returns the input data with a column weekmean_adj added containing
#' the upshifted values of weekly mean alcohol consumption.
#'
#' @references
#' \insertRef{kehoe2012determining}{hseclean}
#' \insertRef{stockwell2018underestimation}{hseclean}
#'
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' # Scottish Health Survey example
#' # 2018
#'
#' library(hseclean)
#' library(data.table)
#' library(magrittr)
#'
#' # Location of Scottish data
#' root_dir <- "X:/HAR_PR/PR/Consumption_TA/HSE/Scottish Health Survey (SHeS)/"
#'
#' data <- read_SHeS_2018(root = root_dir) %>%
#'   clean_age %>% clean_demographic %>%
#'   alc_drink_now_allages %>%
#'   alc_weekmean_adult %>%
#'   select_data(ages = 16:89, years = 2018,
#'     keep_vars = c("wt_int", "year", "age", "sex", "weekmean"),
#'     complete_vars = c("wt_int", "sex", "weekmean"))
#'
#' data <- alc_upshift(data, country = "Scotland",
#'   pcc_data = hseclean::per_capita_alc_for_upshift,
#'   proportion = 0.8)
#'
#' }
#'
#'
#'
#'
#'
#'
alc_upshift <- function(
  data,
  country = c("England", "Scotland")[1],
  year_select,
  # pcc_data = c(hseclean::per_capita_alc_for_upshift, hseclean::per_capita_alc_for_upshift_scotland) [1],
  pcc_data = c("HMRC", "MESAS")[1],
  proportion = 0.8
) {

#Generate the appropriate value for PCC

HMRC <- as.numeric(hseclean::per_capita_alc_for_upshift[Country == country & year == year_select, "PCC"])
MESAS <- as.numeric(hseclean::per_capita_alc_for_upshift_scotland[Country == country & year == year_select, "PCC"])


pcc <- if(pcc_data == "HMRC") {

   if(!(year_select %in% hseclean::per_capita_alc_for_upshift$year)) {
        warning("year selected is not in the pcc reference data")
    } else {
      HMRC
    }

} else if (pcc_data == "MESAS") {

  if(!(country %in% hseclean::per_capita_alc_for_upshift_scotland$Country)) {
    warning("country selected is not in the pcc reference data")
  } else {
    MESAS
  }
}


  cat(crayon::blue(paste0("Reference per capita consumption ", round(pcc, 3), " litres ethanol /year\n")))

  # Calculate the ‘target’ PCC value as PCC x Proportion
  target_pcc <- pcc * proportion

  cat(crayon::blue(paste0("Target per capita consumption at ", 100 * proportion, "% of reference, ", round(target_pcc, 3), " litres ethanol /year\n")))

  # Calculate the current mean consumption in the Population to be upshifted
  # (accounting for relevant weights)

  # convert weekly mean UK standard units to litres ethanol per year

  # A UK unit is 10 millilitres (8 grams) of pure alcohol

  data[ , lt_ethanol_yr := ((365/7) * weekmean * 10) / 1000]

  mu_weighted <- sum(data$wt_int * data$lt_ethanol_yr) / sum(data$wt_int)

  cat(crayon::blue(paste0("Current per capita consumption in population ", round(mu_weighted, 3), " litres ethanol /year\n")))

  # Calculate the ratio between the population mean and the target value
  r <- target_pcc / mu_weighted

  cat(crayon::blue(paste0("Ratio between the current population value and the target value ", round(r, 3), "\n")))

  # Calculate the current mean consumption among men and women in the population to be upshifted
  mu_male <- as.numeric(data[sex == "Male", .(mu = sum(wt_int * lt_ethanol_yr) / sum(wt_int))])
  mu_female <- as.numeric(data[sex == "Female", .(mu = sum(wt_int * lt_ethanol_yr) / sum(wt_int))])

  cat(crayon::blue(paste0("Current per capita consumption\n\t Males: ", round(mu_male, 3), " litres ethanol /year\n\t Females: ", round(mu_female, 3), " litres ethanol /year\n")))

  # Calculate the sex-specific target means
  mu_hat_male <- r * mu_male
  mu_hat_female <- r * mu_female

  cat(crayon::blue(paste0("Target per capita consumption\n\t Males: ", round(mu_hat_male, 3), " litres ethanol /year\n\t Females: ", round(mu_hat_female, 3), " litres ethanol /year\n")))

  # Generate four gamma distributions

  # use method of moments to approximate the shape and scale parameters
  # from the mean and variance

  # scale = variance / mean
  # shape = mean / scale

  gamma_base_male_scale <- ((mu_male * 1.171) ^ 2) / mu_male
  gamma_base_male_shape <- mu_male / gamma_base_male_scale

  gamma_target_male_scale <- ((mu_hat_male * 1.171) ^ 2) / mu_hat_male
  gamma_target_male_shape <- mu_hat_male / gamma_target_male_scale

  gamma_base_female_scale <- ((mu_female * 1.258) ^ 2) / mu_female
  gamma_base_female_shape <- mu_female / gamma_base_female_scale

  gamma_target_female_scale <- ((mu_hat_female * 1.258) ^ 2) / mu_hat_female
  gamma_target_female_shape <- mu_hat_female / gamma_target_female_scale

  # For each sex and centile c calculate the adjustment ratio
  # as the ratio of the Cumulative Density functions of the target and base gamma distributions
  c_vals <- seq(0.1 - 1e-8, 1 - 1e-8, 0.1)

  male_base_c <- qgamma(c_vals, scale = gamma_base_male_scale, shape = gamma_base_male_shape)
  male_target_c <- qgamma(c_vals, scale = gamma_target_male_scale, shape = gamma_target_male_shape)

  female_base_c <- qgamma(c_vals, scale = gamma_base_female_scale, shape = gamma_base_female_shape)
  female_target_c <- qgamma(c_vals, scale = gamma_target_female_scale, shape = gamma_target_female_shape)

  data_adj <- data.table(percentile = c_vals,
                         Male = male_target_c / male_base_c,
                         Female = female_target_c / female_base_c)

  data_adj <- melt.data.table(data_adj, id.vars = "percentile", value.name = "ratio", variable.name = "sex")

  # Calculate the adjusted mean consumption for every individual in the population
  # by multiplying their current consumption by the adjustment ratio appropriate
  # to their sex and centile in the current (observed) sex-specific consumption distribution

  # Assign individuals to their observed age-specific gamma percentiles of weekly mean consumption
  data[ , percentile := {

    # create a new vector of consumption values accounting for survey weights
    vec <- sample(lt_ethanol_yr, 1e5, replace = TRUE, prob = wt_int)

    # estimate the gamma distribution parameters
    fit <- fitdistrplus::fitdist(vec, distr = "gamma", method = "mge", gof = "CvM")

    # use the parameters to estimate the centile values
    obs_c <- stats::qgamma(c_vals, shape = fit$estimate[1], rate = fit$estimate[2])

    # assign each individual to a centile
    percentile <- c_vals[findInterval(lt_ethanol_yr, c(0, obs_c))]

  }, by = "sex"]

  # Merge in the corresponding reference values
  data <- merge(data, data_adj, by = c("sex", "percentile"), all.x = T, all.y = F)

  # Calculate the adjusted consumption
  data[ , lt_ethanol_yr_adj := lt_ethanol_yr * ratio]

  # Cross-check that the population mean of the upshifted consumption is equal to the target value
  # (and apply a small universal adjustment factor if it is slightly out)
  mu_weighted_adj <- sum(data$wt_int * data$lt_ethanol_yr_adj) / sum(data$wt_int)

  cat(crayon::blue(paste0("Adjusted per capita consumption ", round(mu_weighted_adj, 3), " litres ethanol /year\n")))

  # Calculate a universal adjustment factor to make the adjusted value equal to the target value
  univ_adj <- target_pcc / mu_weighted_adj

  cat(crayon::blue(paste0("Universal adjustment factor applied ", round(univ_adj, 3), "\n")))

  data[ , lt_ethanol_yr_adj := lt_ethanol_yr_adj * univ_adj]

  # convert back to mean UK standard units of ethanol per week
  data[ , weekmean_adj := lt_ethanol_yr_adj * 1000 * (1/(365/7)) * (1/10)]

  # Delete columns not needed
  data[ , `:=` (percentile = NULL, ratio = NULL, lt_ethanol_yr = NULL, lt_ethanol_yr_adj = NULL)]

  return(data[])
}


