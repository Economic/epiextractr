# check sample name validity
valid_sample_name <- function(x) {
  # check sample
  x <- tolower(x)
  if (!x %in% c("basic", "march", "may", "org", "org_sample")) {
    cli::cli_abort("Available CPS samples: Basic, March, May, ORG.")
  }
  x
}

# check this is an EPI CPS extract from label info
assert_valid_extract <- function(x) {
  if (length(grep("EPI CPS ", attributes(x)$label)) == 1) {
    return(invisible(x))
  } else {
    cli::cli_abort(
      "{.var {deparse(substitute(x))}} does not appear to be a valid EPI Extract."
    )
  }
}

# resolve the extracts directory for a given sample
resolve_extracts_dir <- function(sample, extracts_dir) {
  if (!is.null(extracts_dir)) {
    return(extracts_dir)
  }

  if (sample == "org_sample") {
    return(system.file("extdata", package = "epiextractr", mustWork = TRUE))
  }

  dir <- Sys.getenv(paste0("EPIEXTRACTS_CPS", toupper(sample), "_DIR"))
  if (dir == "") {
    dir <- getwd()
  }
  dir
}

# filename helpers
annual_filename <- function(sample, year) {
  paste0("epi_cps", sample, "_", year, ".feather")
}

monthly_prefix <- function(sample, year) {
  paste0("epi_cps", sample, "_", year, "_")
}

# resolve file paths for a single year (annual file first, monthly fallback)
resolve_year_files <- function(sample, year, extracts_dir) {
  extracts_dir <- normalizePath(extracts_dir, mustWork = FALSE)
  full_feather_filename <- file.path(
    extracts_dir,
    annual_filename(sample, year)
  )

  if (file.exists(full_feather_filename)) {
    return(full_feather_filename)
  }

  prefix <- monthly_prefix(sample, year)
  monthly_files <- dir(
    extracts_dir,
    pattern = paste0("^", prefix, ".*\\.feather$"),
    full.names = TRUE
  )

  if (length(monthly_files) > 0) {
    months <- sub(paste0(".*", prefix), "", basename(monthly_files))
    months <- sub("\\.feather$", "", months)
    return(monthly_files[order(as.numeric(months))])
  }

  cli::cli_abort(c(
    "{.path {extracts_dir}} does not contain data for the year {year}.",
    "i" = "Specify a valid location with the {.arg .extracts_dir} argument."
  ))
}

# warn about partial-year (monthly) data
warn_partial_year <- function(files, sample, year, .quiet = FALSE) {
  is_monthly <- !any(basename(files) == annual_filename(sample, year))
  if (is_monthly && !.quiet) {
    prefix <- monthly_prefix(sample, year)
    months <- sub(paste0(".*", prefix), "", basename(files))
    months <- sub("\\.feather$", "", months)
    months <- paste(months, collapse = " ")
    cli::cli_alert_warning("Data for year {year} only includes months {months}")
  }
  is_monthly
}

# known data gaps — update this list when new gaps are identified
known_data_gaps <- list(
  "2025" = "October"
)

# warn about known data gaps for requested years
warn_known_gaps <- function(years, .quiet = FALSE) {
  if (.quiet) {
    return(invisible())
  }
  for (year in as.character(years)) {
    if (year %in% names(known_data_gaps)) {
      gap <- known_data_gaps[[year]]
      cli::cli_alert_warning("Data for year {year} excludes {gap}")
    }
  }
}
