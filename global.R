# global.R

libs <- c('shiny', 'tidyverse', 'DT', 'shinydashboard', 'ggrepel', 'GenomicFeatures', 'Gviz')
# install.packages(libs)
lapply(libs, library, character.only=TRUE)

load('data/_circdb.rdata')

