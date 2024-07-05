#' apropos UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_apropos_ui <- function(id){
  ns <- NS(id)
  tagList(
    includeMarkdown(
      system.file("app/www/apropos.md", package = "temperatureprofondeurleman")
    )
  )
}

#' apropos Server Functions
#'
#' @noRd
mod_apropos_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_apropos_ui("apropos_1")

## To be copied in the server
# mod_apropos_server("apropos_1")
