library(knitr)
library(rvest)
library(gsubfn)
library(tidyr)
library(tmap)
library(shiny)
library(openxlsx)
library(readxl)
library(ggplot2)
library(rgdal)
library(rgeos)
library(mosaic)
library(maptools)
library(sf)

options(gsubfn.engine="R")

# Uvozimo funkcije za pobiranje in uvoz zemljevida.
source("lib/uvozi.zemljevid.r", encoding="UTF-8")
