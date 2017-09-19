library(raincpc)
library(SDMTools)
library(raster)
library(ggplot2)
library(rnoaa)
library('plyr')
#through NOAA main
#Rainfall data for the world (1979-present, resolution 50 km), and the US (1948-present, resolution 25 km).
rain <-cpc_prcp(date = "2016-09-13", us = FALSE)

#through NOAA: CPC rainfall data for the world (1979 to present, 50 km resolution) and the USA (1948 to present, 25 km resolution), is one of the few high quality, long term, observation based, daily rainfall products available for free. 
cpc_get_rawdata(2016, 9, 13, 2016, 9, 13, usa = FALSE) 
rain2 <- cpc_read_rawdata(2016,9 , 13)
print(rain2)
plot(rain2, 
     breaks = c(0, 1, 90, 180, 270, 360),
     col = c("grey", "red", "green", "blue"), 
     main = "Rainfall (mm) 13 September 2017")

#average rainfall
cpc_get_rawdata(2014, 7, 3, 2014, 7, 7, usa = FALSE) 
rain3 <- cpc_read_rawdata(2014, 7, 3)
rain4 <- cpc_read_rawdata(2014, 7, 4)
rain5 <- cpc_read_rawdata(2014, 7, 5)
rain6 <- cpc_read_rawdata(2014, 7, 6)
rain7 <- cpc_read_rawdata(2014, 7, 7)

rain_tot <- rain3 + rain4 + rain5 + rain6 + rain7
print(rain_tot)

plot(rain_tot)

raster_ggplot <- function(rastx) {
  require(SDMTools)
  stopifnot(class(rastx) == "RasterLayer")
  
  gfx_data <- getXYcoords(rastx)
  # lats need to be flipped
  gfx_data <- expand.grid(lons = gfx_data$x, lats = rev(gfx_data$y), 
                          stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
  gfx_data$rain <- rastx@data@values
  
  return (gfx_data)
}
