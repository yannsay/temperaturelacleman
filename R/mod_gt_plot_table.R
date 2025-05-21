#' gt_plot_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_gt_plot_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    gt_output(ns("data_table"))
  )
}

#' gt_plot_table Server Functions
#'
#' @noRd
mod_gt_plot_table_server <- function(id, table_to_plot){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$data_table <- create_gt_alplakes_table(table_to_plot) |>
      render_gt()
  })
}

## To be copied in the UI
# mod_gt_plot_table_ui("gt_plot_table_1")

## To be copied in the server
# mod_gt_plot_table_server("gt_plot_table_1")
