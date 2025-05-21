#' Build an API request for AlpLakes lake temperature data
#'
#' Creates an httr2 request to the AlpLakes API for retrieving water temperature data
#' for Lake Geneva. The function handles conversion from CET (Geneva time) to UTC for the API.
#'
#' @param day Character string or Date object representing the date for which to retrieve data
#'        in CET (Geneva time zone). Defaults to the current system date.
#' @param latitude Character string representing the latitude coordinate. Defaults to "46.303696".
#' @param longitude Character string representing the longitude coordinate. Defaults to "6.239853".
#'
#' @return An httr2 request object that can be further modified or executed.
#'
#' @details
#' The function checks if the requested date might be unavailable based on observed
#' API limitations. The AlpLakes API appears to only provide historical data up to the
#' previous week, with data organized by weeks starting on Sundays.
#'
#' The function converts the input date (assumed to be in CET) to UTC for the API request,
#' as the API requires timestamps in the format YYYYmmddHHMM in UTC time zone.
#'
#' @examples
#' \dontrun{
#' # Build a request for today
#' req <- build_alplakes_request()
#'
#' # Build a request for a specific date
#' req <- build_alplakes_request("2025-04-30")
#'
#' # Build a request for a specific location
#' req <- build_alplakes_request("2025-04-30", "46.45", "6.30")
#' }
#'
#'
#' @export
build_alplakes_request <- function(day = Sys.Date(),
                                   latitude = "46.303696",
                                   longitude = "6.239853") {
  day <- day %>% lubridate::date()
  # Convert CET (Geneva time) to UTC for the API
  # Create POSIXct objects for start and end of day in CET
  start_time_cet <- as.POSIXct(paste(day, "00:00:00"), tz = "CET")
  end_time_cet <- as.POSIXct(paste(day + 7, "23:00:00"), tz = "CET")

  # Convert to UTC
  start_time_utc <- format(start_time_cet, "%Y%m%d%H%M", tz = "UTC")
  end_time_utc <- format(end_time_cet, "%Y%m%d%H%M", tz = "UTC")

  # Build the request
  req <- httr2::request("https://alplakes-api.eawag.ch/simulations/depthtime/delft3d-flow/geneva/") |>
    httr2::req_user_agent("temperatureprofondeurleman (http://my.package.web.site)") |>
    httr2::req_url_path_append(start_time_utc) |>
    httr2::req_url_path_append(end_time_utc) |>
    httr2::req_url_path_append(latitude) |>
    httr2::req_url_path_append(longitude) |>
    httr2::req_url_query(variables = "temperature") |>
    httr2::req_headers(accept = "application/json")

  return(req)
}

#' Retrieve water temperature data from AlpLakes API
#'
#' Retrieves water temperature data for Lake Geneva from the AlpLakes API
#' for a specific date and location. The function handles time zone conversion
#' from CET (Geneva time) to UTC and provides appropriate warnings for unavailable data.
#'
#' @param day Character string or Date object representing the date for which to retrieve data
#'        in CET (Geneva time zone). Defaults to the current system date.
#' @param latitude Character string representing the latitude coordinate. Defaults to "46.303696".
#' @param longitude Character string representing the longitude coordinate. Defaults to "6.239853".
#'
#' @return A list containing the JSON response from the API, or NULL if the data is not available.
#'
#' @details
#' The function builds a request using \code{build_alplakes_request()} and then executes it.
#' Based on observed API behavior, data appears to be historical only, with no forecasts available
#' for the current or future weeks. Data is organized by weeks starting on Sundays.
#'
#' If the API returns an error about data not being available, the function returns NULL and
#' issues a warning with the error message.
#'
#' @examples
#' \dontrun{
#' # Get data for today
#' result <- get_data_from_alplakes()
#'
#' # Get data for a specific date
#' result <- get_data_from_alplakes("2025-04-30")
#'
#' # Get data for a specific location
#' result <- get_data_from_alplakes("2025-04-30", "46.45", "6.30")
#' }
#'
#' @export
get_data_from_alplakes <- function(day = Sys.Date(),
                                   latitude = "46.303696",
                                   longitude = "6.239853") {

  # Build the request
  req <- build_alplakes_request(day, latitude, longitude)

  # Execute the request
  response <- req |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  response |> convert_json_to_list()

  # # Check if the response contains an error message
  # content <- httr2::resp_body_json(response)
  # if (!is.null(content$detail) && grepl("Apologies data is not available", content$detail)) {
  #   warning("API Error: ", content$detail,
  #           "\nThe AlpLakes API appears to provide historical data only, organized by weeks starting on Sundays.")
  #   return(NULL)
  }

#   return(content)
# }

#' convert_json_to_list
#'
#' @param API_response response from get_data_from_alplakes
#'
#' @return The API response read with jsonlite::fromJSON. If the call failed, it will return the
#' data from the 14th of June 2024.
#'
#' @export


convert_json_to_list <- function(API_response) {
  if(API_response$status_code == 200) {
    json_data <- API_response |> httr2::resp_body_json()
    return(json_data)

  } else {
    warning("Status code is not 200. Returning the API response.")
    return(API_response)
  }
}
