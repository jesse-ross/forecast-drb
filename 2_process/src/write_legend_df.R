write_legend_rds <- function(in_data, out_file){
  

  saveRDS(in_data, 
           file = out_file) 
  
  return(out_file)
  
}

