#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
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

  # Render dynamic navigation buttons based on current position
  output$navigation_buttons <- renderUI({
    req(all_dates(), current_date_idx())

    # Get current index and max index
    idx <- current_date_idx()
    max_idx <- length(all_dates())

    # Create UI elements
    div(
      class = "d-flex justify-content-between align-items-center w-100",

      # Conditional left/prev button
      if(idx > 1) {
        actionButton("prev_day", "", icon = icon("chevron-left"))
      } else {
        # Empty div to maintain spacing when button is hidden
        div(style = "width: 38px;") # Approximate width of a button
      },

      # Date display (in the middle)
      div(
        class = "text-center flex-grow-1",
        textOutput("current_date")
      ),

      # Conditional right/next button
      if(idx < max_idx) {
        actionButton("next_day", "", icon = icon("chevron-right"))
      } else {
        # Empty div to maintain spacing when button is hidden
        div(style = "width: 38px;") # Approximate width of a button
      }
    )
  })

  # Format the current date for display (now used within the uiOutput)
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
}
