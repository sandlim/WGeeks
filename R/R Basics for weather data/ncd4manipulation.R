#reference: http://geog.uoregon.edu/bartlein/courses/geog490/week04-netCDF.html#open-the-netcdf-file


library(ncdf4)

ncname <- "cru10min30_tmp"  
ncfname <- paste(ncname,".nc", sep="")
dname <- "tmp"  # note: tmp means temperature (not temporary)

#download file: http://thredds.ucar.edu/thredds/catalog.html
#sample file is from http://geog.uoregon.edu/GeogR/data/raster/cru10min30_tmp.nc


# open a netCDF file
ncin <- nc_open("/Users/sandar/Desktop/Climate test/cru10min30_tmp.nc")
print(ncin)


lon <- ncvar_get(ncin,"lon")
nlon <- dim(lon)
head(lon)


lat <- ncvar_get(ncin,"lat",verbose=F)
nlat <- dim(lat)
head(lat)


print(c(nlon,nlat))

t <- ncvar_get(ncin,"time")
t


tunits <- ncatt_get(ncin,"time","units")
nt <- dim(t)
nt


tunits


tmp_array <- ncvar_get(ncin,dname)
dlname <- ncatt_get(ncin,dname,"long_name")
dunits <- ncatt_get(ncin,dname,"units")
fillvalue <- ncatt_get(ncin,dname,"_FillValue")
dim(tmp_array)


title <- ncatt_get(ncin,0,"title")
institution <- ncatt_get(ncin,0,"institution")
datasource <- ncatt_get(ncin,0,"source")
references <- ncatt_get(ncin,0,"references")
history <- ncatt_get(ncin,0,"history")
Conventions <- ncatt_get(ncin,0,"Conventions")


nc_close(ncin)

outworkspace="netCDF01.RData"
save.image(file=outworkspace)

#Check what’s in the current workspace:
ls()


#visualisation
library(chron)
library(lattice)
library(RColorBrewer)

# convert time -- split the time units string into fields
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
options(chron.origin=c(tmonth, tday, tyear))
#chron(time,origin=c(tmonth, tday, tyear))


#3.2 Replace netCDF fillvalues with R NAs
tmp_array[tmp_array==fillvalue$value] <- NA
length(na.omit(as.vector(tmp_array[,,1]))) #62961



#visualisation
# get a single slice or layer (January)
m <- 1
tmp_slice <- tmp_array[,,m]
# quick map
image(lon,lat,tmp_slice, col=rev(brewer.pal(10,"RdBu")))



# levelplot of the slice
grid <- expand.grid(lon=lon, lat=lat)
cutpts <- c(-50,-40,-30,-20,-10,0,10,20,30,40,50)
levelplot(tmp_slice ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))))


#now full data
# create dataframe -- reshape data
# matrix (nlon*nlat rows by 2 cols) of lons and lats
lonlat <- as.matrix(expand.grid(lon,lat))
dim(lonlat)

# vector of `tmp` values
tmp_vec <- as.vector(tmp_slice)
length(tmp_vec)

# create dataframe and add names
tmp_df01 <- data.frame(cbind(lonlat,tmp_vec))
names(tmp_df01) <- c("lon","lat",paste(dname,as.character(m), sep="_"))
head(na.omit(tmp_df01), 10)

# set path and filename
csvpath <- "/Users/Sandar/Desktop/Climate test/data/csv_files"
csvname <- "cru_tmp_1.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(tmp_df01),csvfile, row.names=FALSE, sep=",")


# reshape the array into vector
tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)

# reshape the vector into a matrix
tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=nt)
dim(tmp_mat)

head(na.omit(tmp_mat))


# create a dataframe
lonlat <- as.matrix(expand.grid(lon,lat))
tmp_df02 <- data.frame(cbind(lonlat,tmp_mat))
names(tmp_df02) <- c("lon","lat","tmpJan","tmpFeb","tmpMar","tmpApr","tmpMay","tmpJun",
                     "tmpJul","tmpAug","tmpSep","tmpOct","tmpNov","tmpDec")
# options(width=96)
head(na.omit(tmp_df02, 20))




# get the annual mean and MTWA and MTCO
tmp_df02$mtwa <- apply(tmp_df02[3:14],1,max) # mtwa
tmp_df02$mtco <- apply(tmp_df02[3:14],1,min) # mtco
tmp_df02$mat <- apply(tmp_df02[3:14],1,mean) # annual (i.e. row) means
head(na.omit(tmp_df02))

dim(na.omit(tmp_df02))


# write out the dataframe as a .csv file (second data frame dropping NAs)
csvpath <- "/Users/Sandar/Desktop/Climate test/data/csv_files"
csvname <- "cru_tmp_2.csv"
csvfile <- paste(csvpath, csvname, sep="")
write.table(na.omit(tmp_df02),csvfile, row.names=FALSE, sep=",")


# create a dataframe without missing values
tmp_df03 <- na.omit(tmp_df02)
head(tmp_df03)

ls()

#4 Data frame-to-array conversion(rectangular to raster)
# time an R process
ptm <- proc.time() # start the timer
# ... some code ...
proc.time() - ptm # how long?
# user  system elapsed for sandar
#0.022   0.004   0.364

# copy lon, lat and time from the initial netCDF data set
lon2 <- lon
lat2 <- lat
time2 <- time
tunits2 <- tunits
nlon2 <- nlon; nlat2 <- nlat; nt2 <- nt


ptm <- proc.time() # start the timer
# convert tmp_df02 back into an array
tmp_mat2 <- as.matrix(tmp_df02[3:(3+nt-1)])
dim(tmp_mat2)

# then reshape the array
tmp_array2 <- array(tmp_mat2, dim=c(nlon2,nlat2,nt))
dim(tmp_array2)

# convert mtwa, mtco and mat to arrays
mtwa_array2 <- array(tmp_df02$mtwa, dim=c(nlon2,nlat2))
dim(mtwa_array2)
## [1] 720 360
mtco_array2 <- array(tmp_df02$mtco, dim=c(nlon2,nlat2))
dim(mtco_array2)
## [1] 720 360
mat_array2 <- array(tmp_df02$mat, dim=c(nlon2,nlat2))
dim(mat_array2)
## [1] 720 360
proc.time() - ptm # how long?


# some plots to check creation of arrays
library(lattice)
library(RColorBrewer)

levelplot(tmp_array2[,,1] ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))), main="Mean July Temperature (C)")
levelplot(mtwa_array2 ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))), main="MTWA (C)")
levelplot(mtco_array2 ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))), main="MTCO (C)")
levelplot(mat_array2 ~ lon * lat, data=grid, at=cutpts, cuts=11, pretty=T, 
          col.regions=(rev(brewer.pal(10,"RdBu"))), main="MAT (C)")
#mean temperature of the coldest month (MTCO) and
#mean temperature of the warmest month (MTWA)

library(raster)
inputfile <- "/Users/sandar/Desktop/Climate test/cru10min30_tmp.nc"

# Grab the lat and lon from the data
lat <- raster(inputfile, varname="tmp")
lon <- raster(inputfile, varname="time_bounds")

# Convert to points and match the lat and lons
plat <- rasterToPoints(lat)
plon <- rasterToPoints(lon)
lonlat <- cbind(plon[,3], plat[,3])

# Specify the lonlat as spatial points with projection as long/lat
lonlat <- SpatialPoints(lonlat, proj4string = CRS("+proj=longlat +datum=WGS84"))

# Need the rgdal package to project it to the original coordinate system
library("rgdal")

# My best guess at the proj4 string from the information given
mycrs <- CRS("+proj=lcc +lat_1=35 +lat_2=51 +lat_0=39 +lon_0=14 +k=0.684241 +units=m +datum=WGS84 +no_defs")
plonlat <- spTransform(lonlat, CRSobj = mycrs)
# Take a look
plonlat
extent(plonlat)

# Yay! Now we can properly set the coordinate information for the raster
pr <- raster(inputfile, varname="pr")
# Fix the projection and extent
projection(pr) <- mycrs
extent(pr) <- extent(plonlat)
# Take a look
pr
plot(pr)

# Project to long lat grid
r <- projectRaster(pr, crs=CRS("+proj=longlat +datum=WGS84"))
# Take a look
r
plot(r)
# Add contours
contour(r, add=TRUE)

# Add country lines
library("maps")
map(add=TRUE, col="blue")