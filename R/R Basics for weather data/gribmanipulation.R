#loc=file.path("ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2017090718/gfs.t18z.sfluxgrbf384.grib2")
#download.file(loc,"temp.grb",mode="wb")
#shell/system("wgrib2 -s temp03.grb | grep :LAND: | wgrib2 -i temp00.grb -netcdf LAND.nc",intern=T)
#library(rNOMADS) no longer available

#https://cran.r-project.org/web/packages/rnoaa/rnoaa.pdf


library(rnoaa)
#Arc2 - Africa Rainfall Climatology version 2
#arc2(date = "1983-01-01")
#arc2(date = "2017-02-14")


#Many functions in this package interact with the National Climatic Data Center application pro- gramming interface (API) at https://www.ncdc.noaa.gov/cdo-web/webservices/v2, all of which func- tions start with ncdc_. An access token, or API key, is required to use all the ncdc_ functions. The key is required by NOAA, not us. Go to the link given above to get an API key.


#Buoy data
## Not run:
# Get buoy station information
x <- buoy_stations()
library("leaflet")
leaflet(data = na.omit(x)) %>%
  leaflet::addTiles() %>%
  leaflet::addCircles(~lon, ~lat, opacity = 0.5)
# Get available buoys
buoys(dataset = 'cwind')
# Get data for a buoy
## if no year or datatype specified, we get the first file
buoy(dataset = 'cwind', buoyid = 46085)
# Including specific year
buoy(dataset = 'cwind', buoyid = 41001, year = 1999)
# Including specific year and datatype
buoy(dataset = 'cwind', buoyid = 41001, year = 2008, datatype = "cc")
buoy(dataset = 'cwind', buoyid = 41001, year = 2008, datatype = "cc")
# Other datasets
buoy(dataset = 'ocean', buoyid = 41029)
# curl debugging
library('httr')
buoy(dataset = 'cwind', buoyid = 46085, config=verbose())
# some buoy ids are character, case doesn't matter, we'll account for it
buoy(dataset = "stdmet", buoyid = "VCAF1")
buoy(dataset = "stdmet", buoyid = "wplf1")
buoy(dataset = "dart", buoyid = "dartu")
## End(Not run)

## Not run:
# Get monthly mean sea level data at Vaca Key (8723970)
coops_search(station_name = 8723970, begin_date = 20120301,
             end_date = 20141001, datum = "stnd", product = "monthly_mean")
# Get verified water level data at Vaca Key (8723970)
coops_search(station_name = 8723970, begin_date = 20140927,
             end_date = 20140928, datum = "stnd", product = "water_level")
# Get daily mean water level data at Fairport, OH (9063053)
coops_search(station_name = 9063053, begin_date = 20150927,
             end_date = 20150928, product = "daily_mean", datum = "stnd",
             time_zone = "lst")
# Get air temperature at Vaca Key (8723970)
coops_search(station_name = 8723970, begin_date = 20140927,
             end_date = 20140928, product = "air_temperature")



meteo_nearby_stations(lat_lon_df, lat_colname = "latitude",
                      lon_colname = "longitude", station_data = ghcnd_stations(), var = "all",
                      year_min = NULL, year_max = NULL, radius = NULL, limit = NULL)


