library(shiny)

shinyUI(fluidPage(
  
  titlePanel(""),
  
  tabPanel("Graf",
           sidebarPanel(
             selectInput("state", label = "Izbira zvezne države", 
                         choices = unique(osnova$Zvezna_drzava))),
           mainPanel(plotOutput("prvi")))
))