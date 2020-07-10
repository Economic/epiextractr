#' crosstab: cross-tabulations
#'
#' @param df a data frame
#' @param x first variable
#' @param y second variable
#' @param w weight
#' @param s summary statistic
#' @return a tibble
#' @export
#' @importFrom magrittr %>%
#' @importFrom rlang :=
#' @examples crosstab(mtcars, cyl, gear)
test_fun <- function(df, x, y = NULL, w = NULL, col = FALSE, row = TRUE) {

  # need to add row and column percentages
  arg_y <- rlang::enquo(y)
  arg_col <- rlang::enquo(col)
  arg_row <- rlang::enquo(row)

# row summary statistics is the default
  if (!isTRUE(arg_col) & isTRUE(arg_row)) {

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

    #return(df)

  }

  if (isTRUE(arg_col) & !isTRUE(arg_row)) {
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

    #return(df)

  }

  return(df)

}


