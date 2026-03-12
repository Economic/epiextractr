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
#' @return A character vector of file paths with class `"cps_files"`
#' @export
#' @examples
#' cps_files("org_sample", 2019:2023)
#'
#' # Pass directly to load functions:
#' load_org_sample(cps_files("org_sample", 2019:2023), year, month, wage)
#'
#' \dontrun{
#' # Use with targets
#' library(tarchetypes)
#' tar_assign({
#'   org_files = cps_files("org", 2020:2025) |> tar_file()
#'   org_data = load_org(org_files, year, month, wage) |> tar_target()
#' })
#' }
cps_files <- function(sample, years, extracts_dir = NULL) {
  sample <- valid_sample_name(sample)
  extracts_dir <- resolve_extracts_dir(sample, extracts_dir)

  files <- unlist(lapply(years, function(year) {
    year_files <- resolve_year_files(sample, year, extracts_dir)

    # check if files are monthly (not a single annual file)
    annual_filename <- paste0("epi_cps", sample, "_", year, ".feather")
    is_monthly <- !any(basename(year_files) == annual_filename)
    if (is_monthly) {
      monthly_prefix <- paste0("epi_cps", sample, "_", year, "_")
      months <- sub(paste0(".*", monthly_prefix), "", basename(year_files))
      months <- sub("\\.feather$", "", months)
      months <- paste(months, collapse = " ")
      message(paste("Data for year", year, "only includes months", months))
    }

    year_files
  }))

  if (any(years == 2025)) {
    message("Data for year 2025 excludes October")
  }

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
#' @return A tibble of CPS microdata
#' @export
#' @importFrom magrittr %>%
#' @importFrom haven labelled
#' @importFrom dplyr select
#' @importFrom rlang enquos
#' @examples
#' # Load all columns from the demonstration sample
#' load_org_sample(2019:2020)
#'
#' # Load a selection of columns
#' load_org_sample(2019:2023, year, month, female, wage)
#'
#' # These are equivalent:
#' load_org_sample(2019:2020)
#' load_cps("org_sample", 2019:2020)
#'
#' # Use cps_files() for targets workflows:
#' load_org_sample(cps_files("org_sample", 2019:2023), year, month, wage)
#'
#' \dontrun{
#' # Load real CPS ORG data (requires downloaded extracts):
#' load_org(2010:2019, year, month, orgwgt, female, wage)
#' }
load_cps <- function(
  .sample,
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE
) {
  # retrieve valid sample name
  .sample <- valid_sample_name(.sample)

  if (is.character(.years)) {
    .files <- .years

    # catch stringified years like c("2023", "2025")
    if (!all(grepl("\\.feather$", .files))) {
      rlang::abort(
        "`.years` must be numeric years or file paths from `cps_files()`."
      )
    }

    # validate sample prefix
    if (!all(grepl(paste0("epi_cps", .sample), basename(.files)))) {
      rlang::abort(
        "`.years` contains files that do not match the expected sample type."
      )
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
          version_check = .version_check
        )
      }) %>%
      # stack the data and add version attributes
      bind_cps(version_check = .version_check)

    if (any(.years == 2025)) {
      message(paste("Data for year 2025 excludes October"))
    }
  }

  # display version information
  if (.version_check) {
    message(paste("Using", attr(the_data, "label")))
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
  .version_check = TRUE
) {
  load_cps(
    .sample = "basic",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check
  )
}

#' @export
#' @describeIn load_cps Load CPS May files
load_may <- function(.years, ..., .extracts_dir = NULL, .version_check = TRUE) {
  load_cps(
    .sample = "may",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check
  )
}

#' @export
#' @describeIn load_cps Load CPS ORG files
load_org <- function(.years, ..., .extracts_dir = NULL, .version_check = TRUE) {
  load_cps(
    .sample = "org",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check
  )
}

#' @export
#' @describeIn load_cps Load a demonstration sample of CPS ORG files; only useful for examples
load_org_sample <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE
) {
  load_cps(
    .sample = "org_sample",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check
  )
}


# load_cps Load CPS March files
load_march <- function(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE
) {
  load_cps(
    .sample = "march",
    .years = .years,
    ...,
    .extracts_dir = .extracts_dir,
    .version_check = .version_check
  )
}


read_single_year <- function(
  sample,
  year,
  ...,
  extracts_dir,
  version_check = TRUE
) {
  files <- resolve_year_files(sample, year, extracts_dir)

  # check if files are monthly (not a single annual file)
  annual_filename <- paste0("epi_cps", sample, "_", year, ".feather")
  is_monthly <- !any(basename(files) == annual_filename)

  if (is_monthly) {
    monthly_prefix <- paste0("epi_cps", sample, "_", year, "_")
    months <- sub(paste0(".*", monthly_prefix), "", basename(files))
    months <- sub("\\.feather$", "", months)
    months <- paste(months, collapse = " ")
    message(paste("Data for year", year, "only includes months", months))
  }

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
    message(
      "You are using multiple, different versions of the EPI CPS extracts."
    )
    message("This is not recommended.")
    message(
      "You should re-download the most current version of the data with download_cps()."
    )
    if (version_check) {
      rlang::abort("Version conflicts among multiple data files.")
    }
  }

  x <- data.table::rbindlist(x, use.names = TRUE) %>%
    tibble::as_tibble()

  attr(x, "label") <- full_version
  attr(x, "version") <- sub(".*Version ", "", full_version)

  x
}
