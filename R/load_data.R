#' Load CPS data
#'
#' More description
#'
#' @param years years of CPS data (integers)
#' @param sample CPS sample ("org", "basic", "may")
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#' @param val_labels when TRUE, add value labels to variables
#'
#' @return a tibble of CPS microdata
#' @export
#' @import dplyr
#' @importFrom stats setNames
#' @examples load_cps(years = 2018:2019, sample = "org")
load_cps <- function(years,
                     sample,
                     variables = NULL,
                     extracts_dir = NULL,
                     val_labels = TRUE) {

  if (is.null(extracts_dir)) {
    extracts_dir <- file.path("/data/cps", sample, "epi")
  }

  the_data <-
    purrr::map_dfr(years, ~ read_single_year(
      .x,
      sample = sample,
      variables = variables,
      extracts_dir = extracts_dir
      )
    )

  if (!val_labels) {
    the_data
  }
  else {
    label_filename <- paste0("epi_cps", sample, "_labels.rds")
    the_labels <- readRDS(file.path(extracts_dir, label_filename))

    the_labels_subset <- the_labels %>%
      mutate(n = purrr::pmap_dbl(list(.data$value_label), nrow)) %>%
      filter(n != 0)

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
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#'

read_single_year <- function(year, sample, variables = NULL, extracts_dir) {
  feather_filename <- paste0("epi_cps", sample, "_", year, ".feather")
  the_data <- arrow::read_feather(file.path(extracts_dir, feather_filename))

  if (!is.null(variables)) {
    the_data <- dplyr::select(the_data, variables)
  }

  the_data
}
