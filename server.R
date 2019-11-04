shinyServer <- function(input, output, session){
  
  # Reactive function for all the filtering on "Coil Data" tab
  data <- reactive({
    
    if (is.null(input$supplier)) {
      supplier_filter <- quote(!(supplier %in% "@?><"))
    } else { 
      supplier_filter <- quote(supplier %in% input$supplier)
    }
    
    if (is.null(input$mill)) {
      mill_filter <- quote(!(Mill %in% "@?><"))
    } else {
      mill_filter <- quote(Mill %in% input$mill)
    }
    
    if (is.null(input$gauge)) {
      gauge_filter <- quote(!(gauge %in% "@?><"))
    } else{
      gauge_filter <- quote(gauge %in% input$gauge)
    }
    
    if (is.null(input$temper)){
      temper_filter <- quote(!(temper %in% "@?><"))
    } else {
      temper_filter <- quote(temper %in% input$temper)
    }
    
    if (is.null(input$spec)){
      spec_filter <- quote(!(spec %in% "@?><"))
    } else {
      spec_filter <- quote(spec %in% input$spec)
    }
      
    supplier_data %>%
       filter_(supplier_filter) %>% # I should be using filter instead of filter_, haven't been able to figure out how yet
       filter_(mill_filter) %>%
       filter_(gauge_filter) %>%
       filter_(temper_filter) %>%
      filter_(spec_filter)
    
    
  })
  
  # Using Plotly for R instead of shiny's renderPlot function for added interactivity 
  output$time_series <- renderPlotly({
    
    p1 <- ggplotly(data() %>%
                     ggplot(aes_string(x = "prod_date", y = input$coil_prop)) +
                     geom_point(aes(color=Mill), alpha = 0.7, size = 0.6) +
                     theme_bw() +
                     theme(axis.text.x = element_blank(),
                           axis.ticks.x = element_blank(),
                           axis.title = element_text(),
                           legend.position = 'none')) 
                     
    
    p2 <- ggplotly(data() %>%
                     ggplot(aes_string(x = input$coil_prop, color = "Mill", fill = "Mill")) +
                     geom_histogram(alpha = 0.1) + 
                     facet_wrap(~Mill, nrow = 3, scales = 'free_y') +
                     geom_density(alpha = 0.3) +
                     theme_bw() +
                     theme(axis.title.x = element_blank(),
                           axis.text.y = element_blank(),
                           axis.ticks.y = element_blank(),
                           panel.background = element_blank(),
                           panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(),
                           panel.border = element_blank(),
                           legend.position = 'none',
                           strip.background = element_blank()
                     )
    )
    
    p3 <-  ggplotly(data() %>%
                      ggplot(aes_string(x = "Mill", y=input$coil_prop,color="Mill")) +
                      geom_boxplot(show.legend = T) +
                      coord_flip() + 
                      theme_bw() +
                      theme(axis.text.x = element_blank(),
                            axis.text.y = element_blank(),
                            axis.ticks = element_blank(),
                            panel.background = element_blank(),
                            panel.grid.major = element_blank(),
                            panel.grid.minor = element_blank(),
                            panel.border = element_blank(),
                            legend.position = 'none')
    )
    
    p4 <- ggplotly(data() %>%
                     group_by(Mill,month = format(prod_date, "%Y-%m")) %>%
                     summarise(Volume_tons = sum(weight/2000)) %>%
                     ggplot(aes(x = month, y = Volume_tons, fill = Mill)) +
                     geom_bar(stat = 'identity', position = 'dodge') +
                     theme_bw() +
                     theme(axis.title.x = element_blank(),
                           panel.background = element_blank(),
                           panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(),
                           legend.position = 'none') + 
                     ylab('Volume (tons)')
                   )
    # Using subplot function instead of arrange.grid because I'm using Plotly objects
    subplot(p1, p2, p4, p3, titleY = T, nrows = 2, heights = c(0.8, 0.2), widths = c(0.7,0.3), margin = 0.03) 
    
  })  
 
  output$table <- DT::renderDataTable({
    
    datatable(data(), rownames = F, options = list(pageLength = 5, scrollX = T)) %>%
      formatStyle(input$selected,
                  background = 'skyblue',
                  fontWeight = 'bold')
    
  })
  
  
  # Duplicating this table ouput. Tried using the same output for two tabs, but it slowed down the app loading. 
  #Nneed to understand why using the same output on two tabs slows down the loading of the UI
  
  output$table2 <- DT::renderDataTable({
    
                        datatable(data(), rownames = F, options = list(pageLength = 5, scrollX = T)) %>%
                               formatStyle(input$selected,
                                           background = 'skyblue',
                                           fontWeight = 'bold')
    
  })
  
  
  output$SPC_xbar <- renderPlot({
  if (input$coil_prop_SPC == 'Gauge'){
    supplier_data$gauge[supplier_data$ordered_gauge == input$gauge_SPC] %>%
      qcc('xbar.one')
  } else {
    supplier_data$rockwell[supplier_data$temper == input$temper_SPC] %>%
      qcc('xbar.one')
  }
   
  })
  
  # SPC (Statistical Process Control) tab charts. More charts and analysis to be added in the future. 
  
  output$SPC_pCapability <- renderPlot({
    
    spec_limits <- data.frame(temper = c('T1','T1','T2','T2','T3','T3','T4','T4', 'T5','T5', 'DR7.5','DR7.5', 'DR8','DR8', 'DR8.5','DR8.5', 'DR9','DR9'), 
                              limits = c(45, 53, 49, 57, 53, 61, 57, 65, 61, 69, 67, 75, 68, 76, 69, 77, 71, 79))
    lims <- spec_limits$limits[spec_limits$temper == input$temper_SPC]
    
    if (input$coil_prop_SPC == 'Gauge'){
      supplier_data$gauge[supplier_data$ordered_gauge == input$gauge_SPC & supplier_data$Mill %in% input$mill_SPC] %>%
        qcc('xbar.one') %>% # Idealy this will be xbar and not xbar.one, but need to figure out grouping first. 
        process.capability(., lims) # need real gauge limits
    } else {
      supplier_data$rockwell[supplier_data$temper == input$temper_SPC & supplier_data$Mill %in% input$mill_SPC] %>%
        qcc('xbar.one') %>%
        process.capability(., lims)
    }
    
  })

}




















