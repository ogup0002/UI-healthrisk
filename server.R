#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(flexdashboard)
library(RMySQL)





  
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
    output$slider1 <- renderUI({
      if (input$working_hour == "4-6"){
        range1 = 6
      } else if (input$working_hour == "7-9"){
        range1 = 9
      } else if (input$working_hour == "10-12"){
        range1 = 12
      } else {
        range1 = 14
      }
        
      sliderInput("sitting", "Hours spent sitting on average",
                  min = 0, max = range1, value = 0)

    })
    
    output$slider2 <- renderUI({
      range3=0
      if (input$working_hour == "4-6"){
        range2 = 6
      } else if (input$working_hour == "7-9"){
        range2 = 9
      } else if (input$working_hour == "10-12"){
        range2 = 12
      } else {
        range2 = 14
      }
      
      if (!is.null(input$sitting)){
      range3 = range2 - input$sitting
      }      
      sliderInput("physical", "Hours spent in Physical Activity like Stretching",
                  min = 0, max = range3, value = 0)
      
      
    })
    
    outs <- reactiveValues(out = 0.5)
    observeEvent(input$go,{
      
      if (input$sitting < 4 && input$physical >= 1 && input$breaks < 60){
        outs$out <- 0.5
      } else if (input$sitting == 0  && input$physical >= 0 && input$breaks < 120){
        outs$out <- 0.5
      } else if (input$sitting < 6 && input$physical >= 2 && input$breaks <= 60){
        outs$out <- 0.5
      } else if (input$sitting < 6 && input$physical < 2 && input$breaks <= 60){
        outs$out <- 1
      } else if (input$sitting < 8  && input$physical >= 2 && input$breaks <= 60){
        outs$out <- 1
      } else if (input$sitting == 6 && input$physical < 2 && input$breaks <= 45){
        outs$out <- 1
      } else if (input$sitting >= 8 && input$physical <= 4 && input$breaks <= 60){
        outs$out <- 2
      } else if(input$sitting >= 8 && input$sitting < 11 && input$physical <= 4 && input$breaks > 45){
        outs$out <- 2
      } else if(input$sitting >= 10 && input$physical >= 4 && input$breaks <= 60){
        outs$out <- 1
      } else if(input$sitting >= 10 && input$physical <= 4 && input$breaks > 60){
        outs$out <- 2
      }
      
      
      output$viz <- renderGauge({
        
        gauge(outs$out, 
              min = 0, 
              max = 2, 
              sectors = gaugeSectors(success = c(0, 0.9), 
                                     warning = c(1,1.9),
                                     danger = c(2,3)),
              label = 'Risk Factor'
              )
        
      })
      

    })
    
    observeEvent(input$send,{
      mysqlconnection = dbConnect(RMySQL::MySQL(),
                                  dbname='sittofit',
                                  host='sit-to-fit.clnlbyaislb7.ap-southeast-2.rds.amazonaws.com',
                                  port=3306,
                                  user='admin',
                                  password='j54xAHG3Rw1uy2zJZ7qT')
      
      
      # workinghours, sittinghours, physicalhours, breaks, risknumber
      query <- paste("insert into risks () values (",2,",",input$sitting,",", input$physical,",", input$breaks,",", 2, ");")
      res <- dbSendQuery(mysqlconnection, query)
      print('SENDING')
    })
    output$plot <- renderPlot({
      fetch <- dbGetQuery(mysqlconnection, "SELECT * FROM risks")
      ggplot2(fetch, aes)
    })
    
    

})




