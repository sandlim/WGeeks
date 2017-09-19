# package 
library(raincpc)
library(SDMTools)
library(raster)
library(ggplot2)
library(rnoaa)
library('plyr')


#cpc_get_rawdata(2017, 9, 1, 2017, 9, 7, usa = FALSE) 
rain1 <- cpc_read_rawdata(2017, 9, 1)
rain2 <- cpc_read_rawdata(2017, 9, 2)
rain3 <- cpc_read_rawdata(2017, 9, 3)
rain4 <- cpc_read_rawdata(2017, 9, 4)
rain5 <- cpc_read_rawdata(2017, 9, 5)
rain6 <- cpc_read_rawdata(2017, 9, 6)
rain7 <- cpc_read_rawdata(2017, 9, 7)

rain_tot <- rain1 + rain2 + rain3 + rain4+ rain5+ rain6 + rain7

function(input, output) {

  datasetInput <- reactive({
    switch(input$datasets,
           "day1" = rain1,
           "day2" = rain2,
           "day3" = rain3,
           "day4" = rain4,
           "day5" = rain5,
           "day6" = rain6,
           "day7" = rain7)
  })

output$rainPlot <- renderPlot({
    # Render a plot
    #plot(rain_tot, breaks = c(0, 1, 90, 180, 270, 360), col = c("grey", "red", "green", "blue"),  main = "Rainfall (mm) 1-7 September 2017")
   dataset <- datasetInput()
    plot(dataset,main = "Rainfall (mm) in the first week of September 2017")
  })

}

