# package 
library(raincpc)
library(SDMTools)
library(raster)
library(ggplot2)
library(rnoaa)
library('plyr')
library(lubridate)

#cpc_get_rawdata(2017, 9, 1, 2017, 9, 7, usa = FALSE) 
#rain1 <- cpc_read_rawdata(2017, 9, 1)
#rain2 <- cpc_read_rawdata(2017, 9, 2)
#rain3 <- cpc_read_rawdata(2017, 9, 3)
#rain4 <- cpc_read_rawdata(2017, 9, 4)
#rain5 <- cpc_read_rawdata(2017, 9, 5)
#rain6 <- cpc_read_rawdata(2017, 9, 6)
#rain7 <- cpc_read_rawdata(2017, 9, 7)
#rain_tot <- rain1 + rain2 + rain3 + rain4+ rain5+ rain6 + rain7
#month(dmy(some_date)) ##output as  2012-02-29

function(input, output) {
  
  #SUMMARY 1 : date = output as 2012-02-29
  output$summary <- renderText({
    input$goButton
    paste0('input$text is "', input$text,
           '", and input$n is ', isolate(input$n), '", and input$dates is ', isolate
           (input$dates), month(input$dates)
           ) 
    })
  
 
  #SUMMARY 2
  output$summary2 <- renderText({
    input$goButton
    str <- paste0('input$text is "', input$text, '"')
    isolate({
      str <- paste0(str, ', and input$n is ')
      paste0(str, isolate(input$n))
      })
    })

  #Day to var and download data

  
  #PLOT
  output$rainPlot <- renderPlot({
    input$goButton
    isolate({
      cpc_get_rawdata(year(input$dates), month(input$dates),day(input$dates), 
                    year(input$dates), month(input$dates), day(input$dates), 
                    usa = FALSE) 
      rain <- cpc_read_rawdata(year(input$dates), month(input$dates), 
                               day(input$dates)) 
    plot(rain, main = paste("Rainfall (mm) on", day(input$dates),
                            month(input$dates, label=TRUE),year(input$dates) ))
    })
  })

}

