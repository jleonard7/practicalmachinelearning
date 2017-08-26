library(shiny)
library(dplyr)
library(ggplot2)
library(caret)

shinyServer(function(input, output) {
  
  # Select only variables needed for regression model
  modLCS1 <- select(LifeCycleSavings, sr, pop15, ddpi)

  # First model with full ddpi
  model1 <- lm(sr ~ ddpi, data=modLCS1)
  
  reactMods <- reactive({
    
    modLCS2 <- select(LifeCycleSavings, sr, pop15, ddpi)
    perMiss <-input$sliderMiss/100
    selectNA <- rbinom(dim(modLCS2)[1],size=1,prob=perMiss)==1
    modLCS2$ddpi[selectNA] <- NA
    
    # Used to flag which variables changed
    modLCS2$Type <- ifelse(is.na(modLCS2$ddpi), "Imputed", "Actual")
    
    #modLCS2$ddpi[is.na(modLCS2$ddpi)] <- mean(modLCS2$ddpi, na.rm = TRUE)
    if (input$radio == 1)
    {
      
      # Mean
      modLCS2$ddpi[is.na(modLCS2$ddpi)] <- mean(modLCS2$ddpi, na.rm = TRUE)

    }
    
    else if (input$radio == 2)
    {
      # Max
      modLCS2$ddpi[is.na(modLCS2$ddpi)] <- max(modLCS2$ddpi, na.rm = TRUE)
    }
    
    else if (input$radio == 3)
    {
      # Min
      modLCS2$ddpi[is.na(modLCS2$ddpi)] <- min(modLCS2$ddpi, na.rm = TRUE)
    }
    
    else if (input$radio == 4)
    {
       # Min
       modLCS2$ddpi[is.na(modLCS2$ddpi)] <- median(modLCS2$ddpi, na.rm = TRUE)
    }
    model2 <- lm(sr ~ ddpi, data=modLCS2)
    
    summaryMod2 <- summary(model2)
    
    # To pass out multiple objects from reactive need to create list
    # as the final step in reactive function
    list(summaryMod2, modLCS2)
  })
  
  output$summary1 <- renderPrint({
    summary(modLCS1)
  })
  
  output$pred1 <- renderPrint({
    summary(model1)
    #modLCS1 <--- Pass a table out of reactive and stream back to screen for testing
  })
  output$pred2 <- renderPrint({
    reactMods()[1]
    #reactMods()[2]
  })
  

  output$plot1 <- renderPlot({
    
    qplot(ddpi,sr, data=modLCS1, xlab = "Change in DPI",
         ylab = "Savings Rate (Percent)F", main = "Plot of Original DDPI values")
  })
  output$plot2 <- renderPlot({
    
    modAsDF1 <- as.data.frame(reactMods()[2])

    modLCS1$Type <- ifelse(modAsDF1$Type=="Imputed", "Will be Imputed", "Actual")

    g1 <- ggplot(data=modLCS1, aes(x=ddpi, y=sr))
    
    g1 + geom_point(aes(color=Type)) + 
      labs(title = "Model Using Original", x = "Change in DPI", y = "Savings Rate (Percent)") +
      theme(legend.position="bottom") +
      geom_smooth(method = 'lm', formula = y ~ x)
      
  })
  output$plot3 <- renderPlot({
    
    modAsDF2 <- as.data.frame(reactMods()[2])
    
    g2 <- ggplot(data=modAsDF2, aes(x=ddpi, y=sr))
    
    g2 + geom_point(aes(color=Type)) + 
      labs(title = "Model Using Imputed", x = "Change in DPI", y = "Savings Rate (Percent)") +
      theme(legend.position="bottom") +
      geom_smooth(method = 'lm', formula = y ~ x)
  })
  
})