#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(lessR)
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

    # Sidebar with a slider input for number of bins
    fluidRow(
      column(6, wellPanel(
        selectInput("working_hour","Number of Working Hours on an average typical working day",c("4-6", "7-9", "10-12", "14 or more")),
        uiOutput('slider1'),
        uiOutput('slider2'),
        selectInput("breaks","Break from work after every (in mins)",c(15, 30, 60, 120), selected = 15),
        
        fluidRow(wellPanel(actionButton('go','Analyse'),
              actionButton('send','Send Your Statistics')
             
        ))
      ))
    ),
    fluidRow(
      column(6, wellPanel(
       gaugeOutput('viz'),
       fluidRow(wellPanel(actionButton('popup','Compare your statistics'))),
       bsModal("modalExample", "Your plot", "popup", size = "large",
               
       wellPanel(
         selectInput('viz_type', 'View Statistics for: ',c("Sitting Hours on a working day","Physical Activity Hours while working", "Break interval during Sitting")),
         verbatimTextOutput('textinfo'),
         plotOutput("plot")),
       #column(6, 
      #        verbatimTextOutput('textstatic3'),
      #        verbatimTextOutput('textstatic2')
      # )
      fluidRow(
        #valueBoxOutput("textstatic3"),
      valueBoxOutput("textstatic2"),
      verbatimTextOutput('textstatic1'),
        
       )
       )
       #plotOutput('plot')
      ))
    )
))
