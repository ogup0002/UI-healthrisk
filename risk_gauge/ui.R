#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library('lessR')
library(shiny)
library(flexdashboard)
library(shinythemes)
library(shinyBS)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  theme = shinytheme("flatly"),

      # Application title
    titlePanel("Risk Analysis Meter"),

    # Sidebar with a slider input for number of bins
    fluidRow(
      column(6, wellPanel(
        selectInput("working_hour","Number of Working Hours on an average typical working day",c("4-6", "7-9", "10-12", "14 or more")),
        uiOutput('slider1'),
        uiOutput('slider2'),
        selectInput("breaks","Break from work after every (in mins)",c("15", "30", "60", "120")),
        
        fluidRow(wellPanel(actionButton('go','Analyse'),
              actionButton('send','Send Your Statistics'),
             
        ))
      )),
    ),
    fluidRow(
      column(6, wellPanel(
       gaugeOutput('viz'),
       
       bsModal("modalExample", "Your plot", "go", size = "large",
               
       wellPanel(
         selectInput('viz_type', 'View Statistics for: ',c("Sitting Hours on a working day","Physical Activity Hours while working", "Break interval during Sitting")),
         verbatimTextOutput('textinfo'),
         verbatimTextOutput('textstatic'),
         plotOutput("plot"))
       )
       #plotOutput('plot')
      ))
    )
))
