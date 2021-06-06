#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("lumen"),
                
                # Application title
                titlePanel("Sales Forecasting for Retail Store Data"),
                
                # Sidebar with a slider input for number of bins 
                sidebarLayout(
                    sidebarPanel(
                        # Select date range to be plotted
                        dateRangeInput("moddate", strong("Date range"), start = "2013-01-01", end = "2015-06-30",
                                       min = "2013-01-01", max = "2015-06-30"),
                        
                        # Select type of trend to plot
                        selectInput(inputId = "select_shop", label = strong("Select Shop"),
                                    choices = c("All", shop_list),
                                    selected = "3")
                    ),
                    # Show a plot of the generated distribution
                    mainPanel(
                        tabsetPanel(type = "tabs", 
                                    tabPanel("Trend", br(),plotOutput(outputId = "plot1", height = "300px"),
                                             textOutput(outputId = "desc"),
                                             plotOutput(outputId = "plot2", height = "300px"),
                                             tags$a(href = "https://www.kaggle.com/c/competitive-data-science-predict-future-sales", "Source: Kaggle Predict Future Sales", target = "_blank")
                                    ),
                                    tabPanel("Time Series Decomposition", br(),plotOutput(outputId = "plot3", height = "600px"),
                                             tags$a(href = "https://www.kaggle.com/c/competitive-data-science-predict-future-sales", "Source: Kaggle Predict Future Sales", target = "_blank")
                                    ),
                                    tabPanel("Documentation", br(),textOutput(outputId = "desc1"),
                                             tags$a(href = "https://www.kaggle.com/c/competitive-data-science-predict-future-sales", "Source: Kaggle Predict Future Sales", target = "_blank")
                                    )
                                    
                        )
                    )
                )
)


