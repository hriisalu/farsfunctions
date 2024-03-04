# The purpose of this assessment is to document some R functions using roxygen2 style comments that would eventually be translated into R documentation files. For this assignment you do NOT need to build an entire package nor do you need to write any R code. You only need to document the functions in the supplied R script.
# *what each function does, in general terms;
# *the function arguments (inputs);
# *each function's return value;
# *conditions that may result in an error;
# *functions that need to be imported from external packages;
# *examples of each function's usage

#' Reading FARS data
#'
#' The function reads FARS (Fatality Analysis Reporting System) data from a csv file.
#' If the file does not exist, an error message is shown.
#'
#' @param filename Path to the csv file as a character string.
#'
#' @importFrom readr read_csv
#' @importFrom tibble as_tibble
#'
#' @return A tibble containing the data
#'
#' @examples
#' \dontrun{
#' fars_read("path/to/accident_2013.csv.bz2")
#' }
#'
#' @export
#'
fars_read <- function(filename) {
  path <- system.file("extdata", filename, package = "farsfunctions")
  print(path)
  if (!file.exists(path))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(path, progress = FALSE)
  })
  tibble::as_tibble(data)
}

#' Creating file name
#'
#' The function generates the filename for a FARS data file, based on the input year.
#'
#' @param year The year for which the filename is generated as integer.
#'
#' @return A character string representing the generated filename
#'
#' @examples
#' \dontrun{
#' make_filename(2013)
#' }
#'
#' @export
#'
make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("accident_%d.csv.bz2", year)
}

#' Reading FARS data for multiple years
#'
#' The function reads FARS data for multiple years and combines them into a tibble.
#' If the year is not valid, the warning message is shown.
#'
#' @param years A vector of years, years as integers.
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate select
#'
#' @return A list of tibbles, each containing data for a specific year
#'
#' @examples
#' \dontrun{
#' fars_read_years(c(2013, 2014))
#' fars_read_years(2013:2015)
#' }
#'
#' @export
#'

fars_read_years <- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)
    cat("Reading file:", file, "\n")
    tryCatch({
      dat <- fars_read(file)
      cat("Successfully read file for year:", year, "\n")
      dat <- dat %>%
        dplyr::mutate(year = year) %>%
        dplyr::select(MONTH, year)
      return(dat)
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}




#' Summarizing FARS data for multiple years
#'
#' The function summarizes FARS data for multiple years, counting accidents per month.
#'
#' @param years A vector of years, years as integers.
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr bind_rows group_by summarize n
#' @importFrom tidyr spread
#' @importFrom tibble as_tibble
#'
#' @return A tibble summarizing the number of accidents per month for each year
#'
#' @examples
#' \dontrun{
#' fars_summarize_years(c(2013, 2014))
#' fars_summarize_years(2013:2015)
#' }
#'
#' @export
#'
fars_summarize_years <- function(years) {
  dat <- fars_read_years(years) %>%
    dplyr::bind_rows() %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = dplyr::n()) %>%
    tidyr::spread(year, n)
  return(tibble::as_tibble(dat))
}

#' Mapping FARS data for a specific state and year
#'
#' The function shows FARS data on a map for a specific state and year.
#' If the state number is invalid, the error message is shown.
#'
#' @param state.num The state number as integer.
#' @param year The year for which the data is plotted as integer.
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#' @return A plot of FARS data on a map
#'
#' @examples
#' \dontrun{
#' fars_map_state(50, 2013)
#' }
#'
#' @export
#'
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}
