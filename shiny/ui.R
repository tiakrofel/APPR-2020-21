library(shiny)

shinyUI(fluidPage(
  
  titlePanel(""),
  tabPanel("Graf",
           sidebarPanel(
             selectInput("state", label = "Izbrana zvezna država", 
                         choices = unique(osnova$Zvezna_drzava))),
           mainPanel(plotOutput("prvi")))
))