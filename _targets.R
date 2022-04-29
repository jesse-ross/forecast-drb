library(targets)

tar_option_set(packages = c(
  'tidyverse',
  'ggdist',
  'sf'
))

source('2_process/src/temp_utils.R')
source('3_visualize/src/plot_gradient.R')

list(

  ##### Download forecasting model outputs #####

  # For now, this is a manual process where we download the
  #   files from this GitLab repo to the `1_fetch/in` folder
  #   https://code.usgs.gov/wma/wp/forecast-preprint-code/-/tree/main/in
  tar_target(p1_forecast_data_rds, '1_fetch/in/all_mods_with_obs.rds', format="file"),
  tar_target(p1_forecast_data, readRDS(p1_forecast_data_rds)),

  # Data with all ensembles
  tar_target(p1_ensemble_data_rds, '1_fetch/in/da_noda_all_ensembles.rds', format="file"),
  tar_target(p1_ensemble_data, readRDS(p1_ensemble_data_rds)),

  # Load spatial segment data
  tar_target(p1_forecast_segs_shape_rds, '1_fetch/in/forecast_segs_shape.rds', format="file"),
  tar_target(p1_forecast_segs_sf, readRDS(p1_forecast_segs_shape_rds)),

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

  ##### Create example data to mimic our 70-segment forecast data for now #####

  tar_target(
    p2_forecast_data_allsegs_madeup,
    p1_forecast_data %>%
      filter(model_name == 'DA') %>%
      filter(lead_time == 1) %>%
      filter(scenario == "+0cfs") %>%
      # Force the data to be one row per seg & replace seg ids
      # and be data all for the same dates
      dplyr::slice(seq_along(p2_forecast_seg_ids)) %>%
      mutate(seg_id_nat = p2_forecast_seg_ids,
             issue_time = head(issue_time,1),
             time = head(time,1),
             site_name = NA)
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
  )

)
