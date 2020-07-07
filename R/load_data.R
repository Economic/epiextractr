#' Load CPS data
#'
#' More description
#'
#' @param years years of CPS data (integers)
#' @param sample CPS sample ("org", "basic", "may")
#' @param months months of data to load, only for monthly files
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#' @param val_labels when TRUE, add value labels to variables
#'
#' @return a tibble of CPS microdata
#' @export
#' @importFrom dplyr mutate mutate_if filter pull select
#' @importFrom stats setNames
#' @importFrom rlang .data
#' @examples load_cps(years = 2018:2019, sample = "org")
load_cps <- function(years,
                     sample,
                     months = NULL,
                     variables = NULL,
                     extracts_dir = NULL,
                     val_labels = TRUE) {

  # check extracts_dir
  if (is.null(extracts_dir)) {
    extracts_dir <- file.path("/data/cps", sample, "epi")
  }

  # read the data into single frame
  if (is.null(months)) {
    the_data <- purrr::map_dfr(years, ~ read_single_year(
      year = .x,
      sample = sample,
      month = months,
      variables = variables,
      extracts_dir = extracts_dir))
  }
  else {
    the_data <- purrr::map2_dfr(years, months, ~ read_single_year(
      year = .x,
      sample = sample,
      month = .y,
      variables = variables,
      extracts_dir = extracts_dir))
  }


  # add value labels if necessary
  if (val_labels) {
    label_filename <- paste0("epi_cps", sample, "_labels.rds")
    the_labels <- readRDS(file.path(extracts_dir, label_filename))

    the_labels_subset <- the_labels %>%
      mutate(n = purrr::pmap_dbl(list(.data$value_label), nrow)) %>%
      filter(.data$n != 0)

    colnames_subset <- pull(the_labels_subset, .data$variable_name)

    the_val_labels <- the_labels_subset$value_label %>%
      purrr::map(tibble::deframe) %>%
      setNames(colnames_subset)

    the_val_labels

    the_data %>%
      mutate_if(is.logical, as.numeric) %>%
      labelled::set_value_labels(.labels = the_val_labels)
  }
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
  the_data <- arrow::read_feather(file.path(extracts_dir, feather_filename))

  if (!is.null(variables)) {
    the_data <- select(the_data, variables)
  }

  the_data
}
