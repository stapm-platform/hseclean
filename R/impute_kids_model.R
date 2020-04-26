
#' Multinomial model of number of kids in the household 2012-2014
#'
#' To impute the missing data for number of kids in the household for years 2015+
#' 
#' This is a saved model object. It is a multinomial model fitted in the R package nnet. multinom(formula = kids ~ age_cat + sex + relationship_status + 
#'ethnicity_4cat + imd_quintile + eduend4cat + degree + nssec3_lab + 
#'  employ2cat + activity_lstweek, data = data, maxit = 1000)
#'
#' @docType data
#'
#' @format model object
#'
#' @source The code used to fit the model is in data-raw/Impute Kids
#'
#'
#'
#'
#'
"impute_kids_model"
