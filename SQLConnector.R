#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DBI)
library(RSQLite)
library(dbplyr)
library(dplyr)
library(shinyjs)
# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("MySQL Connector"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("n",
                     "Number of rows you want to see:",
                     min = 1,
                     max = 200,
                     value = 30),
         textInput("dbname","Database Name:",value="shinydemo"),
         textInput("host","Host Name:",value="shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com"),
         textInput("username","Your username:",value="guest"),
         textInput("password","Your password:",value="guest"),
         actionButton("conButton", "Connect!"),
         actionButton("discButton", "Disconnect!")
      ),
      
      
      
      
      
       # Show a plot of the generated distribution
      mainPanel(
         p("Due to Qi-Policy you can view at most 200 lines... sorry:("),
         uiOutput("query"),
         tableOutput("table"),
         uiOutput("refresh")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output){
  conn <- reactive({
    dbConnect(
      drv = RMySQL::MySQL(),
      dbname = input$dbname,
      host = input$host,
      username = input$username,
      password = input$password)
  })
  
  output$query <- renderUI({
    if(input$conButton==0){
      return()
    }
    textAreaInput("query", "Write your query here(end with ;!):", "SELECT * FROM City GROUP BY Population;")
   })
  
  output$refresh <- renderUI({
    actionButton("refresh", "refresh")
  })
  
  observeEvent(input$refresh,{
    output$table <- renderTable({
    x <- dbSendQuery(conn(),input$query)  
     table <- dbFetch(x) %>% as.data.frame()
    dbClearResult(x)
    head(table
         ,input$n)
  })})

   observeEvent(input$discButton,{
     toggle("table")
   })
   
   
}

# Run the application 
shinyApp(ui = ui, server = server)

