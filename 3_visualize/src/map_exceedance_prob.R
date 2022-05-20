
#' @description Map the river segments and style them to show the probability
#' of each exceeding 75 degC the next day.
map_exceedance_prob <- function(exceedance_data, segs_sf, out_file) {

  ggsegmap <- segs_sf %>%
    transform(seg_id_nat = as.character(seg_id_nat)) %>%
    left_join(exceedance_data, by = 'seg_id_nat') %>%
    ggplot(aes(color = prob_exceed_75, size = prob_exceed_75)) +
    geom_sf() +
    theme_void() + 
    coord_sf() +
    scico::scale_color_scico(name = "Probability of \nexceeding 75 degC\n ", palette = 'bilbao', midpoint = 0.50) +
    scale_size_continuous(range = c(0,0.75)) +
    guides(size = "none") # Turn off the legend for the linewidth key

  ggsave(out_file, ggsegmap, width = 1600, height = 1600, dpi = 200, units = "px")
  return(out_file)
}
