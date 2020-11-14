#' check sample name validity
#'
#' @param x sample name
#' @return valid, lowercase sample name
valid_sample_name <- function(x) {

  # check sample
  x <- tolower(x)
  if (! x %in% c("basic", "march", "may", "org")) {
    rlang::abort("Available CPS samples: Basic, March, May, ORG")
  }
  x
}


