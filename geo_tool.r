require(RDSTK)
require(plyr)
server <- function(input, output) {
  
  getData <- reactive({
    
    inFile <- input$file1
    
    if (is.null(input$file1))
      return(NULL)
    
    read.csv(inFile$datapath, header=input$header, sep=input$sep, 
             quote=input$quote)
    
    
  })
  
  
  output$contents <- renderTable({
    
    
    input$goButton
    x <- isolate(
      
      lapply(as.character(getData()$address), street2coordinates) %>% ldply
      )
    
    cbind(getData(),x[,c('latitude','longitude')])
    
  }
    
    
    
  )
  
  output$downloadData <- downloadHandler(
    
    filename = function() { 
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    
    content = function(file) {
      
      write.csv(cbind(getData(),y[,c('latitude','longitude')]), file)
      
    })
  
}
ui <- fluidPage(
  fluidPage(
    titlePanel("Uploading Files"),
    sidebarLayout(
      sidebarPanel(
        fileInput('file1', 'Choose CSV File',
                  accept=c('text/csv', 
                           'text/comma-separated-values,text/plain', 
                           '.csv')),
        tags$hr(),
        checkboxInput('header', 'Header', TRUE),
        radioButtons('sep', 'Separator',
                     c(Comma=',',
                       Semicolon=';',
                       Tab='\t'),
                     ','),
        radioButtons('quote', 'Quote',
                     c(None='',
                       'Double Quote'='"',
                       'Single Quote'="'"),
                     '"'),  
        actionButton("goButton", "Go!"),
        downloadButton('downloadData', 'Download')
      ),
      mainPanel(
        tableOutput('contents')
      )
    )
  )
)

shinyApp(ui = ui, server = server)