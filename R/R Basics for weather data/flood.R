setwd("/Users/sandar/Desktop/Climate test/flood/")
#library(raster)
library(maptools)


library(rasterVis)

x <- brick('fl_risk_20170916091358_tiff/fl1010irmt.tif')
plot(x, axes=FALSE)

y<-raster('fl_risk_20170916091358_tiff/fl1010irmt.tif',crs=CRS('+proj=longlat'))

levelplot(x, margin=FALSE)
plot(y)
        
levelplot(x, margin=FALSE, col.regions=rainbow)

library(raster)
#p <- rasterToPolygons(x, dissolve=TRUE)



        map(add=TRUE, col="blue")
        library(leaflet)
        leaflet() %>% addTiles() %>%
          addRasterImage(x, colors = pal, opacity = 0.8) %>%
          addLegend(pal = pal, values = values(r),
                    title = "Surface temp")
        
        
        
        
        library(htmlwidgets)
        library(raster)
        library(leaflet)
        
        # PATHS TO INPUT / OUTPUT FILES
        projectPath = "/Users/sandar/Desktop/Climate test/flood/"
        #imgPath = paste(projectPath,"data/cea.tif", sep = "")
        #imgPath = paste(projectPath,"data/o41078a1.tif", sep = "") # bigger than standard max size (15431804 bytes is greater than maximum 4194304 bytes)
        imgPath = paste(projectPath,"fl_risk_20170916091358_tiff/fl1010irmt.tif", sep = "")
        outPath = paste(projectPath, "leaflethtmlgen.html", sep="")
        
        # load raster image file
        r <- raster(imgPath)
        crs(r) <- CRS("+init=epsg:4326")
        plot(r)
        
        library('rworldmap')
        mapCountryData( r, nameColumnToPlot="BIODIVERSITY" )
        
        # reproject the image, if necessary
        crs(r) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
        
        # color palette, which is interpolated ?
        pal <- colorNumeric(c("#000000", "#666666", "#FFFFFF"), values(r),
                            na.color = "transparent")
        
        # create the leaflet widget
        m <- leaflet() %>%
          addTiles() %>%
          addRasterImage(r, colors=pal, opacity = 0.9, maxBytes = 123123123) %>%
          addLegend(pal = pal, values = values(r), title = "Test")
        
        # save the generated widget to html
        # contains the leaflet widget AND the image.
        saveWidget(m, file = outPath, selfcontained = FALSE, libdir = 'leafletwidget_libs')
        
        library(rgdal)
        y <- readGDAL("fl_risk_20170916091358_tiff/fl1010irmt.tif")
        class(y)
        library(sp)
        spplot(y)
        
        library(plotKML)
        kml(x)
        x.kml<-kml_layer.Raster(x)
        plot(x.kml)
        e <- extent(x) 
        plot(e)
        # coerce to a SpatialPolygons object
        p <- as(e, 'SpatialPolygons')  
        
        data(eberg_grid)
        library(sp)
        coordinates(eberg_grid) <- ~x+y
        gridded(eberg_grid) <- TRUE
        proj4string(eberg_grid) <- CRS("+init=epsg:31467")
        data(SAGA_pal)
        library(raster)
        r <- raster(eberg_grid["TWISRT6"])
        ## Not run: # KML plot with a single raster:
        kml(r, colour_scale = SAGA_pal[[1]], colour = TWISRT6) 
        
        x <- r > -Inf
        # or alternatively
        # r <- reclassify(x, cbind(-Inf, Inf, 1))
        
        # convert to polygons (you need to have package 'rgeos' installed for this to work)
        pp <- rasterToPolygons(r, dissolve=TRUE)
        
        # look at the results
        plot(x)
        plot(p, lwd=5, border='red', add=TRUE)
        plot(pp, lwd=3, border='blue', add=TRUE)
        
        
        x <- brick('fl_physexp_20170916024155_tiff/fl1010ipeykx.tif')
        plot(x)
        spplot(x)
        library("maps")
        map(add=TRUE, col="blue")
        
        
        
        
        
        # FEMA's Hazus program 
        library(hazus)
        library(reshape2)
        library(ggplot2)
        
        data(haz_fl_dept) # depth-based DFs
        data(haz_fl_velo) # velocity and depth-based DFs
        data(haz_fl_agri) # agriculture DFs
        data(haz_fl_bridge) # DFs for bridges
        data(haz_fl_depr) # depreciation functions
        data(haz_fl_occ) # o
        
