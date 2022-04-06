# forecast-drb

Pipeline and code for downloading and creating an updated visualization to accompany the Delaware River Basin (DRB) forecasting model outputs in 2022.

## How to build

This repo contains a lightweight `targets` pipeline to download data from the USGS data repository, ScienceBase, using `sbtools` and then create output visuals. To run the full pipeline, install all necessary packages and then run `targets::tar_make()`.

* To just download the data, run `targets::tar_make(dplyr::starts_with("p1_"))`. This step takes about 1 minute.
* ...
* ...

## Output

INSERT VISUAL HERE
