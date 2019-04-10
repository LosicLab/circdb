#!
library(shiny)
library(DT)      #!DT required for display of table
library(ggbio)
library(ASpli)
library(RMariaDB)
library(GenomicFeatures)
library(BSgenome.Hsapiens.UCSC.hg19)
#!Write all data to Data subdirectory to let shiny know where to source
#write.table(master_intergration_table_circRNA__bycirc_FACS__commonSNP,
#					'/Users/user/analysis/projects/cRNA/IBD/analysis/circdb/Data/master_intergration_table_circRNA__bycirc_FACS__commonSNP.tab', col.names = T, row.names = F, sep = '\t', quote = F)

#####################
# dataset
#####################
#dataset <- read.table('Data/master_intergration_table_circRNA__bycirc_FACS__commonSNP.tab', header=T, check.names = F)
dataset <- read.table('Data/master_intergration_table_circRNA__bycirc_FACS__commonSNP_and_distalSNP_with_COLOC__DEG_biopsy_overlap_with_miRNA_binding.tab', header=T, check.names = F)


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

# Get UCSC reference loaded & ready
# - Create an ASpliFeatures object from TxDb
genomeTxDb <- makeTxDbFromUCSC( genome="hg19", tablename="knownGene", transcript_ids=NULL, circ_seqs=DEFAULT_CIRC_SEQS, url="http://genome.ucsc.edu/cgi-bin/", goldenPath_url="http://hgdownload.cse.ucsc.edu/goldenPath", taxonomyId=NA, miRBaseBuild=NA)
features <- binGenome(genomeTxDb)


# # Sashimi plot functions
#make_sashimi <- function(){

targets <- dataset[selected_data,]

# Plot a single bin to a window
plotGenomicRegions(
    features,
    'GENE01:E002',
    genomeTxDb,
    ,
    sashimi = TRUE,
    colors = '#AA4444',
    annotationHeight = 0.1,
    tempFolder = 'tmp',
    verbose = TRUE ,
    avoidReMergeBams = FALSE,
    useTransparency = FALSE )




###############
# UI
###############

ui = fluidPage(

	titlePanel('circdb [MSCCR blood]'),

	DTOutput('tbl')

		      )

############
# SERVER
############

server <- function(input, output) {

	output$tbl <- renderDT(dataset, filter = 'top', options = list(lengthChange=FALSE))

}

############
# APP
############
shinyApp(ui = ui, server = server)
