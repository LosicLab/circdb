library(tidyverse)
library(ggbio)

library(BSgenome.Hsapiens.UCSC.hg19)
library(ASpli)
library(Gviz)
library(AnnotationDbi)
library(org.Hs.eg.db)

# Get UCSC reference loaded & ready
# - Create an ASpliFeatures object from TxDb

#
#
#
# features <- binGenome(genomeTxDb, logTo = NULL)
#
#
# targets <- data.frame(
#     row.names = c('simulated_reads_hg19_dbsnp'),
#     bam = system.file( 'extdata', 'genome/simulated_reads.bam', package="ASpli" ),
#     factor1 = c( 'NA'),
#     stringsAsFactors = FALSE )
#
#
#
# ensids <- mapIds(org.Hs.eg.db, keys = as.character(dataset$GeneSymbol), column="ENSEMBL", keytype="SYMBOL", multiVals="first")
# dataset$ensembl_id <- ensids
#
#
#
#
# # Plot a single bin to a window
# plotGenomicRegions(
#     features,
#     dataset,
#     genomeTxDb,
#     targets,
#     sashimi = TRUE,
#     colors = '#AA4444',
#     annotationHeight = 0.1,
#     tempFolder = 'tmp',
#     verbose = TRUE ,
#     avoidReMergeBams = FALSE,
#     useTransparency = FALSE )
#
#
#
# data_summary <- dataset %>%
#   group_by(trait) %>%
#   summarise(count_per_trait = n()) %>%
#   arrange(desc(count_per_trait)) %>%
#   mutate(prop=count_per_trait / nrow(dataset),
#          lab.ypos= cumsum(prop) - 0.5*prop)
#
# output$hist <- renderPlot(ggplot(dataset) + aes(x=log(mean_circ_fraction)) +
#                geom_density(fill='red', alpha=0.5) + theme_classic())
#
# output$plt2 <- renderPlot(ggplot(data_summary) + aes(x='', y=prop, fill=trait) +
#                          geom_bar(width = 1, stat = "identity", color = "white") +
#                            coord_polar("y", start=0) + theme_void())
#
#

test <- dataset %>% tidyr::separate(col = BackspliceLocation, into=c('chr', 'start', 'end'),'-|:', remove=FALSE)
test$gr_strand <- as.character(test$Strand)
test$gr_strand[test$gr_strand %in% c('-/+', '+/-')] <- '*'

axis_track <- GenomeAxisTrack()
ensembl_gene_track <- BiomartGeneRegionTrack(genome="hg19", name="ENSEMBL", symbol=as.character(test$GeneSymbol[1]))
#sTrack <- SequenceTrack(Hsapiens)
plotTracks(list(axis_track, ensembl_gene_track))

test_gr <- makeGRangesFromDataFrame(test, seqnames.field = 'chr', start.field = 'start', end.field = 'end', strand.field = 'gr_strand',keep.extra.columns = TRUE)

library('GenVisR')
# need transcript data for reference
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene

# need a biostrings object for reference
library(BSgenome.Hsapiens.UCSC.hg19)
genome <- BSgenome.Hsapiens.UCSC.hg19

gr <- test_gr[test_gr$BackspliceLocation == 'chr1:100889778-100908552']

layer_track <- geom_curve()

p1 <- geneViz(txdb, gr, genome, reduce=TRUE, labelTranscript = TRUE, labelTranscriptSize = TRUE)
plot <- p1[[1]]
plot

plot + geom_curve(x=p1[[2]]$start, xend=p1[[2]]$end)



