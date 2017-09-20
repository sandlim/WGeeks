#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(raster)
library(ggplot2)
#library(plotly)
library('plyr')
library(lubridate)
library(rwunderground)
suppressPackageStartupMessages(library(googleVis))

rwunderground::set_api_key("  ") #fill up your api key here

#load("/Users/sandar/Desktop/WeatherGeeks/collected_data.Rdata")


setwd("/Users/sandar/Desktop/WeatherGeeks/")
data1<-na.omit(read.csv("incidents.csv"))
data2<-na.omit(read.csv("incidents.csv"))
#names(data2)
#which(colnames(data2)=="incidentType")
data2<-data2[1:20,c(1,2,4,5,6)]
names(data2)[1:5]<- c("IncidentType","County","State","PlaceCode","IncidentBeginDate")

trial<-data.frame(data2,gsub('(County)', '', data2$County))
data3<-data.frame(trial, gsub("\\s*\\([^\\)]+\\)","",as.character(trial$County)))
#location is state, county
data3$Location <- do.call(paste, c(data3[c(3,7)], sep = ",")) 
#remove crap data
data3<-data3[,c(1:5,8)]


library(zipcode)
data(zipcode)
#zdat<-transform(zipcode, Location=interaction(state,city,sep=','))
zdat<-transform(zipcode, Location=interaction(state,city,sep=','))

#Merge Zipcode Data (zdat) and FEMA Disaster Data (data3) for geolocation lookup prep
geodat<-merge(data3,zdat,by="Location")
geodat$latlong<-paste(geodat$latitude, geodat$longitude, sep = ':')
##Server



#rwunderground::set_api_key("72a63563ac6d4c03") 


#myicon=function(condition){
  #makeIcon(
 #   iconUrl = paste0("data/",condition,".png"),
  #  iconWidth = 70, iconHeight = 70,
  #  iconAnchorX = 22, iconAnchorY = 94
 # )}

function(input, output){
    
  
  #Weather forecast:temp
  output$forecast10days.temp<-renderPlotly({
  fc<-forecast10day(set_location(territory = input$state, city = input$city))
  str(fc)
  library(plotly)
  plot_ly() %>%
    add_lines(x = fc$date, y = fc$temp_high, name = "Maximum Temperature") %>%
    add_lines(x = fc$date, y = fc$temp_low, name = "Minimum Temperature")%>%
    layout(title = 'Temperature',
           legend = list(orientation = 'h'),
           yaxis = list(title = "in Fahrenheit"))  

  })
  
  #weather forecast: prep, humidity, wind
 # output$rain10days <-renderPlotly({
  #  str
   # plot_ly(fc, x = ~date, y = ~precip, type = 'bar', name = 'Precipitation') %>%
    #  add_trace(y = ~humidty, name = 'Humidity') %>%
     # layout(yaxis = list(title = '%'), barmode = 'group')%>%
      #layout(title = '',
       #      xaxis = list(title = ""),
        #     yaxis = list(side = 'left', title = 'Humidity, clouds (%)', showgrid = FALSE, zeroline = FALSE),
         #    yaxis2 = list(side = 'right', overlaying = "y", title = 'Rainfall', showgrid = FALSE, zeroline = FALSE))
  #})
    
    
    
    

  
  #tabPanel(tags$em("Rainfall, Humidity and Clouds",style="font-size:120%"),
     #      tags$hr(style="border-color:  #d27979;"),
      #     tabsetPanel(
       #      tabPanel(tags$em("Three Days"),plotlyOutput("humidty_rain_cloudness_3days")),
        #     tabPanel(tags$em("Five Days"),plotlyOutput("humidty_rain_cloudness_5days")),
         #    tabPanel(tags$em("Two Weeks"),plotlyOutput("humidty_rain_cloudness_16days"))
  
  #output$forecast <- renderText({
   # input$goButton
    #fc<-forecast3day(set_location(territory = input$country, city = input$city)) 
    #fc
  #})
  
  
  #SUMMARY 2
  output$alerts <- renderText({
    input$goButton
    al <- alerts(set_location(territory = "Florida", city = "Tampa"))
    str <- paste0('"For" input$city: ', al, '"')
  })
    
    
    #Google
    output$gvis<-renderGvis({
      #subDat<-subset(geodat, geodat$IncidentType %in% input$incidents)
      gvisMap(geodat,locationvar='latlong',
              options=list(enableScrollWheel=TRUE,
                           mapType='terrain', 
                           useMapTypeControl=TRUE)) })
                          # ,
                          #icons=paste0("{","'default': {'normal': 'http://icons.iconarchive.com/", "icons/icons-land/vista-map-markers/48/", "Map-Marker-Ball-Azure-icon.png',\n", "'selected': 'http://icons.iconarchive.com/", "icons/icons-land/vista-map-markers/48/",  "Map-Marker-Ball-Right-Azure-icon.png'", "}}")
                          
    


  
  
}
