#' crosstab: cross-tabulations
#'
#' @param data a data frame
#' @param ... one or two variables, for a one- or two-way cross-tabulation
#' @param w weight
#' @param col column percentages in a two-way cross-tabulation
#' @param row row percentages in a two-way cross-tabulation
#' @return a tibble
#' @export
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @examples crosstab(mtcars, cyl)
#' @examples crosstab(mtcars, cyl, gear)
#' @examples crosstab(mtcars, cyl, gear, w = mpg, col = TRUE)
crosstab <- function(data, ... , w = NULL, col = FALSE, row = FALSE) {

  # parse col names
  col_names <- rlang::enquos(...)

  # syntax checks
  if (length(col_names) > 2) {
    stop("Only one-way or two-way crosstabs allowed")
  }

  # ungroup data
  data <- dplyr::ungroup(data)

  # prep for all crosstabs
  out <- dplyr::count(data, ..., wt = {{ w }})

  # One-way crosstab
  if (length(col_names) == 1) {
    if (col | row) {
      warning("Column and row percentage options are ignored in a one-way cross-tabulation")
    }

    out <- out %>%
      dplyr::mutate(
        percent = .data$n/sum(.data$n),
        cumul_percent = cumsum(.data$percent)) %>%
      dplyr::as_tibble()
  }

  # Two-way crosstab
  if (length(col_names) == 2) {

    # col & row percentages
    if (col & row) {
      stop("You cannot select both col and row percentage options; select either or neither, but not both.")
    }

    # col percentages
    if (col & !row) {
      out <- out %>%
        dplyr::group_by(!! col_names[[2]]) %>%
        dplyr::mutate(n = .data$n / sum(.data$n)) %>%
        dplyr::ungroup()
    }

    # row percentages
    if (!col & row) {
      out <- out %>%
        dplyr::group_by(!! col_names[[1]]) %>%
        dplyr::mutate(n = .data$n / sum(.data$n)) %>%
        dplyr::ungroup()
    }

    out <- out %>%
      dplyr::mutate(dplyr::across(!! col_names[[2]], ~ as.character(haven::as_factor(.x)))) %>%
      tidyr::pivot_wider(id_cols = !! col_names[[1]], names_from = !! col_names[[2]], values_from = "n")
  }

  out

}


