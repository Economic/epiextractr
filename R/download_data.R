#' Download CPS data
#'
#' More description
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
download_cps <- function(sample,
                         extracts_dir = NULL,
                         overwrite = FALSE) {

  # retrieve valid sample name
  sample <- valid_sample_name(sample)

  # require extracts dir
  if (is.null(extracts_dir)) {
    rlang::abort("extracts_dir must specify a directory into which to extract the data")
  }
  if (!file.exists(extracts_dir)) {
    rlang::abort(paste("Directory", extracts_dir, "does not exist"))
  }

  # deal with existing files
  existing_files <- dir(extracts_dir, pattern = paste0("epi_cps", sample))
  if (!overwrite & length(existing_files) != 0) {
    rlang::abort(paste(extracts_dir, "contains existing EPI CPS", sample, "extracts. Please delete them or specify overwrite = TRUE"))
  }
  else if (overwrite & length(existing_files) != 0) {
    message(paste("Deleting existing EPI CPS", sample, "extracts in", extracts_dir, "..."))
    unlink(existing_files)
  }
  else if (overwrite & length(existing_files) == 0) {
    warning(paste("You requested to overwrite existing EPI CPS", sample, "extracts, but no such files were already in specified extracts_dir"))
    warning(paste("We downloaded the data to", extracts_dir, "but you might want to double-check if that's really where you wanted the data."))
  }

  # define compressed file names
  download_path <- file.path("https://microdata.epi.org",
                             paste0("epi_cps", sample, ".tar.gz"))

  # temporarily change download timeout option
  op <- options(timeout = max(600, getOption("timeout")))
  on.exit(options(op))

  # download & extract the data
  temp_dest <- tempfile()
  download.file(download_path, temp_dest)

  message("Decompressing files...")
  untar(temp_dest, exdir = path.expand(extracts_dir))

  unlink(temp_dest)
}

