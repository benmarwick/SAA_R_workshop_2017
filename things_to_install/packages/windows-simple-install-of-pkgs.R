# Here's how to install packages with no internet connection:

# 1. # Specify list of packages to download/install


# get list of the binary files in this dir

pkgs <- list.files("things_to_install/packages/Windows_package_binaries/",
                   full.names = TRUE)

# 2. install from these

install.packages(pkgs, 
                 repos = NULL, 
                 type = "binary")


# --------------------------------------------------------
# I prepared the binaries by making a list of pkg names,
# installing them from CRAN, then copying the binaries files
# from the temporary folder. The unpacked binaries are much too
# big for convenient transfer by USB drive. 
