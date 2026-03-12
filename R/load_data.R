#' Get file paths for EPI CPS extracts
#'
#' Returns file paths for the specified CPS sample and years. Useful for
#' targets-based workflows where file dependencies need to be tracked.
#' The result can be passed directly to `load_cps()` or the `load_org()`,
#' `load_basic()`, etc. wrappers in place of `.years`.
#'
#' @param sample CPS sample ("org", "basic", "march", "may")
#' @param years years of CPS data (integers)
#' @param extracts_dir directory where EPI extracts are
#' @param .quiet Logical. Suppress informational messages? Defaults to
#'   `getOption("epiextractr.quiet", FALSE)`.
#' @return A character vector of file paths with class `"cps_files"`
#' @export
#' @examples
#' cps_files("org_sample", 2023:2025)
#'
#' # Pass directly to load functions:
#' load_org_sample(cps_files("org_sample", 2023:2025), year, month, wage)
#'
#' \dontrun{
#' # Use with targets
#' library(tarchetypes)
#' tar_assign({
#'   org_files = cps_files("org", 2020:2025) |> tar_file()
#'   org_data = load_org(org_files, year, month, wage) |> tar_target()
#' })
#' }
cps_files <- function(
  sample,
  years,
  extracts_dir = NULL,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  sample <- valid_sample_name(sample)
  extracts_dir <- resolve_extracts_dir(sample, extracts_dir)

  files <- unlist(lapply(years, function(year) {
    year_files <- resolve_year_files(sample, year, extracts_dir)
    warn_partial_year(year_files, sample, year, .quiet)
    year_files
  }))

  warn_known_gaps(years, .quiet)

  structure(files, class = "cps_files", sample = sample)
}


#' Load a selection of EPI CPS extracts
#'
#' Select years and variables from the EPI CPS microdata extracts. These data
#' must first be downloaded using `download_cps()` or from
#' \url{https://microdata.epi.org}.
#'
#' All columns are selected if `...` is missing.
#'
#' `.years` accepts either integer years or the result of `cps_files()`.
#' When a `cps_files` object is passed, the files are read directly and
#' `.extracts_dir` is ignored.
#'
#' `.extracts_dir` is required, but if NULL it will look for the environment variables
#' ```
#' EPIEXTRACTS_CPSBASIC_DIR
#' EPIEXTRACTS_CPSORG_DIR
#' EPIEXTRACTS_CPSMAY_DIR
#' ```
#' which could be set in your .Renviron, for example.
#'
#' @describeIn load_cps base function group
#'
#' @param .sample CPS sample ("org", "basic", "march", "may")
#' @param .years years of CPS data (integers), or a `cps_files` object
#' @param ... tidy selection of variables to keep
#' @param .extracts_dir directory where EPI extracts are
#' @param .version_check when TRUE, confirm data are same version
#' @param .quiet Logical. Suppress informational messages? Defaults to
#'   `getOption("epiextractr.quiet", FALSE)`.
#' @return A tibble of CPS microdata
#' @export
#' @importFrom magrittr %>%
#' @importFrom haven labelled
#' @importFrom dplyr select
#' @importFrom rlang enquos
#' @examples
#' # Load all columns from the demonstration sample
#' load_org_sample(2023:2024)
#'
#' # Load a selection of columns
#' load_org_sample(2023:2025, year, month, female, wage)
#'
#' # Use cps_files() for targets workflows:
#' org_files = cps_files("org_sample", 2023:2025)
#' load_org_sample(org_files, year, month, wage)
#'
#' \dontrun{
#' # Load real CPS ORG data (requires downloaded extracts):
#' load_org(2010:2019, year, month, orgwgt, female, wage)
#' # This is equivalent to
#' load_cps("org", 2010:2019, year, month, orgwgt, female, wage)
#' }
load_cps <- function(
  .sample,
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  # retrieve valid sample name
  .sample <- valid_sample_name(.sample)

  if (is.character(.years)) {
    .files <- .years

    # catch stringified years like c("2023", "2025")
    if (!all(grepl("\\.feather$", .files))) {
      cli::cli_abort(
        "{.arg .years} must be numeric years or file paths from {.fun cps_files}."
      )
    }

    # validate sample prefix
    if (!all(grepl(paste0("epi_cps", .sample), basename(.files)))) {
      detected <- sub("^epi_cps", "", basename(.files[1]))
      detected <- sub("_\\d.*", "", detected)
      cli::cli_abort(c(
        "{.arg .years} contains {.val {detected}} files, but expected {.val {(.sample)}}.",
        "i" = "Use {.fun {paste0('load_', detected)}} or pass files from {.code cps_files(\"{(.sample)}\", ...)}."
      ))
    }

    # read each file directly
    the_data <- lapply(.files, function(f) {
      arrow::read_feather(f, col_select = c(...))
    }) %>%
      bind_cps(version_check = .version_check)
  } else {
    # resolve directory
    .extracts_dir <- resolve_extracts_dir(.sample, .extracts_dir)

    # read the data into single list
    the_data <-
      lapply(.years, function(x) {
        read_single_year(
          sample = .sample,
          year = x,
          ...,
          extracts_dir = .extracts_dir,
          version_check = .version_check,
          .quiet = .quiet
        )
      }) %>%
      # stack the data and add version attributes
      bind_cps(version_check = .version_check)

    warn_known_gaps(.years, .quiet)
  }

  # display version information
  if (!.quiet) {
    cli::cli_alert_info("Using {attr(the_data, 'label')}")
  }

  # re-order & return columns
  dots <- enquos(...)
  if (length(dots) == 0) {
    the_data
  } else {
    select(the_data, ...)
  }
}

#' @export
#' @describeIn load_cps Load CPS Basic Monthly files
load_basic <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  load_cps(
    .sample = "basic",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check,
    .quiet = .quiet
  )
}

#' @export
#' @describeIn load_cps Load CPS May files
load_may <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  load_cps(
    .sample = "may",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check,
    .quiet = .quiet
  )
}

#' @export
#' @describeIn load_cps Load CPS ORG files
load_org <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  load_cps(
    .sample = "org",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check,
    .quiet = .quiet
  )
}

#' @export
#' @describeIn load_cps Load a demonstration sample of CPS ORG files; only useful for examples
load_org_sample <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  load_cps(
    .sample = "org_sample",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check,
    .quiet = .quiet
  )
}


# load_cps Load CPS March files
load_march <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
) {
  load_cps(
    .sample = "march",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check,
    .quiet = .quiet
  )
}


read_single_year <- function(
  sample,
  year,
  ...,
  extracts_dir,
  version_check = TRUE,
  .quiet = FALSE
) {
  files <- resolve_year_files(sample, year, extracts_dir)
  warn_partial_year(files, sample, year, .quiet)

  if (length(files) == 1) {
    return(arrow::read_feather(files, col_select = c(...)))
  }

  # multiple files = monthly data
  monthly_data <- lapply(files, function(f) {
    arrow::read_feather(f, col_select = c(...))
  })

  return(bind_cps(monthly_data, version_check))
}

bind_cps <- function(x, version_check) {
  versions <- purrr::map(x, ~ attr(.x, "label")) %>% unlist()
  full_version <- unique(versions)
  if (!length(full_version) == 1) {
    if (version_check) {
      cli::cli_abort(c(
        "Version conflicts among multiple data files.",
        "i" = "Re-download the most current version with {.fun download_cps}."
      ))
    } else {
      cli::cli_warn(c(
        "You are using multiple, different versions of the EPI CPS extracts.",
        "i" = "Re-download the most current version with {.fun download_cps}."
      ))
    }
  }

  x <- data.table::rbindlist(x, use.names = TRUE) %>%
    tibble::as_tibble()

  attr(x, "label") <- full_version
  attr(x, "version") <- sub(".*Version ", "", full_version)

  x
}
