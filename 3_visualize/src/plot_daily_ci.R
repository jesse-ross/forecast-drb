
#' @description Plot of single lead time for temperature predictions across many sites
#' showing confidence intervals around predictions
#' @param ci_data forecast data filtered to 1-day out lead time
#' @param ci_list a list of confidence intervals to find upper and lower bounds 
#' must be a 0.1 degree increment ranging 0.1-0.9
plot_daily_ci <- function(ci_interval_data, ci_list, plot_date, out_file){
  
  max_temp <- max(ci_interval_data$.upper)
  
  p <- ci_interval_data %>%
    filter(.width %in% ci_list) %>%
    ggplot(aes(y = reorder(seg_id_nat, temp),
               group = seg_id_nat,
               x = temp,
               xmin = .lower, xmax = .upper
    )) +
    geom_interval(
      aes(
        #interval_color = ..y..
      )
    ) +
    geom_tile(fill = 'white',
              width = 0.1) +
    theme_ci()+
    scale_color_brewer() +
    labs(y = 'Stream Segment', x = 'Predicted Stream Temperature (F)') +
    scale_x_continuous(position = 'top') +
    guides(fill = guide_legend(
      
    ))
  
  if ( max_temp > 70){
    plot_final <- p +
      geom_vline(xintercept = 74, linetype = "dotted")
  } else {
    plot_final <- p
  }
  
  ggsave(plot = plot_final, filename = out_file, height = 2400, width = 1500, dpi = 200, units = "px")
  return(out_file)
}

theme_ci <- function(){
  theme_classic(base_size = 14)+
    theme(legend.position = c(0.8, 0.1),
          axis.title = element_text(hjust = 0, face = "bold", lineheight = 1.5))
}
