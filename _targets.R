library(targets)

tar_option_set(packages = c(
  'sbtools',
  'tidyverse'
))

source('1_fetch/src/download_helpers.R')

list(

  ##### Download/unzip temperature and flow inputs to forecasting model #####

  tar_target(p0_sbid_tempflow, '5f6a287382ce38aaa2449131'),

  # Download zips
  #   Note: includes the data for the 5 forecast sites (could choose to exclude if we want)
  tar_target(p1_sbfiles_tempflow, find_sb_files(p0_sbid_tempflow, pattern = '(temperature|flow)_observations')),
  tar_target(p1_tempflow_zips, download_sb_files(p0_sbid_tempflow, p1_sbfiles_tempflow, '1_fetch/tmp')),

  # Unzip to get CSVs
  tar_target(p1_tempflow_zips_map, p1_tempflow_zips, pattern=map(p1_tempflow_zips), format="file"), # needed in order to use files to map in next step
  tar_target(p1_tempflow_csvs, do_unzip(p1_tempflow_zips_map, '1_fetch/out'), pattern=map(p1_tempflow_zips_map), format="file"),

  ##### Download/unzip model predictions from forecast model #####

  tar_target(p0_sbid_modelpreds, '5f6a28a782ce38aaa2449137'),

  # Download zips
  #   Note: I am expecting this pattern matching to only return one top-level zipfile which contains a bunch of daily zipfiles
  tar_target(p1_sbfiles_modelpreds, find_sb_files(p0_sbid_modelpreds, pattern = 'forecast(.)+_files\\.zip')),
  tar_target(p1_modelpreds_zips, download_sb_files(p0_sbid_modelpreds, p1_sbfiles_modelpreds, '1_fetch/tmp'), format="file"),

  # Unzip to get an XML and NetCDF (nc) file per day in the forecast
  tar_target(p1_modelpreds_daily_zips, do_unzip(p1_modelpreds_zips, '1_fetch/tmp')), # no format=file, so we can map in next step
  tar_target(p1_modelpreds_daily_files, do_unzip(p1_modelpreds_daily_zips, '1_fetch/out'), pattern=map(p1_modelpreds_daily_zips), format="file"),

  ##### READ/FORMAT DATA? #####

  # Find the available forecast dates based on the forecast file names
  tar_target(p2_forecast_dates, str_extract(p1_modelpreds_daily_files, "([0-9]{4})-([0-9]{2})-([0-9]{2})") %>% unique() %>% as.Date()),
  tar_target(p2_forecast_seg_ids, str_extract(p1_modelpreds_daily_files, "nat\\[([0-9]{4})\\]") %>% unique())

  ##### VISUALIZE DATA? #####
)
