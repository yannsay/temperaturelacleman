#' get_data_from_alplakes
#'
#' @param start_day Beginning of the week call, as string, YYYY-MM-DD, "20240616".
#' @param end_day End of the week call as string, YYYY-MM-DD, "2024-06-16".
#' @param latitude_call Latitude of the point, as string, default is Hermance plage, "46.303696"
#' @param longitude_call Longitude of the point, as string, default is Hermance plage, "46.303696"
#'
#' @description Call to th Alplakes API to retrieve estimation of the temperature at different depths.
#'
#' @examples
#' get_data_from_alplakes(start_day = "2024-06-10", end_day = "2024-06-16")
#'
#'
#' @return The API response.
#'
#' @noRd

get_data_from_alplakes <- function(start_day,
                     end_day,
                     latitude_call = "46.303696",
                     longitude_call = "6.239853") {
  start_day_call <- stringr::str_replace_all(start_day, "-", "") |>  paste0("0100")
  end_day_call <- stringr::str_replace_all(end_day, "-", "") |>  paste0("2200")
  req <- httr2::request("https://alplakes-api.eawag.ch/simulations/depthtime/delft3d-flow/geneva/")

      req |>
        httr2::req_user_agent("temperatureprofondeurleman (http://my.package.web.site)") |>
        httr2::req_url_path_append(start_day_call) |>
        httr2::req_url_path_append(end_day_call) |>
        httr2::req_url_path_append(latitude_call) |>
        httr2::req_url_path_append(longitude_call) |>
        httr2::req_error(is_error = \(resp) FALSE) |>

        httr2::req_perform()

}

#' convert_json_to_list
#'
#' @param API_response response from get_data_from_alplakes
#'
#' @return The API response read with jsonlite::fromJSON. If the call failed, it will return the
#' data from the 14th of June 2024.
#'
#' @noRd

convert_json_to_list <- function(API_response) {
  if(API_response$status_code == 200) {
    json_data <- API_response |> httr2::resp_body_json()
  } else {
    json_data <- alplakes_json_20240615
  }

  return(json_data)
}
