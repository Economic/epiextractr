#' Load CPS data
#'
#' More description
#'
#' @param years years of CPS data (integers)
#' @param sample CPS sample ("org", "basic", "march", "may")
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#' @param version_check when TRUE, confirm data are same version
#' @return a tibble of CPS microdata
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' load_cps(years = 2018:2019, sample = "org")
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
    bind_cps(version_check = version_check)

  if (.version_check) message(paste("Using", attr(the_data, "label")))
  the_data

}


#' Read single year of feather CPS
#'
#' @param year year of data
#' @param sample CPS sample ("basic", "may", "org")
#' @param variables variables to keep
#' @param extracts_dir directory where EPI extracts are
#' @param version_check when TRUE, confirm separate monthly files have same version
#'

read_single_year <- function(sample,
                             year,
                             ...,
                             extracts_dir,
                             version_check = TRUE) {

  feather_filename <- paste0("epi_cps", sample, "_", year, ".feather")
  full_feather_filename <- file.path(extracts_dir, feather_filename)

  if (file.exists(full_feather_filename)) {
    return(read_feather_tidyselect(full_feather_filename, ...))
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
          read_feather_tidyselect(...)}
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


#' bind list of cps files together
#'
#' @param x list of cps files
#' @param version_check whether to check verisons
#'
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


read_feather_tidyselect <- function(.data, ...) {
  if (!inherits(.data, "RandomAccessFile")) {
    .data <- arrow:::make_readable_file(.data)
    on.exit(.data$close())
  }
  reader <- arrow::FeatherReader$create(.data)

  col_select <- rlang::enquos(...)
  columns <- if (length(col_select) != 0) {
    tidyselect::vars_select(names(reader), !!!col_select)
  }

  out <- reader$Read(columns) %>% as.data.frame()

  out
}
