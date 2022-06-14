prep_gradient <- function(ensemble_data, site_info, date_start, days_shown, out_file, threshold){
  

  ensemble_data %>%
    filter(model_name == 'DA') %>%
    mutate(obs_max_temp_f = c_to_f(obs_max_temp_c),
           pred_max_temp_f = c_to_f(max_temp)
    ) %>%
    # subset to time period of interest
    filter(time %in% seq.Date(from = date_start, to = date_start+days_shown, by = "1 day")) %>%
    # filter to 1 day out predictions only
    filter(lead_time == 1) %>%
    left_join(site_info)
  
}

