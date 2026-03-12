#' Download EPI CPS extracts data
#'
#' Download the EPI CPS extracts to your local machine
#'
#' @param sample CPS sample ("org", "basic", "may")
#' @param extracts_dir directory where EPI extracts should be placed
#' @param overwrite when TRUE, overwrite data
#'
#' @return downloaded files
#' @importFrom utils download.file untar
#' @export
#' @examples
#' \dontrun{
#' download_cps(sample = "march", extracts_dir = "/data/cps")
#' }
download_cps <- function(sample, extracts_dir = NULL, overwrite = FALSE) {
  # retrieve valid sample name
  sample <- valid_sample_name(sample)

  # require extracts dir
  if (is.null(extracts_dir)) {
    cli::cli_abort(
      "{.arg extracts_dir} must specify a directory into which to extract the data."
    )
  }
  if (!file.exists(extracts_dir)) {
    cli::cli_abort("Directory {.path {extracts_dir}} does not exist.")
  }

  # deal with existing files
  existing_files <- dir(extracts_dir, pattern = paste0("epi_cps", sample))
  if (!overwrite & length(existing_files) != 0) {
    cli::cli_abort(c(
      "{.path {extracts_dir}} contains existing EPI CPS {sample} extracts.",
      "i" = "Delete them or specify {.code overwrite = TRUE}."
    ))
  } else if (overwrite & length(existing_files) != 0) {
    cli::cli_alert_info(
      "Deleting existing EPI CPS {sample} extracts in {.path {extracts_dir}}..."
    )
    unlink(existing_files)
  } else if (overwrite & length(existing_files) == 0) {
    cli::cli_warn(c(
      "No existing EPI CPS {sample} extracts found in {.path {extracts_dir}}.",
      "i" = "Data was downloaded, but double-check this is the right location."
    ))
  }

  # define compressed file names
  download_path <- file.path(
    "https://microdata.epi.org",
    paste0("epi_cps", sample, ".tar.gz")
  )

  # temporarily change download timeout option
  op <- options(timeout = max(600, getOption("timeout")))
  on.exit(options(op))

  # download & extract the data
  temp_dest <- tempfile()
  download.file(download_path, temp_dest)

  cli::cli_alert_info("Decompressing files...")
  untar(temp_dest, exdir = path.expand(extracts_dir))

  unlink(temp_dest)
}
