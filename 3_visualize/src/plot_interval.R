plot_interval <- function(plot_gradient_df, threshold, show_all_predicted){
  
  # Max temperature for check if it's within range of threshold
  max_temp <- plot_gradient_df %>%
    summarize(max(pred_max_temp_f))
  
  # Breaks by 5, then associated with the data for dynamic coloring of text/ticks
  breaks_all <- seq(0,100, by = 5)
  breaks_draw <- breaks_all[breaks_all >= min(plot_gradient_df$pred_max_temp_f)] 
  
  # plot 1-day out predictions with mean prediction 
  plot_gradient_df %>%
    ggplot(
      aes(
        x = time,
        y = pred_max_temp_f,
        group = site_name
      )) +
    labs(x = "",
         y = "Max temperature (F)") +
    # panel for each site
    facet_grid(~ site_label) + {
      # Turn off or on the full background of predicted values depending on argument
      if(show_all_predicted == TRUE){
        stat_gradientinterval(shape = NA,
                              aes(fill = ifelse(stat(y) > c_to_f(threshold), NA, "none")),
                              size = 1)  }
       else {
        stat_gradientinterval(shape = NA,
                              fill = "white", 
                              size = 1) }
    } +
    stat_interval(.width = seq(0.1, 0.9, by = 0.1), #set CI levels
                  size = 2) +
    # gradient color scale, using red for NA (over threshold)
    scico::scale_fill_scico_d(palette = "lapaz", 
                              end = 0.7,
                            na.value = "orangered",
                            direction = -1) +
    scico::scale_color_scico_d(palette = "lapaz", 
                            end = 0.5,
                            na.value = "orangered",
                            direction = -1)+
    # change alpha so that end of confidence interval shows and doesn't fade away
    scale_slab_alpha_continuous(
      range = c(0.5, 1) #default: 0,1
    )+
    # tile for mean prediction
    geom_tile(fill = 'white',
              stat = "summary",
              fun = "mean",
              height = 0.1)+
    # threshold line
    { if (max_temp >= 71) {
      geom_hline(yintercept = c_to_f(threshold),
               linetype = "dashed",
               color = "orangered",
               size = .48,
               alpha = 0.8) 
        }}+
    theme(legend.position = "none",
          axis.text = element_text(angle = 0, hjust = 0.5),
          axis.text.x = element_text(size = 5),
          strip.background = element_rect(color = NA, fill = NA),
          # color for axis labels
          axis.text.y = element_text(size = 6, 
                                     color = ifelse(breaks_draw == 75, "red", "black")),
          axis.ticks.y = element_line(color = ifelse(breaks_draw == 75, "red", "black")),
          panel.background = element_rect(color="grey", fill = NA),
          axis.line = element_line(size = .5, color="gray"),
          strip.text = element_text(face = "bold"),
          # panel.grid left white marks over facet borders, removed with line below
          panel.grid = element_blank())+
    scale_y_continuous(position = "left",
                       breaks = seq(55, 75, by = 5)) +
    scale_x_date(breaks = scales::breaks_width("1 day"),
                 labels = scales::label_date_short()) 

  
}

