library(targets)

tar_option_set(packages = c(
  'tidyverse',
  'ggdist',
  'sf',
  'cowplot'
))

source('2_process/src/temp_utils.R')
source('2_process/src/prep_intervals.R')
source('2_process/src/prep_df_gradient.R')
source('3_visualize/src/plot_gradient.R')
source('3_visualize/src/plot_interval.R')
source('3_visualize/src/merge_plot_legend.R')
source('3_visualize/src/plot_daily_ci.R')
source('3_visualize/src/map_exceedance_prob.R')

site_lordville <- 1573
focal_date <- '2021-07-04'
threshold_C <- 23.89 # C
show_all_predicted <- F # show_all_predicted displays the brown backgrounds with TRUE

list(

  ##### Download forecasting model outputs #####

  # For now, this is a manual process where we download the
  #   files from this GitLab repo to the `1_fetch/in` folder
  #   https://code.usgs.gov/wma/wp/forecast-preprint-code/-/tree/fy22_preprint/in
  tar_target(p1_forecast_data_rds, '1_fetch/in/all_mods_with_obs.rds', format="file"),
  tar_target(p1_forecast_data, readRDS(p1_forecast_data_rds)),
  
  # Data with calculated 5% CI intervals for ensembles
  tar_target(p1_ci_data_rds, '1_fetch/in/da_noda_ci.rds', format="file"),
  tar_target(p1_ci_data, readRDS(p1_ci_data_rds)),
  
  # Model eval
  tar_target(p1_eval_data_rds, '1_fetch/in/forecast_model_eval.rds', format="file"),
  tar_target(p1_eval_data, readRDS(p1_eval_data_rds)),

  # Load spatial segment data
  # These files came from Sam
  tar_target(p1_forecast_segs_shape_rds, '1_fetch/in/forecast_segs_shape.rds', format="file"),
  tar_target(p1_forecast_segs_sf, readRDS(p1_forecast_segs_shape_rds)),
  
  # OLD DATA `da_noda_all_ensembles.rds` with all ensembles used for gradient intervals 
  # https://code.usgs.gov/wma/wp/forecast-preprint-code/-/tree/main/in
  tar_target(p1_ensemble_data_rds, '1_fetch/in/da_noda_all_ensembles.rds', format="file"),
  tar_target(p1_ensemble_data, readRDS(p1_ensemble_data_rds)),
  # this comes from the same link above, with `_obs` added to the filepath due to
  # shared naming between new and old data
  tar_target(p1_forecast_data_old_rds, '1_fetch/in/all_mods_with_obs_old.rds', format="file"),
  tar_target(p1_forecast_old_data, readRDS(p1_forecast_data_old_rds)),

  ##### Extract some metadata for potentially mapping over #####

  tar_target(p2_forecast_dates, unique(p1_forecast_data$time)),
  tar_target(p2_forecast_seg_ids, unique(p1_forecast_segs_sf$seg_id_nat)),
  tar_target(p2_forecast_model, unique(p1_forecast_data$model_name)),
  tar_target(p2_forecast_scenario, unique(p1_forecast_data$scenario)),

  tar_target(
    p2_site_info,
    p1_forecast_data %>%
      filter(!is.na(site_name)) %>%
      distinct(seg_id_nat, site_name) %>%
      mutate(site_label = stringr::word(site_name, 3, -1))
  ),

  tar_target(
    p2_exceedance_data,
    p1_forecast_data %>% 
      filter(model_name == 'DA') %>%
      filter(lead_time == 1) %>%
      filter(scenario == "+0cfs") %>%
      select(seg_id_nat, time, prob_exceed_75)
  ),
  
  ## Prepping data for plotting `gradientinterval` geom
  tar_target(
    p2_plot_gradient_df,
    prep_gradient(ensemble_data = p1_ensemble_data, 
                  site_info = p2_site_info, 
                  date_start = as.Date("2021-06-28"), 
                  days_shown = 6, 
                  threshold = threshold_C)
  ),
  
  ## Plotting 1-day out forecasts for a given date
  tar_target(
    p2_focal_date,
    as.Date('2022-01-24')
  ),
  # Reshape confidence interval data for plotting
  tar_target(
    p2_daily_ci_data, 
    prep_intervals(ci_data = p1_ci_data,
                   plot_date = p2_focal_date)
  ),
  
  ##### VISUALIZE DATA #####
  tar_target(
    # create plot
    p3_daily_gradient_interval,
    plot_gradient(p2_plot_gradient_df,
                  threshold = threshold_C)
  ),
  tar_target(
    # create legend, filter to just one example date and location
    p3_daily_gradient_legend,
    plot_gradient(p2_plot_gradient_df %>% 
                    filter(issue_time == "2021-06-28") %>% 
                    filter(site_label == "Lordville"),
                  threshold = threshold_C)
  ),
  tar_target(
    # save plot
    p3_daily_gradient_interval_png,
    merge_plot_legend(main_plot = p3_daily_gradient_interval,
                      legend = p3_daily_gradient_legend,
                      out_file = "3_visualize/out/daily_gradient_interval.png"),
    format = "file"
  ),
  
  ## Plot interval to show directly confidence levels
  tar_target(
    # create plot
    p3_daily_interval,
    plot_interval(p2_plot_gradient_df,
                  threshold = threshold_C,
                  show_all_predicted = show_all_predicted)
  ),
  tar_target(
    # create legend, filter to just one example date and location
    p3_daily_interval_legend,
    plot_interval(p2_plot_gradient_df %>% 
                    filter(issue_time == "2021-06-28") %>% 
                    filter(site_label == "Lordville"),
                  threshold = threshold_C,
                  show_all_predicted = show_all_predicted)
  ),
  tar_target(
    # save plot
    p3_daily_interval_png,
    merge_plot_legend(main_plot = p3_daily_interval,
                      legend = p3_daily_interval_legend,
                      show_all_predicted = show_all_predicted,
                      out_file = "3_visualize/out/daily_interval.png"),
    format = "file"
  ),
  
  tar_target(
    p3_seg_exceedance_map_png,
    map_exceedance_prob(exceedance_data = p2_exceedance_data,
                        segs_sf = p1_forecast_segs_sf,
                        out_file = "3_visualize/out/map_segment_exceedance_prob.png"),
    format = "file"
  ),

  tar_target(
    p3_daily_ci_png,
    plot_daily_ci(ci_interval_data = p2_daily_ci_data,
                  ci_list = c(0.5, 0.8, 0.9), 
                  plot_date = p2_focal_date,
                  out_file = "3_visualize/out/daily_ci.png"),
    format = 'file'
  )

)
