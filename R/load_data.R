#' Load CPS data
#'
#' More description
#'
#' @param years years of CPS data (integers)
#' @param sample CPS sample ("org", "basic", "march", "may")
#' @param months months of data to load, only for monthly files
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#' @param val_labels when TRUE, add value labels to variables
#'
#' @return a tibble of CPS microdata
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' load_cps(years = 2018:2019, sample = "org")
#' }
load_cps <- function(years,
                     sample,
                     months = NULL,
                     variables = NULL,
                     extracts_dir = NULL,
                     val_labels = TRUE) {

  # check sample
  sample <- tolower(sample)
  if (! sample %in% c("basic", "march", "may", "org")) {
    stop("You need to specify the CPS sample: Basic, March, May, ORG")
  }

  # check extracts_dir
  if (is.null(extracts_dir)) {
    # use environment variable dir if available
    extracts_dir <- Sys.getenv(paste0("EPIEXTRACTS_CPS", toupper(sample), "_DIR"))
    if (extracts_dir == "") extracts_dir <- getwd()
  }

  # read the data into single list
  if (is.null(months)) {
    the_data <- purrr::map(
      years, ~ read_single_year(
      year = .x,
      sample = sample,
      month = months,
      variables = variables,
      extracts_dir = extracts_dir))
  }
  else {
    crossargs <- expand.grid(x=years, y=months)
    the_data <- purrr::map2(crossargs$x, crossargs$y, ~ read_single_year(
      year = .x,
      sample = sample,
      month = .y,
      variables = variables,
      extracts_dir = extracts_dir))
  }

  the_data %>%
    data.table::rbindlist(use.names = TRUE) %>%
    tibble::as_tibble()
}


#' Read single year of feather CPS
#'
#' @param year year of data
#' @param sample CPS sample ("basic", "may", "org")
#' @param month month of file
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#'

read_single_year <- function(year, sample, month = NULL, variables = NULL, extracts_dir) {

  if(is.null(month)) {
    feather_filename <- paste0("epi_cps", sample, "_", year, ".feather")
  }
  else {
    feather_filename <- paste0("epi_cps", sample, "_", year, "_", month, ".feather")
  }

  if (!is.null(variables)) {
    the_data <- arrow::read_feather(file.path(extracts_dir, feather_filename), col_select = variables)
  }
  else {
    the_data <- arrow::read_feather(file.path(extracts_dir, feather_filename))
  }

  the_data
}
