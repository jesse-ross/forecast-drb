plot_gradient_legend <- function(ensemble_data, site_info){
  
  # filter data to a focal time period
  date_start <- as.Date("2021-06-28")
  
  threshold = 23.89 # C
  
  
  legend_df <- ensemble_data %>%
    filter(model_name == 'DA') %>%
    mutate(obs_max_temp_f = c_to_f(obs_max_temp_c),
           pred_max_temp_f = c_to_f(max_temp),
           facet_title = "Legend"
    ) %>%
    # subset to time period of interest
    filter(time %in% seq.Date(from = date_start, to = date_start, by = "1 day")) %>%
    # and only Lordville
    filter(seg_id_nat == "1573") %>%
    # filter to 1 day out predictions only
    filter(lead_time == 1) 
  
  # Calculate mean predicted temp for annotation 
  mean_pred_t <- mean(legend_df$pred_max_temp_f, na.rm = T)
  
  # plot 1-day out predictions with mean prediction and observed
  legend_df %>%
    ggplot(
      aes(
        x = time,
        y = pred_max_temp_f
      )) +
    labs(x = "",
         y = "") +
    # panel to label legend
    facet_grid(~ facet_title) + 
    # threshold line
    geom_hline(yintercept = c_to_f(threshold),
               linetype = "dashed",
               color = "orangered",
               size = .6,
               alpha = 0.8) +
    stat_gradientinterval(.width = c(0.1),
                          shape = NA,
                          width = 0.95,
                          # sub values over threshold with NA
                          aes(fill = ifelse(stat(y) > c_to_f(threshold), NA, stat(y))), 
                          size = 0.5,
                          p_limits = c(0.2, 0.3)) +
    # gradient color scale, using red for NA (over threshold)
    scico::scale_fill_scico(palette = "lapaz", 
                            begin = 0.5,
                            end = 0.7,
                            na.value = "orangered") +
    scico::scale_color_scico(palette = "lapaz", 
                            end = 0.5,
                            na.value = "orangered") +
    # change alpha so that end of confidence interval shows and doesn't fade away
    scale_slab_alpha_continuous(
      range = c(.15, 1) #default: 0,1
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
          strip.background = element_rect(color = NA, fill = NA),
          strip.text = element_text(face = "bold"),
          panel.background = element_rect(color="grey", fill = NA),
          # panel.grid left white marks over facet borders, removed with line below
          panel.grid = element_blank(),
          # color for axis labels - throws an error, ignore that
          axis.text.y = element_blank(),
          axis.text.x = element_text(color = "NA", size = 6, angle = 0, hjust = 0.5),
          axis.line = element_line(size = .5, color="gray"),
          axis.title.y = element_blank())+
    scale_y_continuous(limits = c(50,80),
                       position = "left",
                       breaks = seq(55, 75, by = 5)) +
    scale_x_date(limits = c(date_start-1, date_start+1),
                 breaks = scales::breaks_width("1 day"),
                 labels = scales::label_date_short()) +
    # label and arrow for mean
    geom_segment(aes(x = date_start-0.8, y = mean_pred_t, 
                     xend = date_start-0.5, yend = mean_pred_t),
                 arrow = arrow(length = unit(0.05, "cm")))+
    annotate(geom = "text", x = date_start-0.9, y = mean_pred_t, label = "mean",
             size = 2)
    # label and arrow for temperature threshold
    
}

