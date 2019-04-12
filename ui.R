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
