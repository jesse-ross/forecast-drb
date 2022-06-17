merge_plot_legend <- function(main_plot, legend, out_file, show_all_predicted){
  
  # Add labels and annotation to legend before combining
  legend_updated <- legend +
    theme(strip.text = element_text(face = "bold", color = NA),
          panel.background = element_blank(),
          axis.text.y = element_blank(),
          axis.text.x = element_blank(),
          axis.line = element_blank(),
          axis.title.y = element_blank(),
          axis.ticks = element_blank())
  
  # Draw a blank spot "NULL" to put legend
  plot_grid(main_plot, NULL, rel_widths = c(5,1))+
    # then add legend on top
    draw_plot(legend_updated, x = 0.83, y = 0.1, width = 0.08, height = 0.8)+
    # and annotate temperature threshold
    draw_label(expression('75'~degree*'F'), colour = "orangered", x = .95, y = .75, size = 8)+
    annotate("segment", xend = 0.903, x = 0.92, yend = 0.62, y = 0.69, 
             arrow = arrow(length = unit(0.1, "cm")), colour = "orangered")+
    draw_label("threshold", x = .96, y = .705, size = 6, colour = "orangered")+
    # and annotate mean
    draw_label("Mean", colour = "black", x = 0.95, y = 0.545, size = 7)+
    annotate("segment", xend = 0.903, x = 0.92, yend = 0.545, y = 0.545, 
             arrow = arrow(length = unit(0.1, "cm")), colour = "black")+
    # and 90% CI
    draw_label("{", x = 0.9, y = 0.47, size = 20, angle = 180, color = "black")+
    draw_label("\u00B1 90% CI", colour = "black", x = 0.95, y = 0.47, size = 7)+
    # and complete values
    {if(show_all_predicted == TRUE){
      draw_label("     Predicted \nvalues", x = 0.93, y = 0.3, 
                 size = 6, color = "cornsilk3")
    } else {
      draw_label("     Predicted \nvalues", x = 0.93, y = 0.3, 
                 size = 6, color = "white")
    }
      }
    
  
  
  ggsave(filename = out_file,
         width = 1600, height = 600, dpi = 300, units = "px", bg = "white")
}
