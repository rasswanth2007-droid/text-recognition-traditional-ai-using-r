library(reticulate)
cv2 <- import("cv2", convert = FALSE)
np <- import("numpy", convert = FALSE)

img <- np$zeros(c(50L, 50L), dtype = np$uint8)
font <- cv2$FONT_HERSHEY_SIMPLEX
cat("font\n")

text_size_info <- cv2$getTextSize("A", font, 1.5, 3L)
cat("getTextSize\n")
text_size <- text_size_info[[0]]

text_x <- as.integer((50L - py_to_r(text_size[[0]])) / 2)
text_y <- as.integer((50L + py_to_r(text_size[[1]])) / 2)

cat("putText\n")
cv2$putText(img, "A", c(text_x, text_y), font, 1.5, 255L, 3L)
cat("boundingRect\n")
bbox <- cv2$boundingRect(img)
cat("done\n")
