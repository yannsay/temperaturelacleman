# # devtools::load_all()
# # Generate mock data for lake temperatures
#
request_data <- get_data_from_alplakes()
clean_alpdata <- clean_alplakes_data(request_data)
tables_to_plot <- create_alplakes_tables(clean_alpdata)

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
        actionButton("next_day", "", icon = icon("chevron-right"))
      ),
      card_body(
        mod_gt_plot_table_ui("gt_plot_table_1")
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
        p("This app displays temperature data for a fictional lake at various depths."),
        p("The data shows how temperature changes with depth and over time."),
        h5("How to use:"),
        tags$ul(
          tags$li("View the temperature table by date"),
          tags$li("Use arrow buttons to navigate between days"),
          tags$li("The table shows temperature readings at different depths")
        ),
        h5("Notes:"),
        p("This is a mock application with simulated data.")
      )
    )
  ),

  # Mobile-friendly styling
  theme = bs_theme(
    version = 5,
    bootswatch = "cerulean"#,
    #base_font = font_google("Roboto")
  )
)

server <- function(input, output, session) {
  # Reactive value to track the current date index
  current_date_idx <- reactiveVal(1)  # Start with today (index 3)

  # Get all unique dates from the dataset
  all_dates <- reactive({
    tables_to_plot$small_show_table_day %>% names() %>% lubridate::date() %>% unique() %>% sort()
  })

  # Function to display the current date's data
  display_current_data <- reactive({
    date_idx <- current_date_idx()
    date_to_show <- as.character(all_dates()[date_idx])
    tables_to_plot$small_show_table_day[[date_to_show]]
  })

  # Format the current date for display
  output$current_date <- renderText({
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

}

shinyApp(ui, server)
