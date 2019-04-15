# global.R

libs <- c('shiny', 'tidyverse', 'DT', 'shinydashboard', 'ggrepel', 'GenomicFeatures', 'Gviz', 'GenomicRanges')
# install.packages(libs)
lapply(libs, library, character.only=TRUE)

load('data/_circdb.rdata')