# ui.R

#------------
# UI
#------------

header <- dashboardHeader(title = 'circdb [MSCCR blood]')

body <- dashboardBody( 
tabItems(
    # start with a dashboard-style home page
    tabItem(tabName = "circBrowser",
            fluidRow(
                infoBox(value = infoBoxOutput('gbrowse_title'), title ="circBrowse",subtitle=HTML("&nbsp;"), icon = icon('dna', lib = 'font-awesome'), color = 'teal',fill=TRUE, width=8),
                infoBox(value = infoBoxOutput('circQTL_title'), title ="circQTL", subtitle = HTML("&nbsp;"), icon = icon('dna', lib = 'font-awesome'), color='maroon', fill=TRUE, width=4)
            ),
            
            fluidRow(
                tabBox(width=8,
                       tabPanel(title = "Gene Browser",
                                solidHeader = TRUE, status='info',
                                h5(textOutput('gbrowse_title')),
                                plotOutput("gbrowser")
                       ),
                       
                       tabPanel(title='Browser Settings',
                                solidHeader=TRUE,status='info',
                                icon=icon('cog', lib='font-awesome'),
                                selectInput('gsymbol', 'select a circID:', gbrowsedf$circID, gbrowsedf$circID[1])
                       )
                ),
                tabBox(width=4,
                       tabPanel(title = "Regulatory circQTLs",
                                solidHeader = TRUE,status='info',
                                h5(textOutput('circQTL_title')),
                                plotOutput("circqtlos")
                       ),
                       
                       tabPanel(title='circQTL Settings',
                                solidHeader=TRUE,status='info',
                                icon=icon('cog', lib='font-awesome'),
                                selectInput('circqtlid', 'select a circID:', snps$trait_id, snps$trait_id[1])
                       )
                )
            )
            ),
            tabItem(tabName = "Volcano",
                    fluidRow(
                        tabBox(width=12,
                               tabPanel(title = "Volcano Plots",
                                        solidHeader = TRUE,color='black', plotOutput("volcano_plot"),status='info'),
                               
                               tabPanel(title='Volcano Plot Settings', solidHeader=TRUE, status='info',icon=icon('cog', lib='font-awesome'),
                                        numericInput('volcano_label_pcutoff', label = 'Gene label p-value cutoff', value=0.05, min=0, max=1),
                                        selectInput('volcanox', 'X: Expression', names(dataset[, exprs_cols])),
                                        selectInput('volcanoy', 'Y: P values', names(dataset[, pval_cols])),
                                        selectInput('volcano_color', 'Color', c('None', names(dataset[, !chars]))),
                                        selectInput('volcano_label', 'Label', c('None', names(dataset[, chars|facs])))
                               )
                        )
                    )
            ),
            tabItem(tabName = 'scatter and histogram',
                    fluidRow(tabBox(width=12,
                                    tabPanel( title = "Scatter",
                                              solidHeader = TRUE,status='info',
                                              plotOutput("scatter")),
                                    tabPanel(title = "Scatter Settings",
                                             solidHeader = TRUE,status='info',
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
                    )
                    ),
                    fluidRow(
                        tabBox(width = 12,
                               tabPanel(title = "Histogram",status='info',
                                        solidHeader = TRUE, plotOutput("hist")),
                               tabPanel(title = "Histogram Settings", solidHeader = TRUE, icon=icon('cog', lib='font-awesome'),
                                        br(),status='info',
                                        # to visualize all the circles with
                                        # user-specified parameters
                                        selectInput('hsx', 'X', names(dataset[, nums])),
                                        selectInput('hscolor', 'Color', c('None', names(dataset[, !(chars|nums)]))),
                                        selectInput('hsfacet_row', 'Facet Row', c(None='.', names(dataset[, facs]))),
                                        selectInput('hsfacet_col', 'Facet Column', c(None='.', names(dataset[, facs])))
                               )
                        )
                    )
            ),
            tabItem(tabName = "table",
                    fluidRow(
                        box(title= 'Table Explorer',status='info',
                            solidHeader = TRUE, DT::dataTableOutput('tbl'), width = 12)
                    )
            ),
    tabItem(tabName = "about",
            fluidRow(box(title= 'About',status='info',
                         solidHeader = TRUE, textOutput('about_text'), width = 12))
    )
)
)

sidebar <- dashboardSidebar(
    menuItem("circBrowser", tabName="circBrowser", icon= icon('dna', lib = 'font-awesome')),
    menuItem("Volcano Plot", tabName = "Volcano", icon=icon('fire', lib='font-awesome')),
    menuItem('Scatter-plot & Histogram', tabName = 'scatter and histogram', icon=icon('chart-area', lib='font-awesome')),
    menuItem("Explore Table", tabName = "table", icon = icon('columns', lib="font-awesome")),
    menuItem("About", tabName = "about", icon = icon('book-open', lib="font-awesome"), selected = TRUE)
)

ui <- dashboardPage(skin='black',
    header,
    sidebar,
    body
)