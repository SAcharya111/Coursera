#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Load Packages
library(shiny)
library(shinythemes)
library(dplyr)
library(readr)
library(ggplot2)
library(scales)
library(DT)
library(forecast)
library(fpp2)

#Load Files
items= read.csv("~/R/Coursera/Developing_data_products/week_4_assignment/Sales_time_series/item_list.csv", sep=",")
sales_train = read.csv("~/R/Coursera/Developing_data_products/week_4_assignment/Sales_time_series/sales_train.csv", sep=",")
shop_list= read.csv("~/R/Coursera/Developing_data_products/week_4_assignment/Sales_time_series/shops.csv", sep=",")

sales_train$rev = sales_train$item_price* sales_train$item_cnt_day
sales_train$yr = substr(sales_train$date, 7, 10)
sales_train$day = substr(sales_train$date, 1, 2)
sales_train$mon = substr(sales_train$date, 4, 5)
sales_train$moddate = as.Date(with(sales_train, paste(yr, mon, day,sep="-")), "%Y-%m-%d")






server <- function(input, output) {
    # Subset data
    
    
    selected_trends <- reactive({
        req(input$moddate)
        validate(need(!is.na(input$moddate[1]) & !is.na(input$moddate[2]), "Error: Please provide both a start and an end date."))
        validate(need(input$moddate[1] < input$moddate[2], "Error: Start date should be earlier than end date."))
        
        # Selection based on shops list
        if (input$select_shop=="All" ){
            shop_choice= shop_list
        } else {
            shop_choice=input$select_shop
        }
        sales_train1= sales_train %>%
            filter(shop_id %in% shop_choice, moddate > input$moddate[1] & moddate < input$moddate[2]) 
        
    })
    
    
    output$plot1 <- renderPlot({
        data<-selected_trends() %>% 
            group_by(date_block_num) %>%
            summarize(Revenue=sum(rev))
        
        color = "#434343"
        par(mar = c(4, 4, 1, 1))
        ggplot(data = data, aes(x=date_block_num, y=Revenue)) +
            geom_line() + labs(x = "Months", y = "Revenue(In Millions)") +  geom_smooth()+
            scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6)) + ggtitle('Sales By Shop')
    })
    
    
    output$plot2 <- renderPlot({
        data<-selected_trends() %>% 
            group_by(date_block_num) %>%
            summarize(Revenue=sum(rev))
        
        data <- ts(data["Revenue"], start = c(0, 1), frequency = 12)    
        ggseasonplot(data, year.labels=TRUE, continuous=TRUE) + labs(x = "Months", y = "Revenue(In Millions)") + ggtitle('Seasonal Trends of Sales by Shop') +
            scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6))
    })
    
    output$desc <- renderText({
        paste("The index is set to 0 on January 1, 2013 .")
    })
    
    output$plot3 <- renderPlot({
        data<-selected_trends() %>% 
            group_by(date_block_num) %>%
            summarize(Revenue=sum(rev))
        
        data <- ts(data["Revenue"], start = c(0, 1), frequency = 12)  
        data %>% decompose(type="multiplicative") %>%
            autoplot() + xlab("Year") + ggtitle("Classical multiplicative decomposition
    of Sales by Shop") + scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6))
        
    })
    
    output$desc1 <- renderText({
        ("This is a Sales Forecasting Exploratory Analysis App.
                This data is loaded from Kaggle. 
                Data Source: Predict Sales Data from Kaggle Database.
                Time Period: Jan 01, 2013 till June 30, 2015.
                Users can select start and end date of the data.
                Users can also select the shop for the deep-dive.
                The dataset had the following columns: Date, Date_block_column for each of the 
                months, Items, Shops, Item Price, Item Count.
                The data was organized as item-wise data sold for each of the shops on days during
                the time period.
                Sales Price was first determined from the item price and quantity sold.
                The date formats were changed to make that as an input by the user.
                In Tab1, first plot the objective is to showcase the trends of sales by each of the shops over time.
                Also, majority of the shops have seasonality behaviour, hence giving that view too.
                In Tab1, second plot will show seasonality behaviour.
                Lastly multiple decomposition, will decompose the time series data into trend and seasonality.
                ")
    })
    
    
    
}
