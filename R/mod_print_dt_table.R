#' print_dt_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_print_dt_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    DTOutput(ns("data_table"))
  )
}

#' print_dt_table Server Functions
#'
#' @noRd
mod_print_dt_table_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$data_table <- DT::renderDT({
      random_DT(10, 5)
    })

  })
}

## To be copied in the UI
# mod_print_dt_table_ui("print_dt_table_1")

## To be copied in the server
# mod_print_dt_table_server("print_dt_table_1")
