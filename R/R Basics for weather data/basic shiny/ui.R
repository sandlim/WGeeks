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
  
  
  
  # Give the page a title
  titlePanel("Global daily rainfall"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      
      # Input: Text for providing a caption ----
      # Note: Changes made to the caption in the textInput control
      # are updated in the output area immediately as you type

      
      # Input: Selector for choosing dataset ----
  
      selectInput(inputId = "datasets",
                  label = "Day:",
                  choices = c("day1", "day2","day3", "day4","day5", "day6","day7")),
      
    
      hr(),
      helpText("Choose the date")
    ),
    
    # Create a spot for the barplot
    
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Formatted text for caption ----
      h3(textOutput("caption", container = span)),
      
      # Output: Verbatim text for data summary ----
      verbatimTextOutput("summary"),
      
      # Output: HTML table with requested number of observations ----
      plotOutput("rainPlot")  
      
    )
    
  
    
  )
)