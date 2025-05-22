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
      title = "Température du Lac Léman",
      id = "nav",
      # Landing page with temperature data
      nav_panel(
        title = "Données des températures",
        icon = icon("temperature-half"),
        card(
          id = "date_display",
          div(
            class = "d-flex justify-content-between align-items-center",
            # Replace static buttons with a UI output for dynamic rendering
            uiOutput("navigation_buttons")
          ),
          card_body(
            # Add a loading spinner for when data is being fetched
            shinycssloaders::withSpinner(
              mod_gt_plot_table_ui("gt_plot_table_1")
            )
          ),
          card_footer(
            "Utilisez les flèches pour changer de jour"
          )
        )
      ),
      # Info/ReadMe page
      nav_panel(
        title = "Info",
        icon = icon("info-circle"),
        card(
          card_header("A propos"),
          card_body(
            h4("Température du Lac Léman"),
            p("Cette application affiche les données de température du Lac Léman vers Hermance à différentes profondeurs."),
            h5("Comment utiliser:"),
            tags$ul(
              tags$li("Consultez le tableau des températures par date"),
              tags$li("Utilisez les boutons fléchés pour naviguer entre les jours"),
              tags$li("Le tableau montre les relevés de température à différentes profondeurs")
            ),
            h5("Remarques:"),
            tags$ul(
              tags$li("Les données sont récupérées en temps réel depuis l'API alplakes lors du chargement de l'application."),
              tags$li("Alplakes API semble générer uniquement les prédictions d'une semaine, c'est à dire, maximum le dimanche de la semaine en cours."),
              tags$li("Les températures sont des prédictions, elles peuvent changer d'un jour à l'autre."),
              tags$li("Plus d'informations disponibles sur ",
                      tags$a(
                        href = "https://www.alplakes.eawag.ch/",
                        "AlpLakes",
                        target = "_blank"
                      ))
            ),
            h4("Auteur"),
            p("",
              tags$a(href =  "https://yannsay.github.io/portfolio/",
                     "Yann Say",
                     target = "_blank"))
          )
        )
      ),
      # Mobile-friendly styling
      theme = bs_theme(
        version = 5,
        bootswatch = "cerulean"
      )
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
      app_title = "temperaturelacleman"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
