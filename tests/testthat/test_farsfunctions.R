library(testthat)
library(farsfunctions)



# Test for fars_read function
test_that("fars_read returns a valid tibble", {
  expect_equal(nrow(fars_read("data/accident_2013.csv.bz2")), 30202)
  expect_equal(ncol(fars_read("data/accident_2013.csv.bz2")), 50)
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

test_that("fars_summarize_years returns the data frame",{
  expect_type(fars_summarize_years(c(2013, 2014)), type = "tibble")
  # expect_equal(nrow(fars_summarize_years(c(2013, 2014))), 12)
  # expect_equal(ncol(fars_summarize_years(c(2013:2015))), 3)
})

# SIIN ON MINGI JAMA!!!!!
#chatGtp soovitus muuta funkctiooni:
fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years) %>%
    dplyr::bind_rows() %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
  return(as_tibble(dat_list))  # Convert to tibble
}


# KELLEGI TEISE FAILIST
test_that("make_filename returns a correctly formatted character string",{
  expect_type(make_filename("2014"), type = "character")
  expect_match(make_filename("2014"),
               "^(accident_).+(csv.bz2)$")
  expect_equal(nchar(make_filename("2014")), 21)
})

test_that("make_filename issues warning if it can't make a filename",{
  expect_warning(make_filename("twenty-fourteen"),
                 "NAs introduced by coercion")
  expect_warning(make_filename("@#$!_"),
                 "NAs introduced by coercion")
})

test_that("fars_read returns the correct tibble", {
  expect_equal(nrow(fars_read("accident_2013.csv.bz2")), 30202)
  expect_equal(ncol(fars_read("accident_2013.csv.bz2")), 50)
})

test_that("fars_read throws error if file doesn't exist",{
  expect_error(fars_read("nonexistent_file"),
               "file 'nonexistent_file' does not exist")
})

test_that("fars_read_years returns the correct list", {
  expect_type(fars_read_years(c("2013","2014")),
              type = "list")
  expect_equal(length(fars_read_years(c("2013","2015"))), 2)
  expect_equal(length(fars_read_years(c("2013","2014","2015"))), 3)
})

test_that("fars_read_years issues warnings if it can't find files", {
  expect_warning(fars_read_years(c("2015","2025")),
                 "invalid year: 2025")
  expect_warning(fars_read_years(list("2014","1776")),
                 "invalid year: 1776")
})

test_that("fars_summarize_years returns the correct list",{
  expect_type(fars_summarize_years(c("2014","2015")),
              type = "list")
  expect_equal(nrow(fars_summarize_years(c("2014","2015"))), 12)
  expect_equal(ncol(fars_summarize_years(c("2014","2015"))), 3)
  expect_equal(ncol(fars_summarize_years(c("2013","2014","2015"))), 4)
})

test_that("fars_summarize_years issues warning if it can't find files",{
  expect_warning(fars_summarize_years(c("2013","1800")),
                 "invalid year: 1800")
  expect_warning(fars_summarize_years(list("2040","2014")),
                 "invalid year: 2040")
})

test_that("fars_map_state correctly maps a state's accident data",{
  expect_null(fars_map_state(1,2015))
})

test_that("fars_map_state throws error if arguments not supplied",{
  expect_error(fars_map_state(1,2033),
               "file 'accident_2033.csv.bz2' does not exist")
  expect_error(fars_map_state(1),
               'argument "year" is missing, with no default')
})

test_that("fars_map_state throws errors for states that can't be mapped",{
  expect_error(fars_map_state(100,2015),
               "invalid STATE number: 100")
  expect_error(fars_map_state(3, 2013),
               "invalid STATE number: 3")
  expect_error(fars_map_state(2,2015),
               "nothing to draw: all regions out of bounds")
})
