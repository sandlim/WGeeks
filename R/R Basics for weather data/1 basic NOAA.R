#weather R
#install.packages(rnoaa)
#install.packages("devtools") Just install any packages you need 

library(rnoaa)
library('plyr')

#NOAA's National Climatic Data Center

#add NOAA_KEY=your-noaa-token to .Renviron file 

#getting info for specific station with known station id, location, data set
#call for locations
ncdc_locs(locationcategoryid = "CITY", sortfield = "name", sortorder = "desc",
          limit = 5)
#mindate    maxdate           name datacoverage            id
#1 1892-08-01 2017-07-31     Zwolle, NL       1.0000 CITY:NL000012
#2 1901-01-01 2017-09-09     Zurich, SZ       1.0000 CITY:SZ000007
#3 1957-07-01 2017-09-09  Zonguldak, TU       1.0000 CITY:TU000057
#4 1906-01-01 2017-09-09     Zinder, NG       0.9025 CITY:NG000004
#5 1973-01-01 2017-09-09 Ziguinchor, SG       1.0000 CITY:SG000004

ncdc_stations(datasetid='GHCND', locationid='FIPS:12017', stationid='GHCND:USC00084289')

#Search for and get NOAA NCDC data.
#data frame for given date (normaly daily data will start from specified), datatypeid = maximum daily temperature
out.data <- ncdc(datasetid='NORMAL_DLY', datatypeid='dly-tmax-normal', startdate = '2010-05-01', enddate = '2010-05-10')
#choose one of the stations
#e.gs
out <- ncdc(datasetid='NORMAL_DLY', stationid='GHCND:AQW00061705', datatypeid='dly-tmax-normal', startdate = '2010-01-01', enddate = '2010-12-10', limit = 300)
ncdc_plot(out)
out <- ncdc(datasetid='NORMAL_DLY', stationid='GHCND:USW00014895', datatypeid='dly-tmax-normal', startdate = '2010-01-01', enddate = '2010-12-10', limit = 300)
ncdc_plot(out)


#plotting variables
#PRCP: Precipitation, in tenths of millimeters
#TAVG: Average temperature, in tenths of degrees Celsius
#TMAX: Maximum temperature, in tenths of degrees Celsius • TMIN: Minimum temperature, in tenths of degrees Celsius

#More plots
out <- ncdc(datasetid='GHCND', stationid='GHCND:USW00014895', datatypeid='PRCP', startdate = '2010-05-01', enddate = '2010-10-31', limit=500)
ncdc_plot(out)

out2 <- ncdc(datasetid='GHCND', stationid='GHCND:USW00014895', datatypeid='PRCP', startdate = '2010-05-01', enddate = '2010-05-03', limit=100)
ncdc_plot(out)
ncdc_plot(out, breaks="28 days", dateformat="%d/%m")


#Combine many calls to noaa function
out1 <- ncdc(datasetid='GHCND', stationid='GHCND:USW00014895', datatypeid='PRCP', startdate = '2010-03-01', enddate = '2010-05-31', limit=500)
out2 <- ncdc(datasetid='GHCND', stationid='GHCND:USW00014895', datatypeid='PRCP', startdate = '2010-09-01', enddate = '2010-10-31', limit=500)
df <- ncdc_combine(out1, out2)
#head(df[[1]]); tail(df[[1]])
ncdc_plot(df)
ncdc_plot(out1, out2, breaks="45 days")

