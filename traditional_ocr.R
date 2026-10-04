# traditional_ocr.R
library(R6)
library(reticulate)

TraditionalOCR <- R6Class("TraditionalOCR",
  private = list(
    cv2 = NULL,
    np = NULL,
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    templates = list()
  ),
  public = list(
    
    initialize = function() {
      private$cv2 <- import("cv2", convert = FALSE)
      private$np <- import("numpy", convert = FALSE)
      py_run_string("
def crop_image(img, x, y, w, h):
    return img[int(y):int(y+h), int(x):int(x+w)]
")
      self$generate_templates()
    },
    
    generate_templates = function() {
      cv2 <- private$cv2
      np <- private$np
      cat("[System] Generating pure AI templates...\n")
      chars_split <- strsplit(private$chars, "")[[1]]
      
      for (char in chars_split) {
        cat(sprintf("Processing %s...\n", char))
        img <- np$zeros(c(50L, 50L), dtype = np$uint8)
        font <- cv2$FONT_HERSHEY_SIMPLEX
        
        cat("  getTextSize...\n")
        text_size_info <- cv2$getTextSize(char, font, 1.5, 3L)
        text_size <- text_size_info[[0]]
        
        cat("  calculating coords...\n")
        text_x <- as.integer((50L - py_to_r(text_size[[0]])) / 2)
        text_y <- as.integer((50L + py_to_r(text_size[[1]])) / 2)
        
        cat("  putText...\n")
        cv2$putText(img, char, c(text_x, text_y), font, 1.5, 255L, 3L)
        
        cat("  boundingRect...\n")
        bbox <- cv2$boundingRect(img)
        x <- py_to_r(bbox[[0]])
        y <- py_to_r(bbox[[1]])
        w <- py_to_r(bbox[[2]])
        h <- py_to_r(bbox[[3]])
        
        if (w > 0 && h > 0) {
          cropped <- py$crop_image(img, x, y, w, h)
          cropped_np <- np$array(cropped, dtype = np$uint8)
          
          resized <- cv2$resize(cropped_np, c(28L, 28L))
          private$templates[[char]] <- py_to_r(resized)
        }
      }
    },
    
    preprocess_and_segment = function(image_path) {
      cv2 <- private$cv2
      np <- private$np
      img <- cv2$imread(image_path, cv2$IMREAD_GRAYSCALE)
      if (is.null(img)) {
        stop(sprintf("Could not read image: %s", image_path))
      }
      
      blurred <- cv2$GaussianBlur(img, c(5L, 5L), 0L)
      
      # average brightness
      avg_brightness <- py_to_r(np$mean(img))
      
      if (avg_brightness < 127) {
        thresh_type <- cv2$THRESH_BINARY
        c_val <- -5L
      } else {
        thresh_type <- cv2$THRESH_BINARY_INV
        c_val <- 5L
      }
      
      thresh <- cv2$adaptiveThreshold(blurred, 255L, cv2$ADAPTIVE_THRESH_GAUSSIAN_C,
                                      thresh_type, 15L, c_val)
                                      
      kernel <- cv2$getStructuringElement(cv2$MORPH_RECT, c(2L, 2L))
      thresh <- cv2$morphologyEx(thresh, cv2$MORPH_OPEN, kernel)
      thresh <- cv2$morphologyEx(thresh, cv2$MORPH_CLOSE, kernel)
      
      # Find contours
      contours_info <- cv2$findContours(thresh, cv2$RETR_EXTERNAL, cv2$CHAIN_APPROX_SIMPLE)
      contours <- contours_info[[0]]
      
      # bounding boxes
      bounding_boxes <- list()
      contours_r <- py_to_r(contours)
      if (length(contours_r) > 0) {
          for (i in 1:length(contours_r)) {
              c <- contours[i-1] # python indexing is 0-based
              bbox <- cv2$boundingRect(c)
              bounding_boxes[[length(bounding_boxes) + 1]] <- py_to_r(bbox)
          }
      }
      
      # Sort left to right based on x-coordinate
      if (length(bounding_boxes) > 0) {
        bounding_boxes <- bounding_boxes[order(sapply(bounding_boxes, function(b) b[[1]]))]
      }
      
      shape <- py_to_r(img$shape)
      img_h <- shape[[1]]
      img_w <- shape[[2]]
      
      characters <- list()
      
      for (b in bounding_boxes) {
        x <- b[[1]]; y <- b[[2]]; w <- b[[3]]; h <- b[[4]]
        if (w > 2 && h > 10 && w < img_w * 0.9 && h < img_h * 0.9) {
          char_crop <- py$crop_image(thresh, x, y, w, h)
          char_crop_np <- np$array(char_crop, dtype = np$uint8)
          char_resized <- cv2$resize(char_crop_np, c(28L, 28L))
          characters[[length(characters) + 1]] <- char_resized
        }
      }
      
      return(characters)
    },
    
    recognize_character = function(char_img) {
      cv2 <- private$cv2
      np <- private$np
      best_match <- "?"
      highest_score <- -1.0
      
      for (char in names(private$templates)) {
        template <- np$array(private$templates[[char]], dtype=np$uint8)
        result <- cv2$matchTemplate(char_img, template, cv2$TM_CCOEFF_NORMED)
        score <- py_to_r(result)[1,1]
        
        if (score > highest_score) {
          highest_score <- score
          best_match <- char
        }
      }
      return(best_match)
    },
    
    recognize_image = function(image_path) {
      cat(sprintf("\n[System] Reading image: %s\n", image_path))
      
      tryCatch({
        characters <- self$preprocess_and_segment(image_path)
        cat(sprintf("[System] Found %d characters.\n", length(characters)))
        
        result_text <- ""
        if (length(characters) > 0) {
            for (char_img in characters) {
              pred <- self$recognize_character(char_img)
              result_text <- paste0(result_text, pred)
            }
        }
        
        cat(sprintf(">>> FINAL RECOGNITION RESULT: '%s'\n", result_text))
        return(result_text)
      }, error = function(e) {
        cat(sprintf("Error: %s\n", e$message))
        return(NULL)
      })
    }
  )
)
