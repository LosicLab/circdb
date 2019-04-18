library(tidyverse)
library(ggbio)

library(BSgenome.Hsapiens.UCSC.hg19)
library(ASpli)
library(Gviz)

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




# need transcript data for reference
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(AnnotationDbi)
genome <- TxDb.Hsapiens.UCSC.hg19.knownGene

junction <- browser_gr[browser_gr$BackspliceLocation == browser_gr$BackspliceLocation[1]]




gquery <- genes(genome)[which(genes(genome)$gene_id == junction$entrez_id),]

# get the exons with the gene coordinates
gquery <- subsetByOverlaps(exons(genome), gquery)

exons <- gquery[c(junction$BackspliceExon1:junction$BackspliceExon2),]



#----------------
# circlize
# ---------------
library(tidyverse)
library(circlize)
test_circle <- 'chr10:13233299-13234568'
snps <- read_tsv('data/common_cRNA_mRNA_SNPS_by_gene.txt')
snps_filtered <- snps %>%
                 as_tibble() %>%
                 dplyr::filter(trait_id == test_circle) %>%
                 mutate(chr=paste0('chr', chr),
                        pos=as.numeric(pos),
                        pos2=as.numeric(pos),
                        val=-log(pvalue)) %>%
                 dplyr::select(chr, pos, pos2, val)

snps_filtered <- as.data.frame(snps_filtered)

# , chromosome.index = paste0("chr", c(1:22, "X", "Y"))
circos.initializeWithIdeogram(species='hg19') 
## important to have enough space for the plots
circos.par("track.height" = 0.2)


circos.genomicTrack(snps_filtered, ylim=c(min(snps_filtered$val), max(snps_filtered$val)), panel.fun = function(region, val, ...) {
  circos.genomicPoints(region, val, col = 'black', pch = 16, cex = 0.5, ...)
  
})
circos.clear()


