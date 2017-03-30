# Here's what we'll do:


# 1. # Specify list of packages to download/install
pkgs <-
  c(
    #prereqs
    'codetools', 
    "Rcpp",
    # tidyverse, etc. 
    "broom",
    "DBI",
    "dplyr",
    "FSA",
    "forcats",
    "ggplot2",
    "ggmap",
    "haven",
    "httr",
    "hms",
    "jsonlite",
    "lubridate",
    "magrittr",
    "modelr",
    "purrr",
    "readr",
    "readxl",
    "scales",
    "sf",
    "stringr",
    "sp",
    "spatstat",
    "tibble",
    "rgdal",
    "rvest",
    "tidyr",
    "xml2",
    # writing
    'devtools',
    'rmarkdown',
    'knitr',
    'bookdown',
    'git2r',
    #vis
    'viridis',
    'plotly',
    'ggforce',
    'ggpmisc',
    'ggrepel',
    'gridExtra'
  )

setwd(paste0(getwd(), 'packages/', )
install.packages(pkgs, repos = NULL, )
# 2. Copy the first path, without quotes (mine is C:/emacs/R/win-library/3.3 )

# 3. Paste this path into your regular windows explorer or finder window

# 4. Now go to the folder on the USB stick that has all the libraries, and open the one that matches your operating systme (the WIN or OSX pkgs folder), then when you can see the folders of hundreds of packages, select all of them (CTLR+A or CMD+A), then copy them to your clipboard (CTRL+C or CMD+C).

# 5. Go to your library path location, and paste the libraries in there (CTRL+V or CMD+V) 

# 6. Wait for the copy to complete, then restart RStudio
