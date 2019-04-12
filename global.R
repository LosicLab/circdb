# global.R

libs <- c('shiny', 'tidyverse', 'DT', 'shinydashboard', 'ggrepel')
# install.packages(libs)
lapply(libs, library, character.only=TRUE)

load('data/_circdb.rdata')