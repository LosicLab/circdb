library(shiny)
library(tidyverse)
library(DT)
library(shinydashboard)
library(dashboardthemes)

#------------
# dataset
#------------
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

chars <- c('geneID', 'circID', 'predictor')
dataset[, chars] <- lapply(dataset[,chars], as.character)

# separate out numeric, factor, and string columns for their appropriate selections
nums <- sapply(dataset, is.numeric)
facs <- sapply(dataset, is.factor)
chars <- sapply(dataset, is.character)


header <- dashboardHeader(title = 'circdb [MSCCR blood]')

body <- dashboardBody(
  tabItems(
        # start with a dashboard-style home page
        tabItem(tabName = "visualize", 
                fluidRow(
                  box(title = "Histogram", status='info',
                      solidHeader = TRUE, plotOutput("hist", height = 250)),
                  box(title = "Scatter", status='info',
                      solidHeader = TRUE, plotOutput("scatter", height = 250))
                ),
                fluidRow(
                  tabBox(width = 12,
                    tabPanel(title = "Scatter Settings", solidHeader = TRUE, status='warning',
                          br(),
                          # to visualize all the circles with
                          # user-specified parameters
                          selectInput('scx', 'X', names(dataset[, nums])),
                          selectInput('scy', 'Y', names(dataset[, nums]), names(dataset[, nums])[[2]]),
                          selectInput('sccolor', 'Color', c('None', names(dataset[, !chars]))),
                          selectInput('scfacet_row', 'Facet Row', c(None='.', names(dataset[, facs]))),
                          selectInput('scfacet_col', 'Facet Column', c(None='.', names(dataset[, facs])) #,
                          # checkboxGroupInput("variable", "Log transform variable?",
                          #                    c("X" = "sclogx",
                          #                      "Y" = "sclogy"))
                          )
                      ),
                    tabPanel(title = "Histogram Settings", solidHeader = TRUE,status='warning',
                            br(),
                            # to visualize all the circles with
                            # user-specified parameters
                            selectInput('hsx', 'X', names(dataset[, nums])),
                            selectInput('hscolor', 'Color', c('None', names(dataset[, !(chars|nums)]))),
                            selectInput('hsfacet_row', 'Facet Row', c(None='.', names(dataset[, facs]))),
                            selectInput('hsfacet_col', 'Facet Column', c(None='.', names(dataset[, facs]))),
                            checkboxInput('hslogx', 'Log Transform X')
                            )
                      )
                  )
                ),
        
        tabItem(tabName = "table",
                fluidRow(box(title= 'Table Explorer', 
                             solidHeader = TRUE, dataTableOutput('tbl'), width = 12))
        )
    )
  )

sidebar <- dashboardSidebar(
  menuItem("Vizualize", tabName = "visualize", icon=icon('chart-area', lib='font-awesome')),
  menuItem("Explore Table", tabName = "table", icon = icon('columns', lib="font-awesome"))
)

#------------
# UI
#------------
ui <- dashboardPage(
  header,
  sidebar,
  body
)


#------------
# SERVER
#------------

server <- function(input, output) {
  
  # select data from reactive user input
  plot_data <- reactive(dataset)
  
  # ---------------------
  # Create output objects 
  # ---------------------
  
  # make the reactive scatter plot object
  output$scatter <- renderPlot({
    # if (input$sclogx){
    #   input$scx <- log(input$scx)
    # }
    # if (input$sclogy){
    #   input$scy <- log(input$scy)
    # }
    scatter <- ggplot(plot_data(), aes_string(x=input$scx, y=input$scy)) + geom_point() + theme_classic()
    if (input$sccolor != 'None'){
      scatter <- scatter + aes_string(color=input$sccolor)
      }
    facets <- paste(input$scfacet_row, '~', input$scfacet_col)
    if (facets != '. ~ .'){
      scatter <- scatter + facet_grid(facets)
    }
    print(scatter)
    })
  
  # make the reactive histogram
  output$hist <- renderPlot({
    if (input$hslogx == TRUE){
      input$scx <- log(input$hsx)
    }
    
    hist <- ggplot(plot_data(), aes_string(x=input$hsx)) + geom_density() + theme_classic()
    if (input$hscolor != 'None'){
      hist <- hist + aes_string(fill=input$hscolor)
    }
    facets <- paste(input$hsfacet_row, '~', input$hsfacet_col)
    if (facets != '. ~ .'){
      hist <- hist + facet_grid(facets)
    }
    print(hist)
    })
  
  # render output datatable
  output$tbl <- renderDataTable(dataset, filter = 'top', options=list(scrollX=TRUE))
}

#------------
# APP
#------------
shinyApp(ui = ui, server = server)
