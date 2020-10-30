# virtual.R
Utilities to manage project level R library. It is used to get something like Python virtual env.
This project is developed under Linux (Ubuntu), you might need adjust some PATH settings if you are not on Linux.

## How does it work 
This utility will create a folder, ./lib/vendor, in project folder.
This folder will be the project level library.

The original default Libraries will be referenced as gloabl libraries. The utility only uses the top one, the library under current user. And other libraries at root level won't be touched.

The utility has a few commands which will manage the project and libraries for you. Explaiend in usage section.

# Install
1. download project_util.R to ~/bin
2. give execute permission `chmod +x ~/bin/project_util.R`
3. Add ~/bin to your PATH in .bashrc `export PATH=~/bin:$PATH`
4. create a alias to something shorter in your .bashrc(optional). e.g. `alias virtualr`

# Usage
## Create your R project
You will create your R project with your normal procedure.

## initialize project
Go into your project folder and 
run `virtual.R --init`

This command will create or modify a few scripts in your project folder.
1. setenv.sh
2. .gitignore (add ignore folders)
3. global_packages.txt
4. requiremetns.txt (example only)

### setenv.sh
this script need be called when you start to development. It will set R_LIBS in environment and add ./lib/vendor to the library paths.

you need run `. setenv.sh` before you start any R sessions. e.g. in command line, or start R studio. 

to start R studio, you can type `rstudio` after calling `. setenv.sh`. If you open R studio from Menu, proejct level library won't take effect.

to start VS code, type `code` after calling `. setenv.sh`

### global_packages.txt
This file is used when you developing multiple similiar projects and they are sharing common libraries and you want to save some space and install time for the project.
in that case put libraries in this file and call `virtual.R -g`
It will read content from this file and install libraries in the global library.

### requirements.txt
this file is used for managing project level libraries. You need maintain this file to track what libraries is required. 
e.g.
```
"","Version"
"curl","4.3"
"quantmod",">= 0.4.0"
"TTR","0.24.2"
"xts","0.12.1"
"zoo","1.8-8"
```
Version of the package to install. Can either be a string giving the exact version required, or a specification in the same format as the parenthesized expressions used in package dependencies. One of the following formats:
1. An exact version required, as a string, e.g. "0.1.13"
2. A comparison operator and a version, e.g. ">= 0.1.12"
3. Several criteria to satisfy, as a comma-separated string, e.g. ">= 1.12.0, < 1.14"
4. Several criteria to satisfy, as elements of a character vector, e.g. c(">= 1.12.0", "< 1.14")

## Usage druring project development

## freeze
use this command to generate libraries list and save to a file to track. default file name is requirements.txt
e.g. 
```
virtual.R -f

virtual.R -f --freeze_file t1.txt

```
## restore
use this command after you clone your project. the default file is requirements.txt.

parameter --enforce_version TRUE|FALSE default TRUE This parameter controlsl if you need enforce to exact version number or not. By default freeze command will generate libraries with version. Without modifying it, the restore command will restore with exact version number. But if you want use >= with version number other than modify the requirements.txt, you can give this parameter with FALSE.

e.g.
```
# use default requirements.txt and force to exact version for lines like "zoo", "1.0.1"

virtual.R -r 

# this command will restore libraries and use >= other than exact numbers for lines like "zoo", "1.0.1"

virtual.R -r --enforce_version FALSE

# use none default file to restore

virtual.R -r --freeze_file t1.txt
```

In case you are missing some libraries in global libraries, run `virtual.R -g`

## install package by using this utility
`virtual.R -i <package_name>`







