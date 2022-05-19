
#' @description Plot of single lead time for temperature predictions across many sites
#' showing confidence intervals around predictions
#' @param ci_data forecast data filtered to 1-day out lead time
#' @param ci_list a list of confidence intervals to find upper and lower bounds 
#' must be a 0.1 degree increment ranging 0.1-0.9
plot_daily_ci <- function(ci_interval_data, ci_list, plot_date, out_file){
  
  ci_interval_data %>%
    filter(.width %in% ci_list) %>%
    ggplot(aes(x = seg_id_nat,
               group = seg_id_nat,
               y = temp,
               ymin = .lower, ymax = .upper
    )) +
    geom_interval() +
    geom_point(color = 'white') +
    theme_ci()+
    scale_color_brewer() +
    labs(x = 'Stream segment', y = 'Temperature (C)')
  
  ggsave(out_file, width = 1600, height = 900, dpi = 200, units = "px")
  return(out_file)
}

theme_ci <- function(){
  theme_classic(base_size = 12)+
    theme()
}
