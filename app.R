# app.R
library(plumber)

# Initialize OCR lazily
source("traditional_ocr.R")

# Create uploads directory
if (!dir.exists("uploads")) {
  dir.create("uploads")
}

#* @assets ./static /static
list()

#* Serve the index HTML
#* @get /
#* @serializer html
function() {
  paste(readLines("templates/index.html", warn=FALSE), collapse="\n")
}

#* @post /api/recognize
#* @parser multi
function(req, res) {
  # Extract image data safely
  img_data <- NULL
  if (is.raw(req$body)) {
    img_data <- req$body
  } else if (!is.null(req$body$image)) {
    if (is.list(req$body$image) && !is.null(req$body$image$value)) {
      img_data <- req$body$image$value
    } else if (is.list(req$body$image) && is.raw(req$body$image[[1]])) {
      img_data <- req$body$image[[1]]
    } else if (is.raw(req$body$image)) {
      img_data <- req$body$image
    }
  } else if (is.list(req$args) && !is.null(req$args$image)) {
    if (is.list(req$args$image) && !is.null(req$args$image$value)) {
      img_data <- req$args$image$value
    } else if (is.raw(req$args$image)) {
      img_data <- req$args$image
    }
  }
  
  if (is.null(img_data) || length(img_data) == 0) {
    res$status <- 400
    return(list(error = "No image provided or unsupported format"))
  }
  
  tmp_path <- tempfile(fileext = ".png", tmpdir = "uploads")
  writeBin(as.raw(img_data), tmp_path)
  
  if (!exists("ocr", envir = .GlobalEnv)) {
    assign("ocr", TraditionalOCR$new(), envir = .GlobalEnv)
  }
  ocr <- get("ocr", envir = .GlobalEnv)
  
  tryCatch({
    result_text <- ocr$recognize_image(tmp_path)
    if (is.null(result_text)) {
      res$status <- 500
      return(list(error = "Failed to process image"))
    }
    
    list(text = result_text)
  }, error = function(e) {
    res$status <- 500
    list(error = e$message)
  }, finally = {
    if (file.exists(tmp_path)) {
      file.remove(tmp_path)
    }
  })
}
