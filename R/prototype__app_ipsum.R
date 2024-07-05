library(shinipsum)
library(shiny)
library(DT)
library(bslib)
library(markdown)
source("R/mod_print_dt_table.R")
source("R/mod_apropos.R")
ui <- page_navbar(
  title = "Température du lac Léman",
  # sidebar = color_by,
  # inverse = TRUE,
  nav_panel(title = "Hermance",
            p("First page content."),
            tabsetPanel(
              tabPanel("Week-end",
                       fluidRow(column(6,
                                       h2("Samedi"),
                                       mod_print_dt_table_ui("samedi_court"),
                                       mod_print_dt_table_ui("samedi_long")),
                                column(6,
                                       h2("Dimanche"),
                                       mod_print_dt_table_ui("dimanche_court"),
                                       mod_print_dt_table_ui("dimanche_long")))
              ),
              tabPanel("7 jours",
                       h2("Semaine"),
                       mod_print_dt_table_ui("semaine"))
            )),
  nav_panel(title = "Autres", p("Second page content.")),
  nav_panel(title = "Lisez-moi", p("lalala"))#,
  # nav_spacer(),
  # nav_menu(
  #   title = "Links",
  #   align = "right",
  #   nav_item(tags$a("Posit", href = "https://posit.co")),
  #   nav_item(tags$a("Shiny", href = "https://shiny.posit.co"))
  #)
)

server <- function(input, output, session) {

  mod_print_dt_table_server("samedi_court")
  mod_print_dt_table_server("samedi_long")
  mod_print_dt_table_server("dimanche_court")
  mod_print_dt_table_server("dimanche_long")
  mod_print_dt_table_server("semaine")


}
shinyApp(ui, server)
