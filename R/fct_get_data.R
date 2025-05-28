#' Build an API request for Alplakes lake temperature data
#'
#' Creates an httr2 request to the Alplakes API for retrieving water temperature data
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
                                   end_day = NULL,
                                   latitude = "46.303696",
                                   longitude = "6.239853") {
  day <- day |>  lubridate::date()
  # Convert CET (Geneva time) to UTC for the API
  # Create POSIXct objects for start and end of day in CET
  start_time_cet <- as.POSIXct(paste(day, "00:00:00"), tz = "CET")

  if(is.null(end_day)) {
    end_time_cet <- as.POSIXct(paste(day + 7, "23:00:00"), tz = "CET")
  } else {
    end_time_cet <- as.POSIXct(paste(end_day, "23:00:00"), tz = "CET")
  }

  # Convert to UTC
  start_time_utc <- format(start_time_cet, "%Y%m%d%H%M", tz = "UTC")
  end_time_utc <- format(end_time_cet, "%Y%m%d%H%M", tz = "UTC")

  # Build the request
  req <- httr2::request("https://alplakes-api.eawag.ch/simulations/depthtime/delft3d-flow/geneva/") |>
    httr2::req_user_agent("temperaturelacleman (https://github.com/yannsay/temperaturelacleman)") |>
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
  req <- build_alplakes_request(day, latitude = latitude, longitude = longitude)

  # Execute the request
  response <- req |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()

  # if the request works
  if (response$status_code == 200) {
    # If error with the new end date returns the call
    json_response <- response |> convert_json_to_list()

    return(json_response)
  }

  # If error
  response_message <- response |> httr2::resp_body_json() |>  purrr::pluck("detail")

  if (stringr::str_detect(response_message, "week starting")){
    error_date <- extract_unavailable_date(response_message)
    new_end_date <- lubridate::date(error_date) -1

    req2 <- build_alplakes_request(day, end_day = new_end_date, latitude = latitude, longitude = longitude)

    response2 <- req2 |>
      httr2::req_error(is_error = \(resp) FALSE) |>
      httr2::req_perform()

    # if the request works
    if (response2$status_code == 200) {
      # If error with the new end date returns the call
      json_response <- response2 |> convert_json_to_list()

      return(json_response)
    }
  }

  return(req)

  #if the request has not worked, return the request as it is.
  }

#' convert_json_to_list
#'
#' @param API_response response from get_data_from_alplakes
#'
#' @return The API response read with jsonlite::fromJSON. If the call failed, the http request.
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


# Function to extract the date from the API response
# If the last date is not available, the API will return:
# Apologies data is not available for geneva week starting 2025-06-01 00:00:00+00:00
extract_unavailable_date <- function(response_message) {
  # response_message <- response |> httr2::resp_body_json() |>  purrr::pluck("detail")

  response_date <- stringr::str_match(response_message, "week starting (\\d{4}-\\d{2}-\\d{2})")[, 2]
  return(response_date)

}

