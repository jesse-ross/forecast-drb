#' @title Identify files on SB
#' @description Using a regular expression, list files from SB
#' that match a pattern of interest
#' @param sb_id character string of the ScienceBase item identifier
#' where the files are located, e.g. `'5f6a287382ce38aaa2449131'`
#' @param pattern regular expression used to find matching files
#' @return vector of filenames that match the pattern
find_sb_files <- function(sb_id, pattern) {
  sbtools::item_list_files(sb_id) %>%
    filter(grepl(pattern, fname)) %>%
    pull(fname)
}

#' @title Download selection of files from an SB item
#' @description Download files from SB to a specific local directory
#' @param sb_id character string of the ScienceBase item identifier
#' where the files are located, e.g. `'5f6a287382ce38aaa2449131'`
#' @param sb_filenames the filenames that match the files on SB that
#' you want to download
#' @param out_dir local directory to save all of the files; must exist
#' @param overwrite T/F whether or not to download and overwrite a
#' file if it already exists locally. Defaults to TRUE
#' @return filepaths to the new, local files
download_sb_files <- function(sb_id, sb_filenames, out_dir, overwrite = TRUE) {
  files_out <- file.path(out_dir, sb_filenames)
  sbtools::item_file_download(
    sb_id = sb_id,
    names = sb_filenames,
    destinations = files_out,
    overwrite_file = overwrite
  )
  return(files_out)
}

#' @title Extract files from a .zip file
#' @description Unzip a file and return the filenames from within
#' @param zip_file a filepath ending in `.zip`
#' @param out_dir local directory to save all of the files; must exist
#' @return filepaths to the new, extracted files
do_unzip <- function(zip_file, out_dir) {
  files_in_zip <- utils::unzip(zipfile = zip_file, list = T) %>% pull(Name)
  files_out <- file.path(out_dir, files_in_zip)
  zip::unzip(zipfile = zip_file, exdir = out_dir)
  return(files_out)
}
