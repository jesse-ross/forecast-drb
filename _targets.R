library(targets)

tar_option_set(packages = c(
  'tidyverse'
))

list(

  ##### Download forecasting model outputs #####

  # For now, this is a manual process where we download the
  #   files from this GitLab repo to the `1_fetch/in` folder
  #   https://code.usgs.gov/wma/wp/forecast-preprint-code/-/tree/main/in
  tar_target(p1_forecast_data_rds, '1_fetch/in/all_mods_with_obs.rds', format="file"),
  tar_target(p1_forecast_data, readRDS(p1_forecast_data_rds)),

  ##### Extract some metadata for potentially mapping over #####

  tar_target(p2_forecast_dates, unique(p1_forecast_data$time)),
  tar_target(p2_forecast_seg_ids, unique(p1_forecast_data$seg_id_nat)),
  tar_target(p2_forecast_model, unique(p1_forecast_data$model_name)),
  tar_target(p2_forecast_scenario, unique(p1_forecast_data$scenario))

  ##### VISUALIZE DATA? #####

)
