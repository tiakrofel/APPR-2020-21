library(shiny)

shinyServer(function(input, output) {
  
  output$prvi <- renderPlot({
    graf.bdp.states <- ggplot(osnova %>% filter(Zvezna_drzava == input$state)) + 
      aes(x = Leto, y = BDPpp) + geom_line() + geom_point() +
      geom_line() + geom_point() + 
      scale_x_continuous(breaks = c(2010, 2013, 2016, 2019))  +
      xlab("Leto") + ylab("BDP na prebivalca ($)") +
      ggtitle("BDP na prebivalca")
    print(graf.bdp.states)
  })
})
