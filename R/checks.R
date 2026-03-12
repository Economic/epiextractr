# check sample name validity
valid_sample_name <- function(x) {
  # check sample
  x <- tolower(x)
  if (!x %in% c("basic", "march", "may", "org", "org_sample")) {
    rlang::abort("Available CPS samples: Basic, March, May, ORG")
  }
  x
}

# check this is an EPI CPS extract from label info
assert_valid_extract <- function(x) {
  if (length(grep("EPI CPS ", attributes(x)$label)) == 1) {
    return(invisible)
  } else {
    rlang::abort(
      paste(deparse(substitute(x)), "does not appear to be a valid EPI Extract")
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

# resolve file paths for a single year (annual file first, monthly fallback)
resolve_year_files <- function(sample, year, extracts_dir) {
  feather_filename <- paste0("epi_cps", sample, "_", year, ".feather")
  full_feather_filename <- file.path(extracts_dir, feather_filename)

  if (file.exists(full_feather_filename)) {
    return(full_feather_filename)
  }

  monthly_prefix <- paste0("epi_cps", sample, "_", year, "_")
  monthly_files <- dir(
    extracts_dir,
    pattern = paste0("^", monthly_prefix, ".*\\.feather$"),
    full.names = TRUE
  )

  if (length(monthly_files) > 0) {
    months <- sub(paste0(".*", monthly_prefix), "", basename(monthly_files))
    months <- sub("\\.feather$", "", months)
    return(monthly_files[order(as.numeric(months))])
  }

  rlang::abort(paste(
    extracts_dir,
    "does not contain data for the year",
    year,
    "\nPlease specify a valid location for the data with the argument .extracts_dir"
  ))
}
