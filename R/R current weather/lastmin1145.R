library(jsonlite)
library(data.table)
library(dplyr)

library(zipcode)
data("zipcode")
all_data<-zipcode
all_data$city<-tolower(all_data$city)
all_data <- subset(all_data, all_data$state=="FL")
tolower((unique(all_data$city))) #544 cities in FL
set.seed(1)


  cities_of_interest<- c("orlando" ,"melbourne","indialantic","hialeah","hallandale","hollywood" ,"tampa")

cities_of_interest=tolower(cities_of_interest)
data_I_want=filter(all_data, city%in%cities_of_interest)
data_I_want=distinct(data_I_want,city,.keep_all = TRUE)


collected_data<- c()

for(i in 1:nrow(data_I_want)){

  url <- paste0("http://api.wunderground.com/api/72a63563ac6d4c03/forecast/geolookup/conditions/q/FL/",data_I_want$city[i],".json")
  req <- fromJSON(paste0(url))
  city=req$location$city
  #city_other=data_I_want$city[i]
  status=req$current_observation$weather   
  date = req$current_observation$observation_time
  rain = req$current_observation$precip_today_string   
  temp=req$current_observation$temp_c
  

  this_data=cbind(date=date,city=city,
                       rain=rain,
                       temperature=temp,weather=status)
  collected_data=rbind(collected_data, this_data)
  }
  
  
library(base)
dat <- cbind(collected_data,data_I_want)
save(dat,file="/Users/sandar/Desktop/WeatherGeeks/collected_data.Rdata")
Sys.sleep(12*60*60)  # collect data every 12 hrs

library(googleVis)

data(Andrew)

#AndrewGeoMap <- gvisGeoMap(Andrew, locationvar='LatLong', numvar='Speed_kt'                          hovervar='Category',                options=list(width=800,height=400,                                     region='US', dataMode='Markers'))

AndrewMap <- gvisMap(Andrew, 'LatLong' , 'Tip',
                     options=list(showTip=TRUE, showLine=TRUE,
                                  enableScrollWheel=TRUE,
                                  mapType='hybrid', useMapTypeControl=TRUE,
                                  width=800,height=400,icons=paste0("{","'default': {'normal': 'http://icons.iconarchive.com/", "icons/icons-land/vista-map-markers/48/", "Map-Marker-Ball-Azure-icon.png',\n", "'selected': 'http://icons.iconarchive.com/", "icons/icons-land/vista-map-markers/48/",  "Map-Marker-Ball-Right-Azure-icon.png'", "}}")))
plot(AndrewMap)
#AndrewTable <- gvisTable(Andrew,options=list(width=800))

## Combine the outputs into one page:

#AndrewVis <- gvisMerge(AndrewGeoMap, AndrewMap)
plot(AndrewMap)
gvisMap {googleVis}	

library(leaflet)

AndrewIcon <- makeIcon(
  iconUrl = "/Users/sandar/Desktop/WeatherGeeks/icons/hurricane.png",
  iconWidth = 38, iconHeight = 95,
  iconAnchorX = 22, iconAnchorY = 94
)
AndrewVis <- gvisMerge(AndrewGeoMap, AndrewMap)

plot(AndrewVis)%>% addTiles() %>%
  addMarkers(icon = AndrewIcon)

leaflet(data = quakes[1:4,]) %>% addTiles() %>%
  addMarkers(~long, ~lat, icon = greenLeafIcon)
