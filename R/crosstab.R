#' crosstab: cross-tabulations
#'
#' @param df a data frame
#' @param x first variable
#' @param y second variable
#' @param w weight
#' @return a tibble
#' @export
#' @importFrom magrittr %>%
#' @importFrom rlang :=
#' @examples crosstab(mtcars, cyl, gear)
crosstab <- function(df, x, y = NULL, w = NULL) {

  # need to add row and column percentages
  arg_y <- rlang::enquo(y)

  # one-way tabulation
  if (rlang::quo_is_null(arg_y)) {
    df <- df %>%
      dplyr::count({{ x }}, wt = {{ w }}) %>%
      dplyr::mutate()
  }
  # two-way tabulation
  else {
    df <- df %>%
      dplyr::count({{ x }}, {{ y }}) %>%
      dplyr::mutate("{{ y }}" := labelled::to_character({{ y }})) %>%
      tidyr::pivot_wider({{ x }}, names_from = {{ y }}, values_from = "n")
  }

  return(df)

}
