
# This code reads the processed health survey dataset
# and conducts imputation of key missing variables.

# all the variables to be imputed are categorical

library(data.table)
library(hseclean)

# Load the data

# choose the file output by 10_clean_shes.R
data <- readRDS(paste0(dir, "/alc_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, ".rds"))

# sapply(data, class)

# view variables with missingness
misscheck <- function(var) {
  x <- table(var, useNA = "ifany")
  na <- x[which(is.na(names(x)))]
  if(length(na) == 0) na <- 0
  perc <- round(100 * na / sum(x), 2)
  #return(c(paste0(na, " missing obs, ", perc, "%")))
  return(na)
}

n_missing <- sapply(data, misscheck)
missing_vars <- n_missing[which(n_missing > 0)]
missing_vars

# household equivalised income has the most missingness
# - this is a key variable to impute
# as we will use it to understand policy inequalities

# The categorical variables involved
var_names <- c(
  "kids",
  "relationship_status",
  "ethnicity_2cat",
  "eduend4cat",
  "degree",
  "nssec3_lab",
  "employ2cat",# complete variable
  "activity_lstweek",# complete variable
  "income5cat",
  "hse_mental",
  "drinker_cat"
)

# Note that the imputation wont work unless the variables considered are
# either subject to imputation or do not contain any missingness (i.e. are complete)

# The variables to be imputed and the method to be used
var_methods <- rep("", ncol(data))

var_methods[which(var_names == "kids")] <- "polr"
var_methods[which(var_names == "relationship_status")] <- "polyreg"
var_methods[which(var_names == "ethnicity_2cat")] <- "logreg"
var_methods[which(var_names == "eduend4cat")] <- "polyreg"
var_methods[which(var_names == "degree")] <- "logreg"
var_methods[which(var_names == "nssec3_lab")] <- "polyreg"
var_methods[which(var_names == "income5cat")] <- "polr"
var_methods[which(var_names == "hse_mental")] <- "logreg"


# Set order of factors where needed for imputing as ordered.
data[ , kids := factor(kids, levels = c("0", "1", "2", "3+"))]
data[ , income5cat := factor(income5cat, levels = c("1_lowest_income", "2", "3", "4", "5_highest_income"))]


# Impute missing values

# Run the imputation
imp <- impute_data_mice(
  data = data,
  var_names = var_names,
  var_methods = var_methods,
  n_imputations = 5
  # for testing just do 1 imputation
  # but test with more later
  # for point estimates, apparently 2-10 imputations are enough
)

data_imp <- copy(imp$data)

# Write the imputed data
write.table(data_imp, paste0(dir, "/alc_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, "_imputed.csv"), row.names = F, sep = ",")
saveRDS(data_imp, paste0(dir, "/alc_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, "_imputed.rds"))



