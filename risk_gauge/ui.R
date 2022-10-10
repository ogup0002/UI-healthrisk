#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#install.packages("remotes")
#remotes::install_github("lgnbhl/scroller")
library(shiny)
library(flexdashboard)
library(shinythemes)
library(shinyBS)
library(shinyWidgets)
library(shinydashboard)
library(shinyjs)
library(scroller)
library(dplyr)
# Define UI for application that draws a histogram

css <- '
.tooltip {
  pointer-events: none;
}
.tooltip > .tooltip-inner {
  pointer-events: none;
  background-color: #73AD21;
  color: #FFFFFF;
  border: 1px solid green;
  padding: 10px;
  font-size: 25px;
  font-style: italic;
  text-align: justify;
  margin-left: 0;
  max-width: 1000px;
}
.tooltip > .arrow::before {
  border-right-color: #73AD21;
}
'

js <- "
$(function () {
  $('[data-toggle=tooltip]').tooltip()
})
"



shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  useShinydashboard(),
  scroller::use_scroller(),
      # Application title
    titlePanel("Risk Analysis Meter"),
  tags$style(HTML("
    body {
            background-color: #33 DCDCDC;
            color: black;
            }")),
  tags$head(tags$style(type = 'text/css',".shiny-input-panel{padding: 0px 0px !important;}")),
  chooseSliderSkin("Nice"),

    # Sidebar with a slider input for number of bins
    fluidRow(style = "background-color:#FFFFFF;",
      column(12, style = "background-color:#FFFFFF;",wellPanel(
        style = "background-color:#FFFFFF",
        selectInput("working_hour","Number of Working Hours on an average typical working day",c("4-6", "7-9", "10-12", "14 or more")),
        uiOutput('slider1'),
        uiOutput('slider2'),
        #div(id="top", "I'm at the bottom, javascript can scroll me into view"),
        selectInput("breaks","Break from work after every (in mins)",c(15, 30, 60, 120), selected = 15),
        
        fluidRow(wellPanel(style = "background-color:#FFFFFF",actionButton('go','Analyse', icon("magnifying-glass"), 
                                        style="color: white; background-color: #1D65E4; border-color: #1D65E4")  %>% 
                             shiny::a() %>%
                             shiny::tagAppendAttributes(href = "##bottom"),
            
              #a(class = "btn-primary btn-lg", href = "##bottom"),            
              # actionButton('send','Send Your Statistics', icon("paper-plane"), 
              #              style="color: white; background-color: #1D65E4; border-color: #1D65E4"),
              # span('Info', span(`data-toggle` = "tooltip", `data-placement` = "right",
              #                   title = "Your input statistics will be sent to us. We do not collect your personal data.",
              #                   icon("info-circle")))
             
        ))
      ))
    ),
    
  fluidRow(
      column(12, wellPanel(style = "background-color:#FFFFFF",
       column(12,wellPanel(style = "background-color:#FFFFFF",
                           div(id="bottom"),
                           gaugeOutput('viz'),
                          br(),
                        
         # fluidRow(actionButton('popup','Compare your statistics', icon = icon('people-group'), style="color: white; background-color: #1D65E4; border-color: #1D65E4"),
         # span('Info', span(`data-toggle` = "tooltip", `data-placement` = "right",
         #                   title = "Comparing will give you your standing among the Melbournian Working Lifestyle.",
         #                   icon("info-circle")))),
         # bsModal("modalExample", "Compare statistics", "popup", size = "large",
         #         
         #         wellPanel(style = "background-color:#FFFFFF",
         #                   selectInput('viz_type', 'View Statistics for: ',c("Sitting Hours on a working day","Physical Activity Hours while working", "Break interval during Sitting")),
         #                   verbatimTextOutput('textinfo'),
         #                   #plotOutput("plot")
         #                   ),
         #         fluidRow(
         #           valueBoxOutput("textstatic2"),
         #           verbatimTextOutput('textstatic1'),
         #         )
         # ),
         br(),
         br(),
         infoBoxOutput('ibox', width = 12),
       ))
      ),          
       )
       ),
       
  fluidRow(
    column(12, wellPanel(style = "background-color:#FFFFFF",
      fluidRow(textOutput('static')),
      tags$head(tags$style("#static{color: black;
                                 font-size: 30px;
                                 font-style: italic;
                                 }"
      )
      ),
      fluidRow(infoBoxOutput('ibox_sitting', width = 12)),
      fluidRow(infoBoxOutput('ibox_physical', width = 12)),
      fluidRow(infoBoxOutput('ibox_breaks', width = 12))
      #valueBoxOutput()
    ))
  )
))
