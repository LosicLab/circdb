# ui.R

#------------
# UI
#------------

ui <- navbarPage('circDB',
          
          # PAGE 1: circRNA Browser to look at your favorite circle
          tabPanel("circBrowser",
                   sidebarLayout(
                     sidebarPanel(selectInput('gsymbol', 'select a circID:', gbrowsedf$circID, gbrowsedf$circID[1])),
                     mainPanel(
                       fluidRow(
                         valueBox(input$gsymbol, icon = 'dna')
                         ),
                       fluidRow(
                               box(width=8,
                                   title = "Gene Browser",
                                                solidHeader = TRUE,
                                                h5(textOutput('gbrowse_title')),
                                                plotOutput("gbrowser")
                               ),
                               box(width=4,
                                     title = "Regulatory circQTLs",
                                     solidHeader = TRUE,
                                     h5(textOutput('circQTL_title')),
                                     plotOutput("circqtlos")
                               )
                               )
                     )
                   )
          ),
    # PAGE 2: explorer plots  
    tabPanel(
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
        )
),

# PAGE 3: 
tabPanel(title= "table",
                fluidRow(box(title= 'Table Explorer',
                             solidHeader = TRUE, DT::dataTableOutput('tbl'), width = 12))
        )
)
)