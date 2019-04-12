# global.R

libs <- c('shiny', 'tidyverse', 'DT', 'shinydashboard')
# install.packages(libs)
lapply(libs, library, character.only=TRUE)


#------------
# dataset
#------------
dataset <- read.table('data/master_intergration_table_circRNA__bycirc_FACS__commonSNP_and_distalSNP_with_COLOC__DEG_biopsy_overlap_with_miRNA_binding.tab', header=T, check.names = F)


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
         'method','is_cRNA_coloc_greater')

# subset relevant columns for table display
dataset <- dataset[, cid]

chars <- c('geneID', 'circID', 'predictor')
dataset[, chars] <- lapply(dataset[,chars], as.character)

# separate out numeric, factor, and string columns for their appropriate selections
nums <- sapply(dataset, is.numeric)
facs <- sapply(dataset, is.factor)
chars <- sapply(dataset, is.character)

