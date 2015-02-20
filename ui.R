library(shiny)

# define UI
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Graduates by Field of Study and Country")
  ,p("This shiny app offers a view into the number of graduates by field of study and compared to the number
     of Young Adults (ages 20 - 40) in each country.  Source: OECD")
  ,p("Documentation: Select one or more fields of study and a range of years. The first graph is a GoogleVis
     motion chart showing Graduates vs. Young Adults by Country over time.  Roll over a bubble to see more detail"
     ,style = "color:darkblue"
     )
  ,p("The second graph shows the countries with the highest number of graduates for every 1000 young adults. 
     Poland stands out as the country with most total graduates"
     ,style = "color:darkblue"
     )
  ,sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("fos"
                         ,label = h3("Select Field of Study") 
                         ,choices = c("Architecture" = "1"
                                     ,"Business and Admin" = "2"
                                     ,"Computing" = "3"
                                     ,"Education" = "4"
                                     ,"Engineering" = "5"
                                     ,"Environmental Protection" = "6"
                                     ,"Health and Welfare" = "7"
                                     ,"Humanities and Arts" = "8"
                                     ,"Journalism and information" = "9"
                                     ,"Law" = "10"
                                     ,"Mathematics and statistics" = "11"
                                     ,"Social and Behavioural Science" = "12"
                                      )
                         ,selected = c("1","2", "3", "4", "5", "6"
                                       ,"7", "8", "9", "10", "11", "12"
                                       )
                         )
      ,sliderInput("year"
                  ,label = h3("Select Range of Years")
                  ,min = 1998
                  ,max = 2012
                  ,value = c(2000, 2012)
                  ,sep = ""
                  ,step = 1
                  ,round = TRUE
                  ,ticks = TRUE
                  )
      )
    ,mainPanel(
            tabsetPanel(
              position = "right"
              ,tabPanel("Graduates vs. Young Adults"
                        ,htmlOutput("gradcoplot"))
              ,tabPanel("Graduates for every 1000 Young Adults"
                        ,plotOutput("gradfosplot")
              )
            )
    )
    )
)
)