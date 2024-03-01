library(testthat)
library(farsfunctions)
library(dplyr)
library(readr)
library(tibble)
library(tidyr)
library(maps)
library(graphics)


# Test for fars_read function
test_that("fars_read returns a valid tibble", {
  expect_equal(nrow(fars_read("accident_2013.csv.bz2")), 30202)
  expect_equal(ncol(fars_read("accident_2013.csv.bz2")), 50)
})

test_that("fars_read shows an error message if the file does not exist", {
  expect_error(fars_read("non_exixtent_file"),
               "file '.+' does not exist")
})


# Test for make_filename function
test_that("make_filename returns a valid filename format", {
  expect_type(make_filename(2013), type = "character")
  expect_match(make_filename(2013), "accident_2013\\.csv\\.bz2$")
})

# Test for fars_read_years function
test_that("fars_read_years returns a list of tibbles for specified years", {
  expect_type(fars_read_years(c(2013, 2014)), type = "list")
  expect_equal(length(fars_read_years(c(2013, 2014))), 2)
  expect_equal(length(fars_read_years(2013:2015)), 3)
})

test_that("fars_read_years shows a warning message if the year is not valid", {
  expect_warning(fars_read_years(c(2012, 2013)),
                 "invalid year: 2012")
  expect_warning(fars_read_years(2012:2015),
                 "invalid year: 2012")
})


# Test for fars_summarize_years function

test_that("fars_summarize_years returns a tibble", {
  expect_type(fars_summarize_years(c(2013, 2014)), type = "list")
  expect_equal(nrow(fars_summarize_years(c(2013, 2015))), 12)
  expect_equal(ncol(fars_summarize_years(2013:2014)), 3)
})

test_that("fars_summarize_years shows a warning message if the year is not valid",{
  expect_warning(fars_summarize_years(c(2012, 2013)),
                 "invalid year: 2012")
  expect_warning(fars_summarize_years(2012:2015),
                 "invalid year: 2012")
})


# Test for fars_map_state function

test_that("fars_map_state shows FARS data on the map", {
  expect_null(fars_map_state(50, 2013))
})

test_that("fars_map_state shows an error message if there is no data", {
  expect_error(fars_map_state(50, 2012),
               "file 'accident_2012.csv.bz2' does not exist")
  expect_error(fars_map_state(85),
               'argument "year" is missing')
})

test_that("fars_map_state shows an error message if the state number is invalid", {
  expect_error(fars_map_state(85, 2013),
               "invalid STATE number: 85")
  expect_error(fars_map_state(2, 2015),
               "nothing to draw: all regions out of bounds")
})
