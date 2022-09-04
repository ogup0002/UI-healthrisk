#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(lessR)
library(shiny)
library(shinydashboard)
library(flexdashboard)
library(RMySQL)
library(shinyjs)
library(plyr)
library(shinyWidgets)



  
# Server Logic
shinyServer(function(input, output) {

  
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname='sittofit',
                              host='db.sittofit.tk',
                              port=3306,
                              user='sittofit',
                              password='0AxPzbedoJFNTfPj67Pr')
  
  
  fetch <<- dbGetQuery(mysqlconnection, "SELECT * FROM risks")
  datacount <<- nrow(fetch)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
# USER INPUT - SLIDERS  
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
        range2 <<- 6
      } else if (input$working_hour == "7-9"){
        range2 <<- 9
      } else if (input$working_hour == "10-12"){
        range2 <<- 12
      } else {
        range2 <<- 14
      }
      
      if (!is.null(input$sitting)){
      range3 = range2 - input$sitting
      }      
      sliderInput("physical", "Hours spent in Physical Activity like Stretching",
                  min = 0, max = range3, value = 0)
      
      
    })
    
    
# Logic    
    outs <- reactiveValues(out = 0.5)
    observeEvent(input$go,{
      
      ##LOGIC HERE
      s = (input$sitting+1)
      print(s)
      p= input$physical+1
      print(p)
      b = as.numeric(input$breaks)/30
      print(b)
      w = range2/2
      print(w)
      R = (s/p+b)/w
      print(R)
      
      
      output$viz <- renderGauge({
        
        gauge(R, 
              min = 0, 
              max = 6, 
              sectors = gaugeSectors(success = c(0, 1), 
                                     warning = c(2,4),
                                     danger = c(5,6)),
              label = 'Risk Factor'
              )
        
      })
      

    })
# Send User Statistics
    observeEvent(input$send,{
      #mysqlconnection = dbConnect(RMySQL::MySQL(),
      #                            dbname='sittofit',
      #                            host='db.sittofit.tk',
      #                            port=3306,
      #                            user='sittofit',
      #                            password='0AxPzbedoJFNTfPj67Pr')
      
      # workinghours, sittinghours, physicalhours, breaks, risknumber
      query <- paste("insert into risks () values (",2,",",input$sitting,",", input$physical,",", input$breaks,",", 2, ");")
      res <- dbSendQuery(mysqlconnection, query)
      #on.exit(dbDisconnect(mysqlconnection)) NOT WORKING
      print('SENDING')
    })
    
# Popup Plot
    output$plot <- renderPlot({
      mysqlconnection = dbConnect(RMySQL::MySQL(),
                                  dbname='sittofit',
                                  host='db.sittofit.tk',
                                  port=3306,
                                  user='sittofit',
                                  password='0AxPzbedoJFNTfPj67Pr')
      
      
      #fetch <- dbGetQuery(mysqlconnection, "SELECT * FROM risks")
      datacount <- nrow(fetch)
      print(fetch)
      if (input$viz_type == 'Sitting Hours on a working day'){
            co <- count(fetch, 'sittinghours')
            disp <- input$sitting
            avg = mean(fetch$sittinghours)
            #lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect) #closes all connections
        PieChart(sittinghours, data = co, main = NULL, hole = 0.1, fill = 'viridis')
      } else if (input$viz_type == 'Physical Activity Hours while working'){
        co <- count(fetch, 'physicalhours')
        disp <- input$physical
        avg = mean(fetch$physicalhours)
        #lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect) #closes all connections
        PieChart(physicalhours, data = co, main = NULL, hole = 0.1, fill = 'viridis')
      } else if (input$viz_type == 'Break interval during Sitting'){
        co <- count(fetch, 'breaks')
        disp <- input$breaks
        avg = mean(fetch$breaks)
        #lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect) #closes all connections
        PieChart(breaks, data = co, main = NULL, hole = 0.1, fill = 'viridis')
      }
    })
# Popup Text output    
    
    observeEvent(input$viz_type,{
      delay(3000)
      print(datacount)
      if (input$viz_type == 'Sitting Hours on a working day'){
        disp <- input$sitting
        disp2 <- 'sitting hours is'} else if (input$viz_type == 'Physical Activity Hours while working'){
          disp <- input$physical
          disp2 <- 'physical activity hours while working is'
        } else if (input$viz_type == 'Break interval during Sitting'){
          disp <- input$breaks
          disp2 <- 'breaks in between sitting hours is'
          }
      output$textinfo <- renderText({paste("Your", disp2, disp)})
      output$textstatic <- renderText({paste("Compare it with other Melbournians!")})
      #output$textstatic3 <- renderText({paste("The Average of Melbournians for", disp2, input$avg)})
      #output$textstatic2 <- renderText({paste("Live Count of User data: ", input$datacount)})
      output$textstatic3 <- renderValueBox({
        valueBox("Over Daily Value", HTML(paste0("The Average of Melbournians for", disp2, input$avg, sep="<br>")), icon = icon("exclamation-triangle"), color = "red")
      })
      output$textstatic2 <- renderValueBox(
        #valueBox(value = "disp2", subtitle = "The Average of Melbournians for", icon = icon("exclamation-triangle"), color = "red", width = 4, href = NULL)
        valueBox(
          value = input$avg,
          subtitle = paste("is the Average", disp2,"of Melbournians."),
          icon = icon("code"),
          width = 2,
          color = "red",
          href = NULL)
      )
      
      
      })
    
    

})




