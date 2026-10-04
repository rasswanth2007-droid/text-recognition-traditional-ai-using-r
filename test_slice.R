library(reticulate)
cv2 <- import("cv2", convert = FALSE)
np <- import("numpy", convert = FALSE)

py_run_string("
def crop_image(img, x, y, w, h):
    return img[int(y):int(y+h), int(x):int(x+w)]
")

img <- np$zeros(c(50L, 50L), dtype = np$uint8)
font <- cv2$FONT_HERSHEY_SIMPLEX

text_size_info <- cv2$getTextSize("0", font, 1.5, 3L)
text_size <- text_size_info[[0]]

text_x <- as.integer((50L - py_to_r(text_size[[0]])) / 2)
text_y <- as.integer((50L + py_to_r(text_size[[1]])) / 2)

cv2$putText(img, "0", c(text_x, text_y), font, 1.5, 255L, 3L)

bbox <- cv2$boundingRect(img)
x <- py_to_r(bbox[[0]])
y <- py_to_r(bbox[[1]])
w <- py_to_r(bbox[[2]])
h <- py_to_r(bbox[[3]])

cat(sprintf("x: %d, y: %d, w: %d, h: %d\n", x, y, w, h))

cropped <- py$crop_image(img, x, y, w, h)
cropped_np <- np$array(cropped, dtype = np$uint8)
resized <- cv2$resize(cropped_np, c(28L, 28L))
cat("resized done!\n")
