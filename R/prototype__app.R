# UI with added refresh button
ui <- page_navbar(
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
        actionButton("prev_day", "", icon = icon("chevron-left")),
        textOutput("current_date"),
        actionButton("next_day", "", icon = icon("chevron-right")),
        # Add refresh button
        actionButton("refresh_data", "", icon = icon("sync"),
                     class = "btn-outline-secondary ms-2",
                     title = "Rafraîchir les données")
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
        p("Cette application affiche les données de température du Lac Léman à différentes profondeurs."),
        p("Les données montrent comment la température varie avec la profondeur et au fil du temps."),
        h5("Comment utiliser:"),
        tags$ul(
          tags$li("Consultez le tableau des températures par date"),
          tags$li("Utilisez les boutons fléchés pour naviguer entre les jours"),
          tags$li("Le tableau montre les relevés de température à différentes profondeurs")
        ),
        h5("Remarques:"),
        p("Les données sont récupérées en temps réel depuis l'API alplakes lors du chargement de l'application.")
      )
    )
  ),
  # Mobile-friendly styling
  theme = bs_theme(
    version = 5,
    bootswatch = "cerulean"
  )
)

# Server function with dynamic data loading
server <- function(input, output, session) {
  # Create a reactive value to store the data
  data_store <- reactiveVal(NULL)

  # Load data on startup using an observer
  observe({
    # Include a message to show data is being fetched
    message("Fetching fresh data from alplakes API...")

    # Get fresh data from the API
    request_data <- get_data_from_alplakes()

    # Process the data
    clean_alpdata <- clean_alplakes_data(request_data)
    tables_to_plot <- create_alplakes_tables(clean_alpdata)

    # Store the data in our reactive value
    data_store(tables_to_plot)
  })

  # Reactive value to track the current date index
  current_date_idx <- reactiveVal(1)

  # Get all unique dates from the dataset
  all_dates <- reactive({
    req(data_store())
    data_store()$small_show_table_day %>%
      names() %>%
      lubridate::date() %>%
      unique() %>%
      sort()
  })

  # Function to display the current date's data
  display_current_data <- reactive({
    req(data_store(), all_dates(), current_date_idx())

    date_idx <- current_date_idx()
    date_to_show <- as.character(all_dates()[date_idx])

    # Add validation to ensure the date exists in the data
    validate(
      need(date_to_show %in% names(data_store()$small_show_table_day),
           "Data for this date is not available")
    )

    data_store()$small_show_table_day[[date_to_show]]
  })

  # Format the current date for display
  output$current_date <- renderText({
    req(all_dates(), current_date_idx())
    format(all_dates()[current_date_idx()], "%A, %B %d, %Y")
  })

  # Render the temperature table
  mod_gt_plot_table_server("gt_plot_table_1", display_current_data)

  # Handle previous day button
  observeEvent(input$prev_day, {
    if (current_date_idx() > 1) {
      current_date_idx(current_date_idx() - 1)
    }
  })

  # Handle next day button
  observeEvent(input$next_day, {
    if (current_date_idx() < length(all_dates())) {
      current_date_idx(current_date_idx() + 1)
    }
  })

  # Add an option to refresh data manually (optional feature)
  observeEvent(input$refresh_data, {
    # Include a message to show data is being fetched
    message("Refreshing data from alplakes API...")

    # Get fresh data from the API
    request_data <- get_data_from_alplakes()

    # Process the data
    clean_alpdata <- clean_alplakes_data(request_data)
    tables_to_plot <- create_alplakes_tables(clean_alpdata)

    # Update the stored data
    data_store(tables_to_plot)

    # Reset to first date when refreshing data
    current_date_idx(1)
  })
}

# Run the application
shinyApp(ui, server)
