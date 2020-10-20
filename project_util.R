#!/usr/bin/Rscript
# call this at the begining

#prepare local library path
if (dir.exists('./lib/vendor') == FALSE) {
  dir.create('./lib/vendor', recursive = TRUE)
}

.libPaths(c("./lib/vendor", .libPaths()))
lib_paths <- .libPaths()
my_lib = lib_paths[1]
global_lib = lib_paths[2]
if (global_lib == my_lib) {
  global_lib = lib_paths[3]
}

print(paste("Library Path:", my_lib, sep = ""))
print(paste("Global Library Path:", global_lib, sep = ""))

# function to install packages required by this tool
install_mininum_packages <- function() {
  x <- c('dplyr', 'optparse','devtools','withr')
  installed_packages = rownames(installed.packages())
  for (p in x) {
    if (p %in% installed_packages == FALSE) {
      install.packages(p, lib = global_lib)
    } else {
      # print (paste(p, " already exists", sep = ""))
    }
  }
}
install_mininum_packages()

library(dplyr)
library(stringr)

install_global_packages <- function() {
  global_packages_required = c('dplyr','shiny','stringr')
  if (file.exists("global_packages.txt")){
    global_packages_required = readLines('global_packages.txt')
  }
  
  installed_packages = rownames(installed.packages())

  for (p in global_packages_required) {
    if (p %in% installed_packages == FALSE) {
      install.packages(p, lib = global_lib)
      print(paste(p, " installed", sep = ""))
    } else {
      print(paste(p, " already exists", sep = ""))
    }
  }
}

# function to create setenv.sh
init_setenv <- function() {
  # create setenv.sh
  if (file.exists("./setenv.sh")) {
    print(paste("setenv.sh already exists"))
  } else {
    txt <- '#!/bin/bash
export R_LIBS="`pwd`/lib/vendor":$R_LIBS
    '
    fp <- file("./setenv.sh")
    writeLines(txt, fp)
    close(fp)
    print("setenv.sh is created")
    system("chmod +x setenv.sh")
  }

  # create global_packages.txt  
  if (! file.exists("global_packages.txt")){
    global_packages_required = c('dplyr','ggplot2','stringr')
    writeLines(global_packages_required,'global_packages.txt')
  }

  # write to .gitignore
  if (! file.exists('.gitignore')){
    x = c('lib/vendor','.vscode')
    writeLines(x,'.gitignore')
  }else{

  }

}


freeze_package <- function(file_name) {
  x <- installed.packages()
  x <- as.data.frame(x)
  y <- select(x, Version, LibPath)

  z <- filter(y, LibPath == my_lib)
  z1 = select(z, Version)
  print(z1)

  write.csv(z1, file = file_name, append = FALSE, quote = TRUE)

}

#
# version	in requirements.txt. Tips: pay attention to the space inside verison field. 
# Version of the package to install. Can either be a string giving the exact version required, or a specification in the same format as the parenthesized expressions used in package dependencies. One of the following formats:
# An exact version required, as a string, e.g. "0.1.13"
# A comparison operator and a version, e.g. ">= 0.1.12"
# Several criteria to satisfy, as a comma-separated string, e.g. ">= 1.12.0, < 1.14"
# Several criteria to satisfy, as elements of a character vector, e.g. c(">= 1.12.0", "< 1.14")
restore_requirements <- function(file_name) {
  library(devtools)
  df <- read.csv(file = file_name)

  # get current package
  x <- installed.packages()
  x <- as.data.frame(x)
  y <- select(x, Version, LibPath)

  cdf <- filter(y, LibPath == my_lib)

  for (row in 1:nrow(df)) {
    p <- df[row, "X"]
    v <- df[row, "Version"]

    if (p %in% rownames(cdf)) {
      print(paste("Package", p, "already exists"))
    } else {
      print(c(p, v))      
      # install the package
      matched = str_match(v,">|<|=")
      if ( !is.na(matched[1])){
        # version must equal to       
        withr::with_libpaths(new = my_lib,  
          install_version(p, version = v, repos = "http://cran.us.r-project.org")
        )
      }else{
        # default install latest version
        install.packages(p, lib = my_lib)
      }      
    }
  }
}

install_package <- function(x) {
  install.packages(x, lib = my_lib)
}


# process parameters
library("optparse")
option_list = list(
  make_option(c("-i", "--install_package"), type = "character", default = NULL,
              help = "package name to install", metavar = "character"),
  make_option(c("-e", "--enforce_version"), type = "logical", action = "store_true", default = FALSE,
              help = "package version enforced to install.", metavar = "character"),
  make_option(c("-f", "--freeze"), type = "logical", action = "store_true", default = FALSE,
              help = "output local lib packages to requirements.txt", metavar = "character"),
  make_option(c("--freeze_file"), type = "character", action = "store_true", default = "requirements.txt",
              help = "file name to dump packages list. default requirements.txt", metavar = "character"),
  make_option(c("-g", "--install_global"), type = "logical", action = "store_true", default = FALSE,
              help = "Install global required packages for shiny development ", metavar = "character"),
  make_option(c("-r", "--restore"), type = "logical", action = "store_true", default = FALSE,
              help = "restore packages from requirements.txt to local lib", metavar = "character"),
  make_option(c("--init"), type = "logical", action = "store_true", default = FALSE,
              help = "create setenv.sh", metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.character(opt$install_package)) {
  install_package(opt$install_package)
} else if (opt$freeze) {
  freeze_package(opt$freeze_file)
} else if (opt$restore) {
  restore_requirements(opt$freeze_file)
} else if (opt$install_global) {
  install_global_packages()
} else if (opt$init) {
  init_setenv()
} else {
  print_help(opt_parser)
  # test
}

