# prepare database for shiny app

library(tidyverse)
library(GenomicFeatures)
library(Gviz)
library(GenomicRanges)
library(AnnotationDbi)
library(org.Hs.eg.db)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)

#------------
# dataset
#------------
dataset <- read.table('data/master_intergration_table_circRNA__bycirc_FACS__commonSNP_and_distalSNP_with_COLOC__DEG_biopsy_overlap_with_miRNA_binding_with_circbase.tab', header=T, check.names = F)

cid <- c('geneID', 'circID', "Exon1",
         "Exon2", "Strand", 'SpliceType',
         'AveExpr_log2cpm',  'AveExpr_log2cpm_Biopsy',
         'mean_circ_fraction', 'mean_circ_fraction_Biopsy',
         # DE information
         'logFC_CD_vs_Control', 'padj_CD_vs_Control',
         'logFC_UC_vs_Control','padj_UC_vs_Control',
         'logFC_vdjnorm', 'padj_vdjnorm',
         #!miRNA binding information
         'best_binding_miRNA', 'miRNA_bind_sites_per_kB_circRNA',
         #celltype enet model information
         'predictor', 'no_parent_regressed',
         'parent_regressed', 'delta_parent',
         'no_parent_regressed_rank', 'parent_regressed_rank',
         #circQTL
         'num_feature__cRNA', 'num_SNP_feature__cRNA',
         'num_SNP_feature__mRNA' , "middle_beta__cRNA",
         #eQTL parent
         'middle_beta__mRNA', 'cis_trans__mRNA',
         'cis_trans__cRNA','common_or_uncommon', 'opposite_QTL_effect',
         #coloc
         'trait', 'mRNA_mlog10_pval', 'cRNA_mlog10_pval',
         'method','is_cRNA_coloc_greater',
         # circDB
         'circbase_ID', 'genomic_length', 'spliced_seq_length',
         'repeats', 'annotation', 'circRNA_study')

# subset relevant columns for table display
dataset <- dataset[, cid]


cid <- c('GeneSymbol', 'BackspliceLocation', "BackspliceExon1",
         "BackspliceExon2", "Strand", 'SpliceType',
         'AveExpr_log2cpm',  'AveExpr_log2cpm_Biopsy',
         'MeanCircFraction', 'MeanCircFraction_Biopsy',
         # DE information
         'logFC_CD_vs_Control', 'padj_CD_vs_Control',
         'logFC_UC_vs_Control','padj_UC_vs_Control',
         'logFC_vdjnorm', 'padj_vdjnorm',
         #!miRNA binding information
         'best_binding_miRNA', 'miRNA_bind_sites_per_kB_circRNA',
         #celltype enet model information
         'celltype_enet_predictor', 'celltype_enet_no_parent_regressed',
         'celltype_enet_parent_regressed', 'celltype_enet_delta_parent',
         'celltype_enet_no_parent_regressed_rank', 'celltype_enet_parent_regressed_rank',
         #circQTL
         'circQTL_num_feature_cRNA', 'circQTL_num_SNP_feature_cRNA',
         'circQTL_num_SNP_feature_mRNA' , "circQTL_middle_beta_cRNA",
         #eQTL parent
         'parent_eQTL_middle_beta_mRNA', 'parent_eQTL_cis_trans_mRNA',
         'parent_eQTL_cis_trans_cRNA','parent_eQTL_common_or_uncommon', 'parent_eQTL_opposite_QTL_effect',
         #coloc
         'trait', 'mRNA_mlog10_pval', 'cRNA_mlog10_pval',
         'method','is_cRNA_coloc_greater',
         # circbase
         'circbase_ID', 'genomic_length', 'spliced_seq_length',
         'repeats', 'annotation', 'circRNA_study')


chars <- c('geneID', 'circID', 'predictor')
dataset[, chars] <- lapply(dataset[,chars], as.character)

colnames(dataset) <- cid


# separate out numeric, factor, and string columns for their appropriate selections
nums <- sapply(dataset, is.numeric)
facs <- sapply(dataset, is.factor)
chars <- sapply(dataset, is.character)

exprs_cols <- c('logFC_CD_vs_Control', 'logFC_UC_vs_Control', 'logFC_vdjnorm')
pval_cols <- c('padj_CD_vs_Control', 'padj_UC_vs_Control', 'padj_vdjnorm')

# prep df for volcano plot
vdata <- dataset %>%
    mutate(padj_CD_vs_Control = -log(padj_CD_vs_Control),
           padj_UC_vs_Control = -log(padj_UC_vs_Control),
           padj_vdjnorm = -log(padj_vdjnorm))

ensids <- mapIds(org.Hs.eg.db, keys = as.character(dataset$GeneSymbol), column="ENSEMBL", keytype="SYMBOL", multiVals="first")
entrezids <- mapIds(org.Hs.eg.db, keys = as.character(dataset$GeneSymbol), column="ENTREZID", keytype="SYMBOL", multiVals="first")
dataset$ensembl_id <- ensids
dataset$entrez_id <- entrezids

# define genomic browser tracks & info
gbrowsedf <- dataset %>% tidyr::separate(col = BackspliceLocation, into=c('chr', 'start', 'end'),'-|:', remove=FALSE)
gbrowsedf$gr_strand <- as.character(gbrowsedf$Strand)
gbrowsedf$gr_strand[gbrowsedf$gr_strand %in% c('-/+', '+/-')] <- '*'

axis_track <- GenomeAxisTrack()


browser_gr <- makeGRangesFromDataFrame(gbrowsedf, seqnames.field = 'chr', start.field = 'start', end.field = 'end', strand.field = 'gr_strand',keep.extra.columns = TRUE)

snps <- read_tsv('data/common_cRNA_mRNA_SNPS_by_gene.txt')


save(nums, facs, chars, exprs_cols, pval_cols, dataset, gbrowsedf, vdata, axis_track, snps, file='data/_circdb.rdata')


