#' create_gt_alplakes_table
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

create_gt_alplakes_table <- function(table_profondeur) {
  table_profondeur |>
    gt::gt() |>
    gt::tab_header(
      title = gt::md("**Température de l'eau à Hermance**"),
    ) |>
    gt::tab_spanner_delim(delim = " ") %>%
    gt::data_color(columns = -profondeur, palette = "Blues")  |>
    gt::fmt(columns = profondeur,
            fns = \(x) paste(x, "m"))
}
