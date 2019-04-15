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

        # this commented section isn't working yet ...
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

    # vlabels <- reactive({
    #     a <- subset(dataset, -log(as.numeric(input$volcanoy)) > -log(as.numeric(input$volcano_label_pcutoff)))
    #     a$padj_CD_vs_Control = -log(a$padj_CD_vs_Control)
    #     a$padj_UC_vs_Control = -log(a$padj_UC_vs_Control)
    #     a$padj_vdjnorm = -log(a$padj_vdjnorm)
    #     return(a)
    # })


    # render volcano plot panel
    output$volcano_plot <- renderPlot({

        vdata <- dataset %>%
                    mutate(padj_CD_vs_Control = -log(padj_CD_vs_Control),
                        padj_UC_vs_Control = -log(padj_UC_vs_Control),
                        padj_vdjnorm = -log(padj_vdjnorm))

        volc <- ggplot(data=vdata) +
                aes_string(x=input$volcanox, y=input$volcanoy) +
                geom_jitter(alpha=0.5) +
                theme_classic()

        if (input$volcano_color != 'None'){
            volc <- volc + aes_string(color=input$volcano_color)
        }

        volc <- volc + geom_hline(yintercept = -log(input$volcano_label_pcutoff))

        # something is fishy here ...
        if(input$volcano_label != 'None'){
        volc <- volc +
                geom_label_repel(data=vdata[input$volcanoy > -log(input$volcano_label_pcutoff), ],
                                 aes_string(label=input$volcano_label))

        }
        print(volc)

    })


    output$gbrowser <- renderPlot({
        gsymbol <- as.character(test$GeneSymbol[1])

        ensembl_gene_track <- BiomartGeneRegionTrack(genome="hg19", name="ENSEMBL", symbol=input$gsymbol)
        print(plotTracks(list(axis_track, ensembl_gene_track)))

    })

    # render output datatable
    output$tbl <- DT::renderDataTable(dataset, filter = 'top', options=list(scrollX=TRUE))
}
