# server.R

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
        # this does not work yet.
        # if (input$hslogx == TRUE){
        #     input$scx <- log(input$hsx)
        # }

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
