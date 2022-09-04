#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(flexdashboard)
library(shinythemes)
library(shinyBS)
library(shinyWidgets)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  useShinydashboard(),

      # Application title
    titlePanel("Risk Analysis Meter"),
  tags$style(HTML("
    body {
            background-color: #DCF0FF;
            color: black;
            }")),
  tags$head(tags$style(type = 'text/css',".shiny-input-panel{padding: 0px 0px !important;}")),

    # Sidebar with a slider input for number of bins
    fluidRow(
      column(6, style = "background-color:#DCF0FF;",wellPanel(
        selectInput("working_hour","Number of Working Hours on an average typical working day",c("4-6", "7-9", "10-12", "14 or more")),
        uiOutput('slider1'),
        uiOutput('slider2'),
        selectInput("breaks","Break from work after every (in mins)",c(15, 30, 60, 120), selected = 15),
        
        fluidRow(wellPanel(actionButton('go','Analyse', icon("magnifying-glass"), 
                                        style="color: black; background-color: #DCF0FF; border-color: #DCF0FF"),
              actionButton('send','Send Your Statistics', icon("paper-plane"), 
                           style="color: black; background-color: #DCF0FF; border-color: #DCF0FF", offset=10)
             
        ))
      ))
    ),
    
  fluidRow(
      column(6, wellPanel(
       column(6,wellPanel(gaugeOutput('viz', height = "100%"),
                          br(),
                          infoBoxOutput('ibox'),
                          
       )
       ),
       fluidRow(actionButton('popup','Compare your statistics', icon = icon('people-group'), style="color: black; background-color: #DCF0FF; border-color: #DCF0FF")),
       bsModal("modalExample", "Your plot", "popup", size = "large",
               
       wellPanel(
         selectInput('viz_type', 'View Statistics for: ',c("Sitting Hours on a working day","Physical Activity Hours while working", "Break interval during Sitting")),
         verbatimTextOutput('textinfo'),
         plotOutput("plot")),
      fluidRow(
      valueBoxOutput("textstatic2"),
      verbatimTextOutput('textstatic1'),
      )
       )
      ))
    ),
  fluidRow(
    column(6, wellPanel(
      #valueBoxOutput()
    ))
  )
))
