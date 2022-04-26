plot_gradient <- function(ensemble_data, site_info, date_start, days_shown){
  
  # filter data to a focal time period
  date_start <- as.Date(date_start)
  
  threshold = 23.89 # C
  
  plot_df <- ensemble_data %>%
    filter(model_name == 'DA') %>%
    mutate(obs_max_temp_f = c_to_f(obs_max_temp_c),
           pred_max_temp_f = c_to_f(max_temp)
    ) %>%
    # subset to time period of interest
    filter(time %in% seq.Date(from = date_start, to = date_start+days_shown, by = "1 day")) %>%
    # filter to 1 day out predictions only
    filter(lead_time == 1) %>%
    left_join(site_info)
  
  # observed max temp
  temp_obs <- plot_df %>% 
    distinct(time, site_name, site_label, obs_max_temp_f)
  
  # custom color scale 
  start <- 42 # lower bound gradient
  end <- c_to_f(threshold) # threshold
  
  # create gradient up until threshold
  col_lapaz <- scico::scico(50, palette = "lapaz", direction = 1)[1:((1+end)-start)]  

  # extend scale with 5 degree steps
  deg_step <- 5
  col_lapaz_ext <- c(rep("royalblue",deg_step), 
                     rep("dodgerblue", deg_step),
                     col_lapaz,
                     rep("orangered",deg_step),
                     rep("red", deg_step))

  deg_num <- as.factor(c((start-(2*deg_step)):(end+(2*deg_step))))
  names(col_lapaz_ext) <- deg_num
  
  
  # plot 1-day out predictions with mean prediction and observed
  plot_df %>%
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
    facet_grid(~ site_name) + 
    stat_gradientinterval(.width = c(.95),
                          width =.95,
                          # sub values over threshold with NA
                          aes(fill = ifelse(stat(y) > c_to_f(threshold), NA, stat(y))), 
                          fill_type = "gradient",
                          size = 0.5) +
    # gradient color scale, using red for NA (over threshold)
    scico::scale_fill_scico(palette = "lapaz", 
                            end = 0.75,
                            na.value = "orangered") +
    # tile to make observed temp
    geom_tile(data = temp_obs,
              aes(x = time,
                  y = obs_max_temp_f,
                  fill = obs_max_temp_f),  
              size = 1,
              height = .4,
              width = .8,
              alpha = 1,
              color = NA) +
    theme(legend.position = "none",
          axis.text=element_text(size=8, angle = 0),
          strip.background = element_rect(color = NA, fill = NA),
          axis.text.y = element_text(color = c(rep("black", 4), "orangered", "black")),
          panel.background = element_rect(color="grey", fill=NA),
          axis.line = element_line(size = .5, color="gray"),
          strip.text = element_text(face = "bold"))+
    scale_y_continuous(position = "left") +
    scale_x_date(breaks = scales::breaks_width("1 day"),
                 labels = scales::label_date_short()) +
    scale_fill_manual(values = c("darkgrey", "orangered"))+
    geom_tile(data = temp_obs,
                aes(x = time,
                    y = obs_max_temp_f,
                    ),  
                size = 1,
                height = .4,
                width = .8,
                alpha = 1,
                color = NA)

  
}

