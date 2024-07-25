# check sample name validity
valid_sample_name <- function(x) {

  # check sample
  x <- tolower(x)
  if (! x %in% c("basic", "march", "may", "org", "org_sample")) {
    rlang::abort("Available CPS samples: Basic, March, May, ORG")
  }
  x
}

# check this is an EPI CPS extract from label info
assert_valid_extract <- function(x) {
  if (length(grep("^EPI CPS ", attributes(x)$label)) == 1) {
    return(invisible)
  }
  else {
    rlang::abort(
      paste(deparse(substitute(x)), "does not appear to be a valid EPI Extract")
    )
  }
}
