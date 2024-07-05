#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_print_dt_table_server("samedi_court")
  mod_print_dt_table_server("samedi_long")
  mod_print_dt_table_server("dimanche_court")
  mod_print_dt_table_server("dimanche_long")
  mod_print_dt_table_server("semaine")
}
