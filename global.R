library(shiny)
library(shinyWidgets)
library(ggplot2)
library(gridExtra)
library(plotly)
library(dplyr)
library(DT)
library(qcc)
library(shinydashboard)



choice_property <- c('pct_c', 'gauge', 'rockwell', 'yield_strength_ksi', 'elong_%')

supplier_mill <- read.csv('./Data/Suppliers/Supplier_Mills_list.csv')

supplier_data <- read.csv("./Data/Suppliers/Supplier_4/data_20191013.csv", as.is = "temper", na.strings = c("", " ", "NA", "<NA>"))

mech_prop_specs <- read.csv("./Data/Specs/mech_prop_specs.csv",as.is = c('temper', 'anneal'))



supplier_data$prod_date <- as.Date(supplier_data$prod_date)

choice_gauge <- sort(unique(supplier_data$ordered_gauge))

choice_temper <- sort(unique(supplier_data$temper))

choice_supplier <- sort(unique(supplier_mill$Supplier ))

choice_mill <- sort(unique(supplier_mill$Mill))

choice_spec <- sort(unique(supplier_data$spec))

supplier_data$prod_date <- as.Date(supplier_data$prod_date)










