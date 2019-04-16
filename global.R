# global.R

libs <- c('shiny',
          'tidyverse',
          'DT',
          'shinydashboard',
          'ggrepel',
          'GenomicFeatures',
          'Gviz',
          'GenomicRanges',
          'TxDb.Hsapiens.UCSC.hg19.knownGene')

# install.packages(libs)
lapply(libs, library, character.only=TRUE)

load('data/_circdb.rdata')


genome <- TxDb.Hsapiens.UCSC.hg19.knownGene