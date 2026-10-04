# generate_test_image.R
library(magick)

generate_image <- function(filename, text, size, bg_color = "white", text_color = "black") {
  width <- size[1]
  height <- size[2]
  
  img <- image_blank(width = width, height = height, color = bg_color)
  
  # Draw text in center
  img <- image_annotate(img, text, gravity = "center", size = 60, 
                        color = text_color, font = "sans", weight = 700)
  
  image_write(img, filename)
  cat(sprintf("[Success] Generated %s | Size: %dx%d | Text: '%s'\n", filename, width, height, text))
}

cat("--- Generating Simulated Images with Different Frame Orientations ---\n")

generate_image("simulated_square_1x1.png", "AERO", c(400, 400))
generate_image("simulated_portrait_3x4.png", "VISION", c(300, 400))
generate_image("simulated_landscape_4x3.png", "DATA", c(400, 300))
generate_image("simulated_widescreen_16x9.png", "SYSTEM", c(640, 360))
generate_image("simulated_dark_1x1.png", "VIPIN", c(500, 500), bg_color = "#646464", text_color = "white")

cat("--- Done! You can now test these on the frontend. ---\n")
