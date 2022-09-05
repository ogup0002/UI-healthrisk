#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(flexdashboard)
library(RMySQL)
library(shinyjs)
library(plyr)
library(shinyWidgets)
library(ggplot2)
library(dplyr)





  
# Server Logic
shinyServer(function(input, output) {

  
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname='sittofit',
                              host='db.sittofit.tk',
                              port=3306,
                              user='sittofit',
                              password='0AxPzbedoJFNTfPj67Pr')
  
  data = dbGetQuery(mysqlconnection, "select * from logic")
  fetch = dbGetQuery(mysqlconnection, "SELECT * FROM risks")
  datacount = nrow(fetch)
  sh_co = count(fetch, sittinghours)
  ph_co = count(fetch, physicalhours)
  b_co = count(fetch, breaks)
  
  avg_s = round(mean(fetch$sittinghours),2)
  avg_p = round(mean(fetch$physicalhours),2)
  avg_b = round(mean(fetch$breaks),2)
  lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  

  calc_risk <- function(sit_hrs, phy_hrs, breaks){
    #data <- read.csv("C:\\user\\ounam\\Downloads\\risk_calculator_data.csv", header = TRUE)
    if (breaks == 15){
      result <- data[data$sit == sit_hrs & data$phy == as.integer(phy_hrs), ]$val - 0.6
    }else if (breaks == 30){
      result <- data[data$sit == sit_hrs & data$phy == as.integer(phy_hrs), ]$val - 0.5
    }
    else if (breaks == 60){
      result <- data[data$sit == sit_hrs & data$phy == as.integer(phy_hrs), ]$val - 0.3
    }
    else{
      result <- data[data$sit == sit_hrs & data$phy == as.integer(phy_hrs), ]$val - 0.1
    }
    return(result)
  }
  
  adjust_breaks <- function(breaks, val){
    if (breaks == 15){
      return(val-0.6)
    }
    else if (breaks == 30){
      return(val-0.5)
    }
    else if (breaks == 60){
      return(val-0.3)
    }
    else{
      return(val-0.1)
    }
  }
  
  
  
  
  
  
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
      #s = (input$sitting+1)
      #p= input$physical+1
      #b = as.numeric(input$breaks)/30
      #w = range2/2
      #R = ((s+b)/p)
      
      
      
      R = calc_risk(input$sitting, input$physical, input$breaks)
      
      output$viz <- renderGauge({
        
        gauge(R, 
              min = 0, 
              max = 10, 
              sectors = gaugeSectors(success = c(0, 3), 
                                     warning = c(3,7),
                                     danger = c(7,10)),
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
      mysqlconnection = dbConnect(RMySQL::MySQL(),
                                  dbname='sittofit',
                                  host='db.sittofit.tk',
                                  port=3306,
                                  user='sittofit',
                                  password='0AxPzbedoJFNTfPj67Pr')
      
      # workinghours, sittinghours, physicalhours, breaks, risknumber
      query <- paste("insert into risks () values (",2,",",input$sitting,",", input$physical,",", input$breaks,",", 2, ");")
      res <- dbSendQuery(mysqlconnection, query)
      #on.exit(dbDisconnect(mysqlconnection)) NOT WORKING
      print('SENDING')
    })
    
# Popup Plot
    output$plot <- renderPlot({
      if (input$viz_type == 'Sitting Hours on a working day'){
        ggplot(data=sh_co, aes(x=sittinghours, y=n)) +
          geom_bar(stat="identity", fill="lightblue") + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                            panel.background = element_blank(), axis.line = element_line(colour = "black"))
        
        
       
        
        
      } else if (input$viz_type == 'Physical Activity Hours while working'){
        
        ggplot(data=ph_co, aes(x=physicalhours, y=n)) +
          geom_bar(stat="identity", fill="lightblue") + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                            panel.background = element_blank(), axis.line = element_line(colour = "black"))
        
      } else if (input$viz_type == 'Break interval during Sitting'){
        
        ggplot(data=b_co, aes(x=breaks, y=n)) +
          geom_bar(stat="identity", fill="lightblue") + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                            panel.background = element_blank(), axis.line = element_line(colour = "black"))
      }
    })
# Popup Text output    
    
    observeEvent(input$viz_type,{
      delay(3000)
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
      output$textstatic1 <- renderText({paste("Live Count of User data: ", datacount)})
      output$textstatic3 <- renderValueBox({
        valueBox("Over Daily Value", HTML(paste0("The Average of Melbournians for", disp2, input$avg, sep="<br>")), icon = icon("exclamation-triangle"), color = "red")
      })
      output$textstatic2 <- renderValueBox(
        if (input$viz_type == 'Sitting Hours on a working day'){
          disp2 <- 'sitting hours is'
        valueBox(
          value = avg_s,
          subtitle = paste("is the Average", disp2,"of Melbournians."),
          icon = icon("circle-info"),
          width = 2,
          color = "red",
          href = NULL)
        }
        else if (input$viz_type == 'Physical Activity Hours while working'){
          disp2 <- 'physical activity hours while working is'
          valueBox(
            value = avg_p,
            subtitle = paste("is the Average", disp2,"of Melbournians."),
            icon = icon("exclamation-triangle"),
            width = 2,
            color = "red",
            href = NULL)
        }
        else if (input$viz_type == 'Break interval during Sitting'){
          disp2 <- 'breaks in between sitting hours is'
          valueBox(
            value = avg_b,
            subtitle = paste("is the Average", disp2,"of Melbournians."),
            icon = icon("exclamation-triangle"),
            width = 2,
            color = "red",
            href = NULL)
        }
      )
      
      
      })
    
    #observeEvent(input$send, {
      # Show a modal when the button is pressed
    #  shinyalert("Success!", "Your statistics have been sent!.", type = "success")
    #})
    
    observeEvent(input$go,
    output$ibox <- renderInfoBox({
      R = calc_risk(input$sitting, input$physical, input$breaks)
      if (R < 4){
        infoBox(
          "You are at Low Risk Sedentary Behaviour",
          "Read below about Recommended lifestyle changes!",
          icon = icon("person"),
          color = 'green'
        )} 
      else if (R > 4 && R < 8){
        infoBox(
          "You are at Medium Risk Sedentary Behaviour",
          "Read below about Recommended lifestyle changes!",
          icon = icon("exclamation"),
          color = 'orange'
        )}
      else {
        infoBox(
          "You are at High Risk Sedentary Behaviour",
          "Read below about Recommended lifestyle changes!",
          icon = icon("exclamation-triangle"),
          color = 'red'
        )}
    })
)
# Preventive Measures    
    observeEvent(input$go,{
                 R = calc_risk(input$sitting, input$physical, input$breaks)
                 output$ibox_sitting <- renderInfoBox({
                   
                   if (R < 4){
                     infoBox(
                       "Reduce a bit of your sitting hours.",
                       "Opt for Standing Desk and reduce your sitting hours.",
                       icon = icon("person"),
                       color = 'lime',
                       width = 12
                     )
                   }
                   else if (R > 4 && R < 8){
                     infoBox(
                       "Consider sitting less throughout your day.",
                       "Your sitting hours are high, reduce by opting for Standing desk. It will cause lower back issues in long-term from such inactivity.",
                       icon = icon("person"),
                       color = 'yellow'
                     )}
                   else {
                     infoBox(
                       "You are spending too much time sitting on desk.",
                       "Sitting for such long hours can lead to health issues in a short span of time. Opt for Standing Desk and move around frequently.",
                       icon = icon("person"),
                       color = 'orange'
                     )}
                 })
                 output$ibox_breaks <- renderInfoBox({
                   
                   if (R < 4){
                     infoBox(
                       "You are taking good short breaks!",
                       "Breaks allow for our back to stretch, keep you off from strain.",
                       icon = icon("hourglass-end"),
                       color = 'lime'
                     )
                   }
                   else if (R > 4 && R < 8){
                     infoBox(
                       "You are taking good breaks, just take in shorter intervals.",
                       "Breaks are good for physical health, mind and also protects your eyes.",
                       icon = icon("hourglass-start"),
                       color = 'yellow'
                     )}
                   else {
                     infoBox(
                       "You are not taking enough breaks in between your working hours!!",
                       "Take shorter break interval to relieve yourself from stress as it leads to other health concerns.",
                       icon = icon("hourglass"),
                       color = 'orange'
                     )}
                 })
                 
                 output$ibox_physical <- renderInfoBox({
                   
                   if (R < 4){
                     infoBox(
                       "You are doing good, but you can do a little better.",
                       "Be active and keep moving around while working.",
                       icon = icon("person-walking"),
                       color = 'yellow'
                     )
                   }
                   else if (R > 4 && R < 8){
                     infoBox(
                       "You are not engaging in physical activity enough!",
                       "Walk, stretch while you work. Physical Inactivity leads to weight gain and other health concerns.",
                       icon = icon("person-walking"),
                       color = 'orange'
                     )}
                   else {
                     infoBox(
                       "You are at High Risk Sedentary Behaviour",
                       "Consider home workout while you work. Physical Inactivity leads to Obesity and other health concerns.",
                       icon = icon("dumbbell"),
                       color = 'red'
                     )}
                 })
    }
                 )
})


#lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)

