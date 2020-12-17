#' Load a selection of EPI CPS extracts
#'
#' Select years and variables from the EPI CPS microdata extracts. These data
#' must first be downloaded using `download_cps()` or from
#' \url{https://microdata.epi.org}.
#'
#' Load CPS Details paragraph
#'
#' @section After function section:
#' Despite its location, this actually comes after the function section.
#' @describeIn load_cps base function group
#'
#' @param .sample CPS sample ("org", "basic", "march", "may")
#' @param .years years of CPS data (integers)
#' @param ... tidy selection of variables to keep
#' @param .extracts_dir directory where EPI extracts are
#' @param .version_check when TRUE, confirm data are same version
#' @return A tibble of CPS microdata
#' @export
#' @importFrom magrittr %>%
#' @importFrom haven labelled
#' @examples
#' \dontrun{
#'
#' # These are equivalent:
#' load_org(2019:2020)
#' load_cps("org", 2019:2020)
#' }
load_cps <- function(.sample,
                     .years,
                     ...,
                     .extracts_dir = NULL,
                     .version_check = TRUE) {

  # retrieve valid sample name
  .sample <- valid_sample_name(.sample)

  # check extracts_dir
  if (is.null(.extracts_dir)) {
    # use environment variable dir if available
    .extracts_dir <- Sys.getenv(paste0("EPIEXTRACTS_CPS", toupper(.sample), "_DIR"))
    if (.extracts_dir == "") .extracts_dir <- getwd()
  }

  # read the data into single list
  the_data <-
    lapply(.years, function(x) {
      read_single_year(
        sample = .sample,
        year = x,
        ...,
        extracts_dir = .extracts_dir,
        version_check = .version_check)}
    ) %>%
    # stack the data and add version attributes
    bind_cps(version_check = .version_check)

  if (.version_check) message(paste("Using", attr(the_data, "label")))
  the_data

}

#' @export
#' @describeIn load_cps Load CPS Basic Monthly files
load_basic <- function(.years,
                     ...,
                     .extracts_dir = NULL,
                     .version_check = TRUE) {
  load_cps(.sample = "basic",
           .years = .years,
           ...,
           .extracts_dir = .extracts_dir,
           .version_check = .version_check)
}

#' @export
#' @describeIn load_cps Load CPS May files
load_may <- function(.years,
                     ...,
                     .extracts_dir = NULL,
                     .version_check = TRUE) {
  load_cps(.sample = "may",
           .years = .years,
           ...,
           .extracts_dir = .extracts_dir,
           .version_check = .version_check)
}

#' @export
#' @describeIn load_cps Load CPS ORG files
load_org <- function(.years,
                     ...,
                     .extracts_dir = NULL,
                     .version_check = TRUE) {
  load_cps(.sample = "org",
           .years = .years,
           ...,
           .extracts_dir = .extracts_dir,
           .version_check = .version_check)
}


# load_cps Load CPS March files
load_march <- function(.years,
                     ...,
                     .extracts_dir = NULL,
                     .version_check = TRUE) {
  load_cps(.sample = "march",
           .years = .years,
           ...,
           .extracts_dir = .extracts_dir,
           .version_check = .version_check)
}



read_single_year <- function(sample,
                             year,
                             ...,
                             extracts_dir,
                             version_check = TRUE) {

  feather_filename <- paste0("epi_cps", sample, "_", year, ".feather")
  full_feather_filename <- file.path(extracts_dir, feather_filename)

  if (file.exists(full_feather_filename)) {
    return(arrow::read_feather(full_feather_filename, col_select = c(...)))
  }
  else {
    monthly_prefix <- paste0("epi_cps", sample, "_", year, "_")
    months <- dir(extracts_dir, pattern = paste0("^", monthly_prefix, ".*\\.feather$"))
    months <- sub(paste0(".*", monthly_prefix), "", months)
    months <- sub(".feather", "", months) %>%
      as.numeric() %>%
      sort()
    # use monthly data
    if (length(months) > 0) {
      monthly_data <- lapply(months, function(x) {
        file.path(extracts_dir, paste0(monthly_prefix, x, ".feather")) %>%
          arrow::read_feather(col_select = c(...))}
      )
      months <- paste(months, collapse = " ")
      message(paste("Data for year", year, "only includes months", months))
      return(bind_cps(monthly_data, version_check))
    }
    # abort when no data found
    else {
      rlang::abort(paste(extracts_dir, "does not contain data for the year", year))
    }
  }

}

bind_cps <- function(x, version_check) {

  versions <- purrr::map(x, ~ attr(.x, "label")) %>% unlist()
  full_version <- unique(versions)
  if (! length(full_version) == 1) {
    message("You are using multiple, different versions of the EPI CPS extracts.")
    message("This is not recommended.")
    message("You should re-download the most current version of the data with download_cps().")
    if (version_check) rlang::abort("Version conflicts among multiple data files.")
  }

  x <- data.table::rbindlist(x, use.names = TRUE) %>%
    tibble::as_tibble()

  attr(x, "label") <- full_version
  attr(x, "version") <- sub(".*Version ", "", full_version)

  x
}


