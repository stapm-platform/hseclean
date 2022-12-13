
#' Chained multiple imputation of a set of variables
#'
#' This function uses the \href{https://cran.r-project.org/web/packages/mice/mice.pdf}{mice} package to
#' multiply impute missing values based on the statistical relationships among a set of variables.
#' There is a range of mice documentation and tutorials that is worth getting into to develop and check this function.
#'
#' @param data Data table - the Health Survey for England dataset with missing values
#' @param var_names Character vector - the names of the variables to be considered in the multiple imputation.
#' @param var_methods Character vector - the names of the statistical methods to be used to predict each of
#' the above variables - see the mice documentation.
#' @param n_imputations Integer - the number of different versions of the imputed data to produce.
#' @importFrom data.table :=
#' @return Returns a list containing
#' \itemize{
#' \item{data} All versions of the multiply imputed data in a single data table.
#' \item{object} The mice multiple imputation object.
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' # "logreg" - binary Logistic regression
#' # "polr" - ordered Proportional odds model
#' # "polyreg" - unordered Polytomous logistic regression
#'
#' imp_obj <- impute_data_mice(
#'   data = test_data,
#'   c("binary_variable", "order_categorical_variable", "unordered_categorical_variable"),
#'   c("logreg", "polr", "polyreg"),
#'   n_imputations = 5
#' )
#'
#' }
#'
impute_data_mice <- function(
  data,
  var_names,
  var_methods,
  n_imputations
) {

  # Convert variables to factors
  for(v in var_names) {

    if(!is.factor(data[ , get(v)])) {

    data[ , (v) := as.factor(get(v))]

    }

  }

  # Setup the predictor matrix
  n <- ncol(data)
  predMat <- matrix(0, n, n)

  # Set the method to be used to impute each variable
  var_methods_long <- rep("", n)

  # Set the variables that will be used in the prediction of missing values in other variables
  for(var_i in var_names) {

    # var_i <- var_names[1]

    predMat[NamePos(var_i, data), NamePos(var_names[var_names != var_i], data)] <- 1

    var_methods_long[NamePos(var_i, data)] <- var_methods[which(var_names == var_i)]

  }

  # Make sure the diagonal is zero so no variable is predicting itself
  if(sum(diag(predMat)) > 0) warning("a variable is predicting itself")

  # Create the mids object
  mi_object <- mice::mice(data, m = n_imputations, method = var_methods_long, predictorMatrix = predMat)

  # Grab the imputed iterations of the hse and join them together

  for (i in 1:n_imputations) {

    imp <- mice::complete(mi_object, i, include = FALSE)

    setDT(imp)

    imp[ , imputation := i]

    if(i == 1) {

      imputed_data <- copy(imp)

    } else {

      imputed_data <- data.table::rbindlist(list(imputed_data, copy(imp)), use.names = T)

    }

  }

  return(
    list(
      data = imputed_data,
      object = mi_object
    )
  )
}



# Return the position of a variable name
NamePos <- function(
  name_list,
  data
) {

  which(is.element(names(data), name_list))

}





















































