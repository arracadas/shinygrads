# Developing Data Products
# Week 3 Project
# Create Shiny application
# Total Graduates by Country
# Source: OECD (OECD.StatExtracts)
# Created: Feb 17,2015

# setwd("~/Documents/cursos/JHU Data Prods/project")

# load libraries
library(shiny)
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(googleVis))

# load graduates by Field of Study data
# fields are Country, Year, FieldEducation, Graduates, Pop of YoungAdults
fs1 <- read.delim("./oecd_gradFS.txt"
                  ,stringsAsFactors = FALSE
                  ,na.strings = c("NA","")
                  ,header = TRUE
)

# load graduates and young adult population
# fields are Country, Year, Graduates, Pop of YoungAdults
y1 <- read.delim("./oecd_gradYA.txt"
                 ,stringsAsFactors = FALSE
                 ,na.strings = c("NA","")
                 ,header = TRUE
)

# create list of choices of field of study
foslist <- c("Architecture and building (ISC 58)"
             ,"Business and administration (ISC 34)"
             ,"Computing (ISC 48)"
             ,"Education (ISC 14)"
             ,"Engineering and engineering trades (ISC 52)"
             ,"Environmental protection (ISC 85)"
             ,"Health and welfare"
             ,"Humanities and Arts"
             ,"Journalism and information (ISC 32)"
             ,"Law (ISC 38)"
             ,"Mathematics and statistics (ISC 46)"
             ,"Social and behavioural science (ISC 31)"
)

# add factors
fs1$CountryCd <- factor(fs1$CountryCd)
fs1$FieldEducation <- factor(fs1$FieldEducation)

y1$CountryCd <- factor(y1$CountryCd)
y1$CountryName <- factor(y1$CountryName)


# create reactive output
shinyServer(function(input, output) {
  gradfos <- reactive({
    # subset firs data file graduates by field of study and country
    f <- foslist[as.numeric(input$fos)]  # list of selected fields of study
    yr <- seq(input$year[1]
              ,input$year[2]
              ,by = 1)  # range of selected years
    gradfos <- subset(fs1
                      ,FieldEducation %in% f & Year %in% yr
                      )
    
    # roll up data across range of selected years
    gradfos <- aggregate(. ~ CountryCd + CountryName + FieldEducation
                         ,data = gradfos[,c("CountryCd"
                                            ,"CountryName"
                                            ,"FieldEducation"
                                            ,"Graduates"
                                            ,"YoungAdults")]
                         ,FUN = mean)
    
    # calculate Graduates per 1000 Young Adults
    gradfos$GraduatesProportion <- round(gradfos$Graduates/gradfos$YoungAdults, 5)*1000
    
    # aggregate, rank countries based on GraduatesProportion and sort dataframe
    gradfosrank <- aggregate(. ~ CountryCd
                             ,data = gradfos[,c("CountryCd"
                                                ,"GraduatesProportion")]
                             ,FUN = sum)
    
    gradfosrank$Rank <- rank(gradfosrank$GraduatesProportion)
    
    gradfos <- merge(gradfos
                     ,gradfosrank[,c("CountryCd"
                                     ,"Rank")]
                     ,by = c("CountryCd")
                     )
    
    # sort CountryName acccording to Rank
    gradfos$CountryName <- factor(gradfos$CountryName
                                  ,levels = unique(gradfos[order(gradfos$Rank
                                                          ,decreasing = TRUE),]$CountryName)
    )
    
    return(gradfos)
  })
  
  gradco <- reactive({
    # subset second data file graduates by country
    yr <- seq(input$year[1]
              ,input$year[2]
              ,by = 1)  # range of selected years
    gradco <- subset(y1
                      ,Year %in% yr
                      )
    gradco
  })
  
  # create first reactive plot
  output$gradfosplot <- renderPlot({
    gp <- qplot(x = CountryName
                ,weight = GraduatesProportion
                ,data = gradfos()
                ,fill = FieldEducation
                ,geom = "bar"
                ,binwidth = 15
                ,main = "Count of Graduates per 1000 Young Adults"
                ,ylab = "Graduates"
                ,xlab = ""
    )
    gp <- gp + theme(axis.text.x = element_text(angle = 90
                                                ,hjust = 1)) + scale_y_continuous("GraduatesProportion")
    print(gp)
  })
  
  # create second reactive plot
  output$gradcoplot <- renderGvis({
    yp <- gvisMotionChart(gradco()
                          ,"CountryName"
                          ,"Year"
                          ,options=list(width=600
                                        ,height=400
                          )
    )
    return(yp)
  })
})
