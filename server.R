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
        # this part does not work yet.
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

    # set the inputs up for the volcano plot
    vdata <- reactive(dataset)
    vlabels <- reactive({
                        dataset %>%
                            filter(input$volcanoy < input$volcano_label_pcutoff) %>%
                            filter(input$volcanox > input$volcano_label_exprcutoff)
        })

    # render volcano plot panel
    output$volcano_plot <- renderPlot({

        volc <- ggplot(data=vdata()) +
                aes_string(x=input$volcanox, y=input$volcanoy) +
                geom_jitter(alpha=0.5) +
                theme_classic()

        if (input$volcano_color != 'None'){
            hist <- hist + aes_string(color=input$volcano_color)
        }

        volc <- volc +
                geom_label_repel(data=vlabels(),
                                 aes_string(x=input$volcanox, y=input$volcanoy, label=input$volcano_label))


    })

    # render output datatable
    output$tbl <- renderDataTable(dataset, filter = 'top', options=list(scrollX=TRUE))
}
