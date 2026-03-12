#' Retrieve metadata from CPS extract
#'
#' @param x EPI CPS extract generated from `load_cps()` functions
#' @param version String version number
#' @return
#' `cps_version` and `cps_citation` return version or citation strings.
#'
#' `assert_cps_version` returns an error when the provided version is incorrect.
#' @examples
#' cps_org <- load_org_sample(2023:2025)
#' cps_citation(cps_org)
#' cps_version(cps_org)
#' @name cps_metadata

#' @export
#' @rdname cps_metadata
cps_version <- function(x) {
  assert_valid_extract(x)
  attributes(x)$version
}

#' @export
#' @rdname cps_metadata
cps_citation <- function(x) {
  assert_valid_extract(x)
  version_number <- attributes(x)$version
  year <- substr(version_number, 1, 4)

  cli::cli_alert_info(
    "You can cite {.var {deparse(substitute(x))}} as follows:"
  )

  paste0(
    "Economic Policy Institute. ",
    year,
    ". Current Population Survey Extracts, Version ",
    version_number,
    ", https://microdata.epi.org."
  )
}

#' @export
#' @rdname cps_metadata
assert_cps_version <- function(x, version) {
  version_number <- cps_version(x)
  if (!version_number == version) {
    cli::cli_abort(
      "Version number is {.val {version_number}}, not {.val {version}}."
    )
  }
}
