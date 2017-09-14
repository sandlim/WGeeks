# package 
library(raincpc)
library(SDMTools)
library(raster)
library(ggplot2)
library(rnoaa)
library('plyr')

#cpc_get_rawdata(2016, 9, 13, 2016, 9, 13, usa = FALSE) 
#rain2 <- cpc_read_rawdata(2016, 9 , 13)


# Use a fluid Bootstrap layout
fluidPage(
  titlePanel("Global daily rainfall"),
  
  fluidRow(
    
    
    column(4, wellPanel(
      dateInput(inputId="dates", "Day:", value = "2017-02-29", min = NULL, max = NULL,
                format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                language = "en", width = NULL),
      helpText("Choose the date"),
      hr(),
    
      sliderInput("n", "n (isolated):",
                  min = 10, max = 1000, value = 200, step = 10),
      
      textInput("text", "text (not isolated):", "input text"),
      br(),
      actionButton("goButton", "Go!")
      )),
    
    
    column(8,
           h4("summary"),
           textOutput("summary"),
           h4("summary2"),
           textOutput("summary2"),
           h3(textOutput("caption", container = span)),
           plotOutput("rainPlot")  
    )
  )
)

