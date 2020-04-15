
library(hseclean)

root_dir <- "/Volumes/Shared/"


test_that("2001 HSE data can be read and processed", {
  
  expect_error(data <- read_2001(root = root_dir), NA)
  expect_warning(data <- read_2001(root = root_dir), NA)
  
  data <- read_2001(root = root_dir)
  
  data <- clean_age(data)
  
})




