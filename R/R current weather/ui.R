#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(raincpc)
library(SDMTools)
library(raster)
library(ggplot2)
library(rnoaa)
library('plyr')

library(shiny)
library(zipcode)


library(jsonlite)
library(data.table)
library(dplyr)

#all_data<-data("zipcode")
#all_data$city<-tolower(all_data$city)
#all_data <- subset(all_data, all_data$state="FL")
#fl_cities <-unique(all_data$cities)


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



# Use a fluid Bootstrap layout
fluidPage(
  
  fluidRow(
    
    column(4, #wellPanel(
      #dateInput(inputId="dates", "Day:", value = "2017-02-29", min = NULL, max = NULL,format = "yyyy-mm-dd", startview = "month", weekstart = 0, language = "en", width = NULL),# helpText("Choose the date"),#hr(),
      
      textInput("country", "Your Territory", "Florida"),
      textInput("city", "Your City", "Tampa"),
      br(),
      
      actionButton("goButton", "Go!"),
      br()
   ),

    
    column(8, 
           htmlOutput("gvis"),
           
           h4("Weather Alerts"),
           textOutput("alerts")
          # h3(textOutput("caption", container = span))
     
    )
   
  
  
  
)
)