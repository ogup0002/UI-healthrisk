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
        
      sliderInput("sitting", "Dynamic",
                  min = 0, max = range1, value = 0)

    })
    
    output$slider2 <- renderUI({
      if (input$working_hour == "4-6"){
        range2 = 6
      } else if (input$working_hour == "7-9"){
        range2 = 9
      } else if (input$working_hour == "10-12"){
        range2 = 12
      } else {
        range2 = 14
      }
      range3 = range2 - input$sitting
      
      sliderInput("physical", "Dynamic1",
                  min = 0, max = range3, value = 0)
      
    })
    
    output$viz <- renderGauge({
      if (input$working_hour == "4-6"){
        range4 = 6
      } else if (input$working_hour == "7-9"){
        range4 = 9
      } else if (input$working_hour == "10-12"){
        range4 = 12
      } else {
        range4 = 14
      }
      if (range4 < 6 && input$sitting < 4 && input$physical >= 2 && input$breaks < 60){
        out = 0
      } else if (range4 < 9 && input$sitting < 6 && input$physical >= 2 && input$breaks <= 60){
        out = 0
      } else if (range4 < 9 && input$sitting > 6 && input$physical >= 2 && input$breaks <= 60){
        out = 1
      } else if (range4 < 6 && input$sitting == 6 && input$physical < 2 && input$breaks <= 45){
        out = 1
      } else if (range4 > 9 && input$sitting > 8 && input$physical > 4 && input$breaks <= 60){
        out = 2
      } else if (range4 > 9 && input$sitting > 8 && input$physical < 4 && input$breaks > 45){
        out = 2
      }
        
      gauge(input$out, 
            min = 0, 
            max = 2, 
            sectors = gaugeSectors(success = c(0, 0.9), 
                                   warning = c(1,1.9),
                                   danger = c(2,3)))
     
    })

})




