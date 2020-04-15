
library(hseclean)

root_dir <- "/Volumes/Shared/"

test_that("all current smokers have an amount smoked per data that is greater than zero", {
  
  data <- read_2016(root = root_dir)
  
  data <- clean_age(data)
  data <- clean_demographic(data)
  data <- smk_status(data)
  data <- smk_former(data)
  data <- smk_life_history(data)
  data <- smk_amount(data)
  
  testthat::expect_equal(nrow(data[cig_smoker_status == "current" & cigs_per_day == 0]), 0, info = "some current smokers smoke 0 cigs per day")
  
})

  
  

