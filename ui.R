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
                        box(width=4, title = "Scatter",
                        solidHeader = TRUE, plotOutput("scatter")),

                        tabBox(width=8, height = 400,
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
                fluidRow(
                    box(width = 4, title = "Histogram",
                             solidHeader = TRUE, plotOutput("hist")),
                    tabBox(width=8, height = 400,
                           tabPanel(title = "Genome Browser",
                                    solidHeader = TRUE, plotOutput("gbrowser")),

                           tabPanel(title='Browser Settings', solidHeader=TRUE, icon=icon('cog', lib='font-awesome'),
                                    selectInput('gsymbol', 'select a circle:', test$GeneSymbol) )
                           )
                    ),
                fluidRow(
                    tabBox(width = 4,
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
