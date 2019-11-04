library(dashboard)

shinyUI(
  dashboardPage(
    dashboardHeader(title = 'Raw Material Data Portal'),
    dashboardSidebar(collapsed = FALSE,
      
      sidebarMenu(id = 'tabs',
        menuItem('Coil data', tabName = 'data', icon = icon('coins')),
        menuItem('SPC', tabName = 'SPC', icon = icon('chart-bar'))
        
      ),
      # Using conditional panels to update the sidebar filters available depending on the tab selected. 
      conditionalPanel(
        
        condition = "input.tabs == 'data'",
        
        selectizeInput(inputId = 'coil_prop',
                       'Coil property',
                       choice_property),
        selectizeInput(inputId = 'supplier',
                       'Supplier',
                       choices = supplier_mill$Supplier,
                       selected = NULL,
                       multiple = TRUE),
        selectizeInput(inputId = 'mill',
                       'Mill',
                       choices = supplier_mill$Mill,
                       selected = NULL,
                       multiple = TRUE),
        selectizeInput(inputId = 'gauge',
                       'Gauge (in)',
                       choice_gauge,
                       selected = NULL,
                       multiple = TRUE),
        selectizeInput(inputId = 'temper',
                       'Temper',
                       choice_temper,
                       selected = NULL,
                       multiple = TRUE), 
        selectizeInput(inputId = 'spec',
                       'Spec #',
                       choice_spec,
                       select = NULL,
                       multiple = TRUE)
      ),
      conditionalPanel(

        condition = "input.tabs == 'SPC'",
          selectizeInput(inputId = 'coil_prop_SPC',
                            'Coil property',
                           selected = 'Temper',
                           choices = c('Gauge', 'Temper')),
          selectizeInput(inputId = 'mill_SPC',
                         'Mill',
                         choices = supplier_mill$Mill,
                         selected = c('Mill 1', 'Mill 2', 'Mill 3'),
                         multiple = TRUE),
        conditionalPanel(
          condition = "input.coil_prop_SPC == 'Gauge'",

                         selectizeInput(inputId = 'gauge_SPC',
                           'Gauge (in)',
                           choice_gauge,
                           selected = NULL,
                           multiple = F)
          ),
          conditionalPanel(
            condition = "input.coil_prop_SPC == 'Temper'",

            selectizeInput(inputId = 'temper_SPC',
                           'Temper',
                           choice_temper,
                           selected = 'T2',
                           multiple = F)
          )

       )
      
      # I want to add date filter in the future. 
      
      # dateRangeInput("dates", label = ("Date range")),
      # hr(),
      # fluidRow(column(4, verbatimTextOutput("value")))
      
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = 'SPC',
                
                  fluidRow(column(7, plotOutput('SPC_xbar')), 
                           column(5, plotOutput('SPC_pCapability'))),
                  ),
        
        tabItem(tabName = 'data', 
                fluidRow(
                    tabBox(
                      
                      tabPanel("Graphs & Stats", 
                                fluidRow(box(plotlyOutput("time_series"), width = 12)), 
                                fluidRow(box(DT::dataTableOutput('table'), width = 12))),
                      tabPanel('Data', 
                               fluidRow(box(DT::dataTableOutput('table2'), width = 12))), 
                      tabPanel("Insights", "To be replaced with Machine learning tools"),
                      width = 12)
                    
                        ) 
                
                )
      )
    )
  )
  
  
  
)

