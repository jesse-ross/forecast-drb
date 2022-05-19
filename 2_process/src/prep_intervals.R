
#' @description Reshape data for use with 'geom_slabinterval' family from ggdist
#' @param ci_data forecast data filtered to 1-day out lead time
#' @param plot_date focal date for 1-day out forecasts
#' @param ci_list a list of confidence intervals to find upper and lower bounds 
#' must be a 0.1 degree increment ranging 0.1-0.9
prep_intervals <- function(ci_data, plot_date, ci_list){
  
  # filter data to focal date, 1-day out predictions
  ci_interval <- ci_data %>% 
    mutate(lead_time = time - issue_time) %>%
    filter(model_name == 'DA') %>%
    filter(lead_time == 1 & time == plot_date) %>%
    select(seg_id_nat, threshold, quantile) %>%
    # convert percentile increments to upper and lower bounds
    mutate(interval = case_when(
      threshold > 0.5 ~ '.upper', 
      threshold < 0.5 ~ '.lower',
      threshold == 0.5 ~ 'median'),
      .width = case_when(
        interval == '.upper' ~ (threshold - 0.5)*2,
        interval == '.lower' ~ (0.5 - threshold)*2,
        TRUE ~ threshold
      ))

  # find central tendancy
  ci_median <- ci_interval %>%
    filter(interval == 'median') %>%
    rename(.point = interval, temp = quantile) %>%
    select(seg_id_nat, temp, .point)

  # Reshape data for input to ggdist geom_interval family
  ci_wide <- ci_interval %>%
    filter(interval != 'median', .width %in% ci_list) %>% 
    select(-threshold) %>% 
    transform(.width = as.factor(.width)) %>%
    pivot_wider(id_cols = c('seg_id_nat', '.width'), 
                names_from = interval, 
                values_from = quantile) %>%
    left_join(ci_median)
  
  return(ci_wide)

}