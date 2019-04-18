# ui.R

#------------
# UI
#------------

header <- dashboardHeader(title = 'circdb [MSCCR blood]')

body <- dashboardBody(
    tabItems(
        # start with a dashboard-style home page
        tabItem(tabName = "visualize",
                fluidRow(
                    tabBox(width=12,
                           tabPanel(title = "Gene Browser",
                                    solidHeader = TRUE,
                                    h5(textOutput('gbrowse_title')),
                                    plotOutput("gbrowser")
                                    ),

                           tabPanel(title='Browser Settings',
                                    solidHeader=TRUE,
                                    icon=icon('cog', lib='font-awesome'),
                                    selectInput('gsymbol', 'select a circID:', gbrowsedf$BackspliceLocation, gbrowsedf$BackspliceLocation[1])
                                    )
                    ) #,
                    # tabBox(width=4,
                    #        tabPanel(title = "Regulatory circQTLs",
                    #                 solidHeader = TRUE,
                    #                 h5(textOutput('circQTL_title')),
                    #                 plotOutput("circqtlos")
                    #        ),
                    #        
                    #        tabPanel(title='circQTL Settings',
                    #                 solidHeader=TRUE,
                    #                 icon=icon('cog', lib='font-awesome'),
                    #                 selectInput('circqtlid', 'select a circID:', snps$trait_id, snps$trait_id[1])
                    #        )
                    #)
                ),
                fluidRow(
                  tabBox(width=12,
                         tabPanel(title = "Volcano Plots",
                                  solidHeader = TRUE, plotOutput("volcano_plot")),
                         
                         tabPanel(title='Volcano Plot Settings', solidHeader=TRUE, icon=icon('cog', lib='font-awesome'),
                                  numericInput('volcano_label_pcutoff', label = 'Gene label p-value cutoff', value=0.05, min=0, max=1),
                                  selectInput('volcanox', 'X: Expression', names(dataset[, exprs_cols])),
                                  selectInput('volcanoy', 'Y: P values', names(dataset[, pval_cols])),
                                  selectInput('volcano_color', 'Color', c('None', names(dataset[, !chars]))),
                                  selectInput('volcano_label', 'Label', c('None', names(dataset[, chars|facs])))
                         )
                  )
                ),
                fluidRow(tabBox(width=6,
                                tabPanel( title = "Scatter",
                                          solidHeader = TRUE,
                                          plotOutput("scatter")),
                                tabPanel(title = "Scatter Settings",
                                         solidHeader = TRUE,
                                         icon=icon('cog', lib='font-awesome'),
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
                                )
                ),
                tabBox(width = 6,
                       tabPanel(title = "Histogram",
                                solidHeader = TRUE, plotOutput("hist")),
                       tabPanel(title = "Histogram Settings", solidHeader = TRUE, icon=icon('cog', lib='font-awesome'),
                                br(),
                                # to visualize all the circles with
                                # user-specified parameters
                                selectInput('hsx', 'X', names(dataset[, nums])),
                                selectInput('hscolor', 'Color', c('None', names(dataset[, !(chars|nums)]))),
                                selectInput('hsfacet_row', 'Facet Row', c(None='.', names(dataset[, facs]))),
                                selectInput('hsfacet_col', 'Facet Column', c(None='.', names(dataset[, facs]))) #,
                                #checkboxInput('hslogx', 'Log Transform X') # as of right now this does not work
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

ui <- dashboardPage(
    header,
    sidebar,
    body
)
