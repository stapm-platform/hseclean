
library(hseclean)
library(testthat)

root_dir <- "/Volumes/Shared/"


test_that("HSE data can be read and processed", {
  
  expect_error(data <- read_2018(root = root_dir), NA)
  expect_warning(data <- read_2018(root = root_dir), NA)
  
  data <- read_2018(root = root_dir)
  
  data <- clean_age(data)
  
})




