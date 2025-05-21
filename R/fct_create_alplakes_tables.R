#' create_alplakes_tables
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

create_alplakes_tables <- function(alplakes_clean_data) {
  long_show_table <- alplakes_clean_data %>%
    mutate(across(everything(), \(x) round(x,1))) %>%
    select(profondeur, everything()) %>%
    arrange(profondeur) %>%
    mutate(profondeur = -profondeur)

  small_show_table <- long_show_table %>%
    mutate(profondeur = round(profondeur)) %>%
    filter(!duplicated(profondeur)) %>%
    filter(profondeur %in% seq(0, -50, by = -5) )


  unique_days <- names(alplakes_clean_data)[-1] %>% lubridate::date() %>% unique() %>% as.character()
  week_days <- unique_days %>% lubridate::date() %>% weekdays()

  long_show_table_day <- map(unique_days,
                             ~select(long_show_table, profondeur, contains(.x))) %>%
    set_names(week_days)

  small_show_table_day <- map(unique_days,
                              ~select(small_show_table, profondeur, contains(.x))) %>%
    set_names(week_days)

  return(list(small_show_table = small_show_table,
              long_show_table = long_show_table,
              long_show_table_day = long_show_table_day,
              small_show_table_day = small_show_table_day))
}
