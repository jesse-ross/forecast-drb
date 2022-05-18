library(targets)

tar_option_set(packages = c(
  'tidyverse',
  'ggdist',
  'sf'
))

source('2_process/src/temp_utils.R')
source('3_visualize/src/plot_gradient.R')
source('3_visualize/src/map_exceedance_prob.R')

site_lordville <- 1573

list(

  ##### Download forecasting model outputs #####

  # For now, this is a manual process where we download the
  #   files from this GitLab repo to the `1_fetch/in` folder
  #   https://code.usgs.gov/wma/wp/forecast-preprint-code/-/tree/fy22_preprint/in
  tar_target(p1_forecast_data_rds, '1_fetch/in/all_mods_with_obs.rds', format="file"),
  tar_target(p1_forecast_data, readRDS(p1_forecast_data_rds)),
  
  # Data with calculated 5% CI intervals for ensembles
  tar_target(p1_ci_data_rds, '1_fetch/in/all_mods_with_obs.rds', format="file"),
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

  ##### VISUALIZE DATA #####
  tar_target(
    p3_daily_gradient_interval_png,
    plot_gradient(ensemble_data = p1_ensemble_data,
                  site_info = p2_site_info,
                  date_start = "2021-06-28",
                  days_shown = 6,
                  out_file = "3_visualize/out/daily_gradient_interval.png"),
    format = "file"
  ),

  tar_target(
    p3_seg_exceedance_map_png,
    map_exceedance_prob(exceedance_data = p2_exceedance_data,
                        segs_sf = p1_forecast_segs_sf,
                        out_file = "3_visualize/out/map_segment_exceedance_prob.png"),
    format = "file"
  )

)
