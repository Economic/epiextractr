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
crosstab <- function(df, x, y = NULL, w = NULL, col = FALSE, row = FALSE) {

  # need to add row and column percentages
  arg_y <- rlang::enquo(y)

  # default to counts
  if (col == FALSE & row == FALSE) {
    # one-way tabulation
    if (rlang::quo_is_null(arg_y)) {
      df <- df %>%
        dplyr::count({{ x }}, wt = {{ w }}) %>%
        dplyr::mutate()
    }
    # two-way tabulation
    else {
      df <- df %>%
        dplyr::count({{ x }}, {{ y }}, wt = {{ w }}) %>%
        dplyr::mutate("{{ y }}" := labelled::to_character({{ y }}))

    }

    return(df)
  }

  # row summary
  if (col == FALSE & row == TRUE) {
    # one-way tabulation
    if (rlang::quo_is_null(arg_y)) {
      df <- df %>%
        dplyr::count({{ x }}, wt = {{ w }}) %>%
        dplyr::mutate() %>%
        dplyr::mutate(freq = n/sum(n), cumul = cumsum(freq))
    }
    # two-way tabulation
    else {
      df <- df %>%
        dplyr::count({{ x }}, {{ y }}, wt = {{ w }}) %>%
        dplyr::mutate("{{ y }}" := labelled::to_character({{ y }})) %>%
        dplyr::group_by({{ x }}) %>%
        dplyr::mutate(freq = n/sum(n), cumul = cumsum(freq))

    }

    return(df)
  }

  # column summary
  if (col == TRUE & row == FALSE) {
    # one-way tabulation
    if (rlang::quo_is_null(arg_y)) {
      df <- df %>%
        dplyr::count({{ x }}, wt = {{ w }}) %>%
        dplyr::mutate() %>%
        dplyr::mutate(freq = n/sum(n), cumul = cumsum(freq))
    }
    # two-way tabulation
    else {
      df <- df %>%
        dplyr::count({{ x }}, {{ y }}, wt = {{ w }}) %>%
        dplyr::mutate("{{ y }}" := labelled::to_character({{ y }})) %>%
        dplyr::group_by({{ y }}) %>%
        dplyr::mutate(freq = n/sum(n), cumul = cumsum(freq))

    }

    return(df)
  }

  ## NEED TO FIGURE OUT WHAT ERROR MESSAGE GOES IN HERE
  if (col == TRUE & row == TRUE) {
    print(paste("Error"))
  }


}
