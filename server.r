# Define server logic required

server <- function(input, output, session) {
  
  #Home
  output$Auction_type = renderPlot({
    types = as.factor(allData$Type)
    types = droplevels(types, exclude = c("","0"))
    types = na.omit(types)
    pie(table(types), col = rainbow(2), main = "Auction types", labels = c("Buy", "Sell"))
  })
  output$Accessibility = renderPlot({
    pie(table(allData$`_auctionData_verejna_string`), col = rainbow(2), main = "Auction Accessibility", labels = c("Private","Public"))
  })
  
  output$Currency = renderPlot({
    currency = as.factor(allData$`_auctionData_mena_string`)
    currency = droplevels(currency, exclude = c("ks", "THB", "0", "GBP", "%", "AUD", "I", "RUB", "<NA>"))
    pie(table(currency), col = rainbow(7), main = "Most Used Currency")
  })
  output$Evaluation = renderPlot({
    evaluation_type = as.factor(allData$Evaluated_By)
    evaluation_type = droplevels(evaluation_type, exclude = c("", "2722195"))
    evaluation_type = na.omit(evaluation_type)
    pie(table(evaluation_type), col = rainbow(7), main = "Auction Evaluation by",labels = "")
    legend("bottomleft", legend = c("Pomocní výpočet - max", "Pomocní výpočet - min", "Celková nabítka účastníka", "Hodnocení", "Jednotlivé položky", "Multikriteriální hodnocení", "Skupiny položek" ),bty="n", fill = rainbow(7))
    
  })
  
  # Data
  output$allData = DT::renderDataTable({
    datatable(allData, rownames = F,options = list(scrollX = TRUE))
  })
  output$offersintime = DT::renderDataTable({
    datatable(offersInTime, rownames = F,options = list(scrollX = TRUE))
  })
  output$items = DT::renderDataTable({
    datatable(items, rownames = F,options = list(scrollX = TRUE))
  })
  
  # Auctions
  observeEvent(input$type,{
    typeObserver(input,session)
  })
  observeEvent(input$clarification,{ 
    clarificationObserver(input,session)
  })
  observeEvent(input$evaluation,{ 
    evaluationObserver(input,session)
  })
  
  observeEvent(input$auction,{ 
    output$auctions <- renderAuctionPlot(input,output,session)
  })
  
  #Bids progress 
  output$bids_plot <- renderPlot({
    subData2 = filter(offersInTime, Client == 100)
    subData2 = filter(subData2, Auction_ID == input$A_ID)
    subData2 = filter(subData2, Item_ID == input$I_ID)
    subData2$New_BID = as.integer(subData2$New_BID)
    ggplot(data = subData2, aes(x = subData2$Change_order, y = subData2$New_BID, colour = "red")) + geom_line() + theme_bw() + geom_point() + xlab("Number of bid") + ylab("Bid ammount") + theme(legend.position = "none")
  })
  
  output$bids_table <- renderDataTable({
    subData2 = filter(offersInTime, Client == 100)
    subData2 = filter(subData2, Auction_ID == input$A_ID)
    subData2 = filter(subData2, Item_ID == input$I_ID)
    subData2$New_BID = as.integer(subData2$New_BID)
    datatable(subData2, rownames = F,options = list(scrollX = TRUE))
  })
  # Items
  output$items_plot = renderPlot({
    data3 = filter(items, Klient == input$klient)
  })
  output$items_table <- renderDataTable({
    data3 = filter(items, Klient == input$klient)
    datatable(data3)
  })
  
  # Authors
  output$authors <- renderTable({
    read_excel(paste('tasks', ".xlsx", sep=""), 1)
  })
}




