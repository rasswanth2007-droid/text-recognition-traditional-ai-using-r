library(reticulate)
cv2 <- import("cv2", convert = FALSE)
np <- import("numpy", convert = FALSE)

img <- np$zeros(c(50L, 50L), dtype = np$uint8)
cat("img created\n")

py_dict <- dict(img = img)
cat("dict created\n")

py_run_string("cropped = img[0:10, 0:10]", convert = FALSE, local = py_dict)
cat("run_string done\n")

cropped <- py_dict$get("cropped")
cat("get done\n")
