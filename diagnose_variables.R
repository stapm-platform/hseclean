# Diagnostic script to check what variables are in HSE 2022

library(data.table)
library(stringr)

# Read the raw data (all columns)
cat("Reading HSE 2022 data (all columns)...\n")
data_raw <- fread(
  "C:/Users/cm1mha/Documents/hseclean-master (3)/hseclean-master/HSE_2022/UKDA-9469-tab/tab/hse_2022_eul_v1.tab",
  na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A")
)

setnames(data_raw, names(data_raw), tolower(names(data_raw)))

cat("Total columns:", ncol(data_raw), "\n\n")

# Check alcohol columns (894:1084)
cat("=== ALCOHOL VARIABLES (columns 894:1084) ===\n")
alc_cols <- colnames(data_raw[, 894:1084])
cat("Number of alcohol variables:", length(alc_cols), "\n")
cat("\nBeer variables:\n")
print(alc_cols[grepl("beer", alc_cols, ignore.case = TRUE)])

cat("\nCider variables:\n")
print(alc_cols[grepl("cid", alc_cols, ignore.case = TRUE)])

cat("\nWine variables:\n")
print(alc_cols[grepl("wine", alc_cols, ignore.case = TRUE)])

cat("\nSpirits variables:\n")
print(alc_cols[grepl("spir", alc_cols, ignore.case = TRUE)])

cat("\nSherry variables:\n")
print(alc_cols[grepl("sherry", alc_cols, ignore.case = TRUE)])

cat("\nAlcopops/RTD variables:\n")
print(alc_cols[grepl("pop", alc_cols, ignore.case = TRUE)])

cat("\n=== KEY DRINKING FREQUENCY VARIABLES ===\n")
cat("Looking for dnoft, dnnow, dnany...\n")
all_names <- names(data_raw)
cat("\nVariables starting with 'dn':\n")
print(all_names[grepl("^dn", all_names, ignore.case = TRUE)])

cat("\nVariables containing 'drink':\n")
print(all_names[grepl("drink", all_names, ignore.case = TRUE)])

cat("\n=== CHECKING SPECIFIC BEER VARIABLES ===\n")
beer_vars_needed <- c("nbeer", "nbeerm1", "nbeerm2", "nbeerm3", "nbeerm4",
                      "nbeerq1", "nbeerq2", "nbeerq3", "nbeerq4",
                      "sbeer", "sbeerm1", "sbeerm2", "sbeerm3", "sbeerm4",
                      "sbeerq1", "sbeerq2", "sbeerq3", "sbeerq4")

for (var in beer_vars_needed) {
  if (var %in% all_names) {
    col_num <- which(all_names == var)
    cat(sprintf("  ✓ %s found at column %d\n", var, col_num))
  } else {
    # Check with _22 suffix
    var_with_suffix <- paste0(var, "_22")
    if (var_with_suffix %in% all_names) {
      col_num <- which(all_names == var_with_suffix)
      cat(sprintf("  ✓ %s found as %s at column %d\n", var, var_with_suffix, col_num))
    } else {
      cat(sprintf("  ✗ %s NOT FOUND\n", var))
    }
  }
}
