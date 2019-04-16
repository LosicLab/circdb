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
        withProgress(message = 'loading histogram', value=0, expr={

                hist <- ggplot(plot_data(), aes_string(x=input$hsx)) + geom_density() + theme_classic()

                incProgress(amount=0.25, detail='adding points...')

                if (input$hscolor != 'None'){
                    incProgress(amount = 0.5, detail='adding colors...')
                    hist <- hist + aes_string(fill=input$hscolor)
                }
                facets <- paste(input$hsfacet_row, '~', input$hsfacet_col)
                if (facets != '. ~ .'){
                    incProgress(amount=0.75, detail='adding facets...')
                    hist <- hist + facet_grid(facets)
                }
                incProgress(amount = 0.8, detail='rendering plot...')
                print(hist)
        }
        )
    })


    # render volcano plot panel
    output$volcano_plot <- renderPlot({

        vy <- vdata[, input$volcanoy] > -log(input$volcano_label_pcutoff)
        vlabels <- vdata[vy,]

        withProgress(message = 'plotting volcano', value = 0, expr =  {
            volc <- ggplot(data=vdata) +
                aes_string(x=input$volcanox, y=input$volcanoy) +
                geom_jitter(alpha=0.5) +
                theme_classic()

            if (input$volcano_color != 'None'){
                volc <- volc + aes_string(color=input$volcano_color)
            }


            volc <- volc +
                    geom_hline(yintercept = -log(input$volcano_label_pcutoff), linetype='dashed', size=0.2)

            incProgress(amount = 0.25, detail = 'adding points ...')
            # something is fishy here ...
            if(input$volcano_label != 'None'){
                volc <- volc +
                    geom_label_repel(data=vlabels,
                                     aes_string(label=input$volcano_label))
            incProgress(amount=0.5, detail = 'adding labels ...')
            }

            volc <- volc + labs(y=paste0('-log(', input$volcanoy, ')'))
            incProgress(amount = 0.75, detail = 'rendering plot ...')
            print(volc)
            })

    })

    output$gbrowse_title <- renderText({
        gene <- dataset[dataset$BackspliceLocation == input$gsymbol,]$GeneSymbol
        paste0('Gene symbol: ', as.character(gene),' - ', as.character(input$gsymbol))
        })

    output$gbrowser <- renderPlot({
        withProgress(message = 'Loading gene browser', value=0, expr={
                        gene <- gbrowsedf[gbrowsedf$BackspliceLocation == input$gsymbol,]$GeneSymbol[1]
                        chr <- gbrowsedf[gbrowsedf$BackspliceLocation == input$gsymbol,]$chr[1]
                        junction <- browser_gr[browser_gr$BackspliceLocation == input$gsymbol]


                        # get the exons with the gene coordinates
                        # to plot the backsplice
                        gquery <- genes(genome)[which(genes(genome)$gene_id == junction$entrez_id),]
                        gquery <- subsetByOverlaps(exons(genome), gquery)
                        exons <- gquery[c(junction$BackspliceExon1,junction$BackspliceExon2),]
                        exons$exon_id <- NULL
                        exons$value <- '5'

                        # make the tracks
                        idx_track <- IdeogramTrack(genome = 'hg19', chromosome = chr)

                        bmt <- BiomartGeneRegionTrack(genome = 'hg19', symbol=as.character(gene), stacking='dense',name='Consensus', fill='darkgray', col='darkgray', col.line='black')
                        splice_track <- AnnotationTrack(range = exons, name = "backsplice", genome = 'hg19', min.width=3, collapse=TRUE, fill='blue', col='blue', shape=c('box'))
                        ensembl_gene_track <- BiomartGeneRegionTrack(genome="hg19", name="ENSEMBL Isoforms", symbol=as.character(gene), fill='darkblue', col='darkblue', transcriptAnnotation='transcript')

                        #print(exons)

                        incProgress(0.5, detail='...')

                        print(plotTracks(list(idx_track, axis_track, bmt, splice_track, ensembl_gene_track), sizes = c(0.75,0.75,0.5,0.5,5), add53=TRUE, add35=TRUE, littleTicks=TRUE,  background.title="black"))
                        }
        )
    })

    # render output datatable
    output$tbl <- DT::renderDataTable(dataset, filter = 'top', options=list(scrollX=TRUE))
}
