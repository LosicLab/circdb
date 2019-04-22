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

# # # # # tooltips

col_details <- read_csv('data/master_data_header.txt', col_names = c('colname', 'detail'))

args <- paste(paste0("th(\'", col_details$colname,"\', title=\'",col_details$detail, "\')"), collapse = ',')

sketch <- htmltools::withTags(table(
  class = 'display',
  thead(
    tr(
      th('GeneSymbol', title='GeneSymbol: geneic locus of transcription'),
      th('BackspliceLocation', title='Backsplice: start/end of backsplice mapping in hg19'),
      th('circbase_ID', title='circbase_ID: circbase ID for this backsplice'),
      th('BackspliceExon1', title='Exon_1: annotated first exon within major isoform'),
      th('BackspliceExon2', title='Exon_2: annotated second exon within major isoform'),
      th('Strand', title='Strand: backsplice alignment strand'),
      th('SpliceType', title='SpliceType: exonic or intronic circRNA'),
      th('genomic_length', title='GenomicLength: length of unspliced circRNA'),
      th('spliced_seq_length', title='SplicedLength: length of spliced circRNA'),
      th('annotation', title='Annotation: overlapping known hg19 annotation'),
      th('repeats', title='Repeats: overlapping known repeats'),
      th('in_other_samples', title='InOtherSamples: also found in these celltypes'),
      th('circRNA_study', title='InOther_circRNA_study: also observed in these studies'),
      th('AveExpr_log2cpm', title='AverageExpression: log2cpm average MSCCR-blood expression'),
      th('AveExpr_log2cpm_Biopsy', title='AverageExpression: log2cpm average MSCCR-biopsy expression (if observed)'),
      th('mean_circ_fraction', title='MeanCircularization: backsplice support normalized by maximal forward splice (MSCCR-blood)'),
      th('mean_circ_fraction_Biopsy', title='MeanCircularization: backsplice support normalized by maximal forward splice (MSCCR-biopsy)'),
      th('logFC_CD_vs_Control', title='logFoldChange_CD_vs_Control: log fold change for CD vs Control (MSCCR-blood)'),
      th('padj_CD_vs_Control', title='p_adj_CD_vs_Control: BH-corrected p value for CD vs Control (MSCCR-blood)'),
      th('logFC_UC_vs_Control', title='logFoldChange_UC_vs_Control: log fold change for UC vs Control (MSCCR-blood)'),
      th('padj_UC_vs_Control', title='p_adj_UC_vs_Control: BH-corrected p value for UC vs Control (MSCCR-blood)'),
      th('logFC_vdjnorm', title='logFoldChange_VDJ_seq: log fold change for T/BCR seq normalized total expression (MSCCR-blood)'),
      th('padj_vdjnorm', title='p_adj_VDJ_seq: BH-corrected p value for for T/BCR seq normalized total expression (MSCCR-blood)'),
      th('best_binding_miRNA', title='Predicted_miRNA: best-3prime UTR binding miRNA'),
      th('miRNA_bind_sites_per_kB_circRNA', title='miRNA_Sponginess: number of miRNA binding sites per kB spliced circRNA'),
      th('predictor', title='CellType: FACS category used in elastic-net model for circRNA expression'),
      th('no_parent_regressed', title='CellType_enet_Coefficient_without_parent: value of elastic-net coefficient for predictor without parent mRNA regressed'),
      th('parent_regressed', title='CellType_enet_Coefficient_with_parent: value of elastic-net coefficient for predictor with parent mRNA regressed (<=CellType_enet_Coefficient)'),
      th('delta_parent', title='CellType_Parent_Effect: difference in elastic-net coefficients when regressing out parent'),
      th('no_parent_regressed_rank', title='CellType_enet_model_rank: term rank in model (lowest is more important; highest least important) without regressing parent mRNA'),
      th('parent_regressed_rank', title='CellType_enet_model_rank: term rank in model (lowest is more important; highest least important) with regressing parent mRNA'),
      th('num_feature__cRNA', title='Num_of_circRNA_isoforms: number of distinct circRNA transcribed from same locus controlled by SNP'),
      th('num_SNP_feature__cRNA', title='Num_SNPs: number of SNPs associated with circRNA'),
      th('num_SNP_feature__mRNA', title='Num_SNPs: number of SNPs associated with mRNA'),
      th('middle_beta__cRNA', title='AverageBeta_circRNA: average logFoldChange in circRNA for every copy of variant allele'),
      th('middle_beta__mRNA', title='AverageBeta_mRNA: average logFoldChange in parent mRNA for every copy of variant allele'),
      th('cis_trans__mRNA', title='Cis_Trans_mRNA: cis or trans SNPs for mRNA'),
      th('cis_trans__cRNA', title='Cis_Trans_mRNA: cis or trans SNPs for circRNA'),
      th('common_or_uncommon', title='Opposite_QTL_Effects: do AverageBeta_circRNA and AverageBeta_mRNA have same sign (common)'),
      th('opposite_QTL_effect', title='Opposite_QTL_Effects: do AverageBeta_circRNA and AverageBeta_mRNA have same sign (no)'),
      th('trait', title='coloc_Trait: phenotypic trait tested in de Lange GWAS (PMC5289481): IBD | CD | UC'),
      th('mRNA_mlog10_pval', title='mRNA_parent_cauaslity_pvalue: -log10(p_value) of causality test for risk mediation (pleiotropy null); SNP -> mRNA -> trait'),
      th('cRNA_mlog10_pval', title='circRNA_parent_cauaslity_pvalue: -log10(p_value) of causality test for risk mediation (pleiotropy null); SNP -> circRNA -> trait'),
      th('method', title='coloc_method: colcalization method used (SMR | MetaXCan | COLOC)'),
      th('is_cRNA_coloc_greater', title='circRNA_colocalize: do circRNA daughers mediate more risk for trait than mRNA parents')
    )
  )
))
datatable(dataset, container = sketch)
