#install.packages("rwunderground")
rwunderground::set_api_key("72a63563ac6d4c03") #500 times a day only with sandar's account

library(rwunderground)

#location by city
set_location(territory = "Hawaii", city = "Honolulu")
#set_location(territory = "California", city = "San Diego")

#location by airport
lookup_airport("singapore")
set_location(airport_code = "SIN")


#Locations by zip code
set_location(zip_code = "96813")

#alerts
alerts(set_location(territory = "Hawaii", city = "Honolulu"))
alerts(set_location(territory = "Florida", city = "Florida City"))
alerts(set_location(territory = "Florida", city = "Tampa"))


#forecast
fc<-forecast10day(set_location(territory = "florida", city = "tampa"))
str(fc)
library(plotly)
plot_ly() %>%
  add_lines(x = fc$date, y = fc$temp_high, name = "Maximum Temperature") %>%
  add_lines(x = fc$date, y = fc$temp_low, name = "Minimum Temperature")%>%
  layout(title = 'Temperature',
         legend = list(orientation = 'h'),
         yaxis = list(title = "in Fahrenheit"))  

plot_ly() %>%
  add_lines(x = fc$date, y = fc$temp_high, name = "Maximum Temperature") %>%
  add_lines(x = fc$date, y = fc$temp_low, name = "Minimum Temperature")%>%
  layout(title = 'Temperature',
         legend = list(orientation = 'h'),
         yaxis = list(title = "in Fahrenheit"))  



hourly10day(set_location(territory = "Hawaii", city = "Honolulu"))


#Historical data YYYYMMDD
history(set_location(territory = "Hawaii", city = "Honolulu"), date = 20150131)


#planning MMDD format based on past weather
planner(set_location(territory = "Switzerland", city = "Zurich"), start_date = "1209", end_date = "1509")

#tides
tide(set_location(territory = "Hawaii", city = "Honolulu")) 
rawtide(set_location(territory = "Hawaii", city = "Honolulu"))


