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
      
        withProgress(message='loading scatter',
                     
                     value=0,
                     expr={

        # this commented section isn't working yet ...
        # if (input$sclogx){
        #   input$scx <- log(input$scx)
        # }
        # if (input$sclogy){
        #   input$scy <- log(input$scy)
        # }

        scatter <- ggplot(plot_data(), aes_string(x=input$scx, y=input$scy)) + geom_point() + theme_classic()
        incProgress(amount = 0.25, detail = '...')
        
        if (input$sccolor != 'None'){
          incProgress(amount = 0.5, detail='...')
            scatter <- scatter + aes_string(color=input$sccolor)
        }
        facets <- paste(input$scfacet_row, '~', input$scfacet_col)
        
        if (facets != '. ~ .'){
          incProgress(amount = 0.75, detail='...')
            scatter <- scatter + facet_grid(facets)
        }
        incProgress(amount = 0.9, detail='...')
        
        print(scatter)
        }
        
        )
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
        gene <- dataset[dataset$circID == input$gsymbol,]$geneID[1]
        paste0('Gene symbol: ', as.character(gene),' - ', as.character(input$gsymbol))
        })

    output$gbrowser <- renderPlot({
        withProgress(message = 'Loading gene browser', value=0, expr={
                        gene <- gbrowsedf[gbrowsedf$circID == input$gsymbol,]$geneID[1]
                        chr <- gbrowsedf[gbrowsedf$circID == input$gsymbol,]$chr[1]
                        junction <- browser_gr[browser_gr$circID == input$gsymbol]


                        # get the exons with the gene coordinates
                        # to plot the backsplice
                        gquery <- genes(TxDb.Hsapiens.UCSC.hg19.knownGene)[which(genes(TxDb.Hsapiens.UCSC.hg19.knownGene)$gene_id == junction$entrez_id),]
                        gquery <- subsetByOverlaps(exons(TxDb.Hsapiens.UCSC.hg19.knownGene), gquery)
                        exons <- gquery[c(junction$Exon1,junction$Exon2),]
                        exons$exon_id <- NULL
                        exons$value <- '5'

                        # make the tracks
                        idx_track <- IdeogramTrack(genome = 'hg19', chromosome = chr)

                        bmt <- BiomartGeneRegionTrack(genome = 'hg19', symbol=as.character(gene), stacking='dense',name='Consensus',
                                                      fill='darkgray', col='darkgray', col.line='black')
                        splice_track <- AnnotationTrack(range = exons, name = "backsplice", genome = 'hg19',
                                                        min.width=3, collapse=TRUE, fill='blue', col='blue', shape=c('box'))
                        ensembl_gene_track <- BiomartGeneRegionTrack(genome="hg19", name="ENSEMBL Isoforms",
                                                                     symbol=as.character(gene), fill='darkblue', col='darkblue', transcriptAnnotation='transcript')

                        
                        incProgress(0.5, detail='...')

                        print(plotTracks(list(idx_track, axis_track, bmt, splice_track, ensembl_gene_track), sizes = c(0.75,0.75,0.5,0.5,5), add53=TRUE, add35=TRUE, littleTicks=TRUE,  background.title="black"))
                        }
        )
    })
    
    output$circQTL_title <- renderText({
      gene <- snps[snps$trait_id == input$circqtlid,]$gene_symbol[1]
      paste0('Gene symbol: ', as.character(gene),' - ', as.character(input$gsymbol))
    })


    output$circqtlos <- renderPlot({

      # Prep the data
      snps_filtered <- read_tsv('data/common_cRNA_mRNA_SNPS_by_gene.txt') %>%
          as_tibble() %>%
          dplyr::filter(trait_id == input$circqtlid) %>%
          mutate(chr=paste0('chr', chr),
                 pos=as.numeric(pos),
                 pos2=as.numeric(pos))
      
      snps_filtered <- as.data.frame(snps_filtered)
      snps_filtered <- snps_filtered[, c(1,5,19, 2:4, 6:18)]
      
      
      gene <- gbrowsedf[gbrowsedf$circID == input$circqtlid,]$geneID[1]
      chr <- gbrowsedf[gbrowsedf$circID == input$circqtlid,]$chr[1]
      junction <- browser_gr[browser_gr$circID == input$circqtlid]
      
      # get the exons with the gene coordinates
      # to plot the backsplice
      gquery <- genes(TxDb.Hsapiens.UCSC.hg19.knownGene)[which(genes(TxDb.Hsapiens.UCSC.hg19.knownGene)$gene_id == junction$entrez_id),]
      tx <- subsetByOverlaps(transcripts(TxDb.Hsapiens.UCSC.hg19.knownGene), gquery)
      tx <- as.data.frame(tx)
      exons <- subsetByOverlaps(exons(TxDb.Hsapiens.UCSC.hg19.knownGene), gquery)
      
      exons <- as.data.frame(exons)
      exons$gene <- as.character(gene)
      exons$exon_id <- as.factor(exons$exon_id)
      levels(exons$exon_id) <- as.character(1:length(levels(exons$exon_id)))
      
      
      
      exons <- exons[, c('gene', 'start', 'end', 'seqnames', 'width', 'strand', 'exon_id')]
      
      bs_exons <- exons[c(junction$Exon1,junction$Exon2),]
      crna_exons <-  exons[c(junction$Exon1:junction$Exon2),]
      bs_exon1 <- bs_exons[1, c(1:3, 5)]
      bs_exon2 <- bs_exons[2, c(1:3, 5)]
      
      # # plot the circos
      print({
      circos.par(track.height = 0.1, gap.degree=180)
      circos.genomicInitialize(exons)
      circos.genomicTrack(snps_filtered, ylim=c(min(snps_filtered$beta) - 0.5, max(snps_filtered$beta) +0.5), panel.fun = function(region, beta, ...) {
          circos.genomicPoints(region, beta, col = 'blue', pch = 16, cex = 0.5, ...)
      })
      
      circos.genomicTrack(exons, ylim = c(-2.5, 2.5),
                          panel.fun = function(region, value, ...) {
                              # for each transcript
                              current_tx_start = min(region[, 1])
                              current_tx_end = max(region[, 2])
                              circos.lines(c(current_tx_start, current_tx_end),
                                           c(0, 0), col = "#CCCCCC")
                              circos.genomicRect(region, ytop = 1,
                                                 ybottom = -1, col = "orange", border = NA)
                              
                          }, bg.border = NA)
      
      
      circos.genomicTrack(crna_exons, ylim = c(-2.5, 2.5),
                          panel.fun = function(region, value, ...) {
                              # for each transcript
                              current_tx_start = min(region[, 1])
                              current_tx_end = max(region[, 2])
                              circos.lines(c(current_tx_start, current_tx_end),
                                           c(0, 0), col = "#CCCCCC")
                              circos.genomicRect(region, ytop = 1,
                                                 ybottom = -1, col = "red", border = NA)
                              
                          }, bg.border = NA)
      
      circos.genomicLink(bs_exon1, bs_exon2, col = 'red', border = NA, h=0.1, h2=0.1)
      
      circos.clear()
      })

    })
    
    # render output datatable
    output$tbl <- DT::renderDataTable({
      columnLabels <- col_details$detail
      
      datatable(
        dataset,
        filter='top',
        options = list(scrollX=TRUE, scrollY='500px'),
        container = sketch,
        rownames= FALSE
      )
      })
    
    output$about_text <- renderText({expr = 'About this page.'})
}
