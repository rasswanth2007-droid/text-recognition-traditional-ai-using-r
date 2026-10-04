# Text Recognition Traditional AI (R Edition)

This is a text recognition system utilizing traditional computer vision (OpenCV) and template matching techniques, featuring an R Plumber web interface for easy use. This project has been entirely ported to R.

## Features
- **Traditional OCR Pipeline**: Preprocessing, binarization, morphological operations, and contour detection for text extraction. (Powered by R's `reticulate` interface to OpenCV for robust results without Neural Networks).
- **Web Interface**: A responsive web UI powered by R `plumber` for uploading images and viewing extracted text.
- **Test Image Generation**: A utility script (`generate_test_image.R`) using R's `magick` package to generate synthetic test images with various backgrounds and dimensions.

## Project Structure
- `app.R`: The Plumber API and router definition.
- `run.R`: The entry script to start the Plumber web server.
- `traditional_ocr.R`: The core OCR engine utilizing `R6` and `reticulate`.
- `generate_test_image.R`: R script to generate simulated text images using `magick`.
- `templates/`: HTML templates for the web UI.
- `static/`: CSS/JS assets for the web interface.

## Getting Started

1. Install system requirements:
   Ensure you have python installed in your environment, as `reticulate` relies on it for the `opencv-python` and `numpy` bindings.

2. Install R dependencies:
   Open your R console and run:
   ```R
   install.packages(c("plumber", "magick", "reticulate", "R6"))
   ```
   
   Ensure the required Python packages are available to `reticulate`:
   ```R
   library(reticulate)
   py_install(c("opencv-python", "numpy"))
   ```

3. Run the web application:
   ```bash
   Rscript run.R
   ```

4. Access the web interface at `http://127.0.0.1:5000`.

## Generating Test Images
You can generate synthetic test images purely in R by running:
```bash
Rscript generate_test_image.R
```
This will generate various test images (e.g., `simulated_square_1x1.png`, etc.) in the project root directory that can be tested on the web interface.
