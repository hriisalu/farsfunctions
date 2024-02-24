library(testthat)
library(farsfunctions)

# Test for fars_read function
test_that("Test fars_read function", {
  # Create a temporary file with some data
  tmp_file <- tempfile()
  write.csv(data.frame(a = 1:5, b = letters[1:5]), tmp_file)
  
  # Test if fars_read reads the data correctly and returns a tibble
  expect_s3_class(fars_read(tmp_file), "tbl_df")
})

# Test for make_filename function
test_that("Test make_filename function", {
  # Test if make_filename generates the correct filename
  expect_equal(make_filename(2013), "accident_2013.csv.bz2")
})