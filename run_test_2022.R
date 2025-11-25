# Complete HSE 2022 Testing Script
# This script rebuilds data, reinstalls package, and runs tests

cat("========================================\n")
cat("HSE 2022 COMPLETE TEST WORKFLOW\n")
cat("========================================\n\n")

# Step 1: Rebuild data files with cider assumptions
cat("Step 1: Rebuilding data files...\n")
source("rebuild_data.R")
cat("✓ Data files rebuilt\n\n")

# Step 2: Install the package
cat("Step 2: Installing hseclean package...\n")
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install(upgrade = "never", build_vignettes = FALSE, quiet = TRUE)
cat("✓ Package installed\n\n")

# Step 3: Run the tests
cat("Step 3: Running tests...\n\n")
source("tests/test_hse_2022.r")

cat("\n========================================\n")
cat("WORKFLOW COMPLETE\n")
cat("========================================\n")
