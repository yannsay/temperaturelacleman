library(shiny)
library(bslib)
library(dplyr)
library(lubridate)
library(DT)

# Generate mock data for lake temperatures
set.seed(123)
create_mock_data <- function() {
  # Create dates from today-2 to today+7
  dates <- seq(from = Sys.Date() - 2, to = Sys.Date() + 7, by = "day")

  # Different depths in meters
  depths <- c(0, 5, 10, 15, 20, 30, 50)

  # Create all combinations of dates and depths
  data <- expand.grid(date = dates, depth = depths)

  # Generate temperature data (realistic pattern: warmer at surface, cooler at depth)
  data$temperature <- 20 - (data$depth * 0.3) +
    sin(as.numeric(data$date) / 10) * 2 + # Seasonal variation
    rnorm(nrow(data), 0, 0.5)  # Random variation

  return(data)
}

lake_data <- create_mock_data()

ui <- page_navbar(
  title = "Lake Temperature Monitor",
  id = "nav",

  # Landing page with temperature data
  nav_panel(
    title = "Temperature Data",
    icon = icon("temperature-half"),
    card(
      card_header("Lake Temperature by Depth"),
      id = "date_display",
      div(
        class = "d-flex justify-content-between align-items-center",
        actionButton("prev_day", "", icon = icon("chevron-left")),
        textOutput("current_date"),
        actionButton("next_day", "", icon = icon("chevron-right"))
      ),
      card_body(
        DTOutput("temp_table")
      ),
      card_footer(
        "Use arrows to navigate between days"
      )
    )
  ),

  # Info/ReadMe page
  nav_panel(
    title = "Info",
    icon = icon("info-circle"),
    card(
      card_header("About This App"),
      card_body(
        h4("Lake Temperature Monitor"),
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
  current_date_idx <- reactiveVal(3)  # Start with today (index 3)

  # Get all unique dates from the dataset
  all_dates <- reactive({
    sort(unique(lake_data$date))
  })

  # Function to display the current date's data
  display_current_data <- reactive({
    date_to_show <- all_dates()[current_date_idx()]
    lake_data %>%
      filter(date == date_to_show) %>%
      arrange(depth)
  })

  # Format the current date for display
  output$current_date <- renderText({
    format(all_dates()[current_date_idx()], "%A, %B %d, %Y")
  })

  # Render the temperature table
  output$temp_table <- renderDT({
    data <- display_current_data()
    datatable(
      data[, c("depth", "temperature")],
      #colnames = c("Depth (m)" = "depth", "Temperature (°C)" = "temperature"),
      options = list(
        dom = 't',
        pageLength = 10,
        scrollY = "50vh",
        searching = FALSE,
        ordering = TRUE
      ),
      rownames = FALSE
    ) %>%
      formatRound("temperature", 1)
  })

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
