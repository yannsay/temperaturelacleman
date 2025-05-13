#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_navbar(
      title = "Température du lac Léman",
      nav_panel(title = "Hermance",
                p("First page content."),
                tabsetPanel(
                  tabPanel("Samedi",
                           h2("Samedi"),
                           mod_print_dt_table_ui("samedi_court"),
                           mod_print_dt_table_ui("samedi_long")),
                  tabPanel("Dimanche",
                           h2("Dimanche"),
                           mod_print_dt_table_ui("dimanche_court"),
                           mod_print_dt_table_ui("dimanche_long")),
                  tabPanel("Lundi",
                           h2("Lundi"),
                           mod_print_dt_table_ui("lundi_court"),
                           mod_print_dt_table_ui("lundi_long")),
                )),
      nav_panel(title = "Autres", p("Second page content.")),
      nav_panel(title = "Lisez-moi",
                mod_apropos_ui("apropos1"))#,
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "temperatureprofondeurleman"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
