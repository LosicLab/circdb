library(tidyverse)
library(ggbio)

plotSpliceSum(bamfile, txdb, which = genesymbol["RBM17"])

# Get UCSC reference loaded & ready
# - Create an ASpliFeatures object from TxDb
genomeTxDb <- makeTxDbFromUCSC( genome="hg19", tablename="knownGene", transcript_ids=NULL, circ_seqs=DEFAULT_CIRC_SEQS, url="http://genome.ucsc.edu/cgi-bin/", goldenPath_url="http://hgdownload.cse.ucsc.edu/goldenPath", taxonomyId=NA, miRBaseBuild=NA)
features <- binGenome(genomeTxDb)



targets <- dataset[selected_data,]

# Plot a single bin to a window
plotGenomicRegions(
    features,
    'CDC14A',
    genomeTxDb,
    targets=dataset,
    sashimi = TRUE,
    colors = '#AA4444',
    annotationHeight = 0.1,
    tempFolder = 'tmp',
    verbose = TRUE ,
    avoidReMergeBams = FALSE,
    useTransparency = FALSE )

data_summary <- dataset %>%
  group_by(trait) %>%
  summarise(count_per_trait = n()) %>%
  arrange(desc(count_per_trait)) %>%
  mutate(prop=count_per_trait / nrow(dataset),
         lab.ypos= cumsum(prop) - 0.5*prop)

output$hist <- renderPlot(ggplot(dataset) + aes(x=log(mean_circ_fraction)) +
               geom_density(fill='red', alpha=0.5) + theme_classic())

output$plt2 <- renderPlot(ggplot(data_summary) + aes(x='', y=prop, fill=trait) +
                         geom_bar(width = 1, stat = "identity", color = "white") +
                           coord_polar("y", start=0) + theme_void())
