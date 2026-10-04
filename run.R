# run.R
library(plumber)

# Setup the plumber router
pr <- plumb("app.R")

# Run the Plumber API server on port 5003
pr$run(host = "127.0.0.1", port = 5003)
