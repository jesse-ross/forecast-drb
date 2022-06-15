plot_gradient <- function(plot_gradient_df, threshold){
  
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
    # threshold line
    geom_hline(yintercept = c_to_f(threshold),
               linetype = "dashed",
               color = "orangered",
               size = .6,
               alpha = 0.8) +
    # panel for each site
    facet_grid(~ site_label) + 
    stat_gradientinterval(.width = c(0),
                          shape = NA,
                          width =.95,
                          # sub values over threshold with NA
                          aes(fill = ifelse(stat(y) > c_to_f(threshold), NA, stat(y))), 
                          size = 0.5) +
    # gradient color scale, using red for NA (over threshold)
    scico::scale_fill_scico(palette = "lapaz", 
                            end = 0.7,
                            na.value = "orangered") +
    scico::scale_color_scico(palette = "lapaz", 
                            end = 0.5,
                            na.value = "orangered") +
    # change alpha so that end of confidence interval shows and doesn't fade away
    scale_slab_alpha_continuous(
      range = c(0, 1) #default: 0,1
    ) +
    # tile for mean prediction
    geom_tile(aes(x = time,
                  y = pred_max_temp_f,
                  fill = ifelse(stat(y) > c_to_f(threshold), NA, stat(y))),  
              stat = "summary",
              fun = "mean",
              size = 1,
              height = .4,
              width = .8,
              alpha = 1,
              color = NA) +
    theme(legend.position = "none",
          axis.text = element_text(size = 6, angle = 0, hjust = 0.5),
          strip.background = element_rect(color = NA, fill = NA),
          # color for axis labels - throws an error, ignore that
          axis.text.y = element_text(color = c(rep("black", 4), "orangered", "black")),
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

