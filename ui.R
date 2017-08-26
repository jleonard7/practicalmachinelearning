library(shiny)

shinyUI(fluidPage(
  
  # Title
  titlePanel("Imputation Impacts on Model Building"),
  
  # Top Row on Page
  fluidRow(
    
    column(6,
           wellPanel(
             
             # Default value is 10, range is 5 to 20
             sliderInput("sliderMiss", label = h4("Set Percentage of Missing Data"), 5, 20, value = 10)
           ),
           
           fluidRow(
             column(12,
                    wellPanel(
                      radioButtons("radio", label = h4("Select Imputation Method"),
                                   choices = list("Mean" = 1, "Max" = 2, "Min" = 3, "Median" = 4),
                                   selected = 1),
                      submitButton("Submit")
                    )
             )
           )
    ), # Close first column of top row
    
    column(6,
              wellPanel("Summary of Original Dataset",
                        verbatimTextOutput("summary1"))
           ) #Close second column of top row
    ), # Close top row 

  
  # Bottom Row on Page
  fluidRow(
    
    column(6, 
      tabsetPanel(
      
        tabPanel("Model with Original Data",
                 verbatimTextOutput("pred1")),
        tabPanel("Model with Imputed Data",
                 verbatimTextOutput("pred2"))
        )
      ),
    column(6, 
           tabsetPanel(
             
             tabPanel("Plot of Original Data",
                      plotOutput("plot2")),
             tabPanel("Plot of Imputed Data",
                      plotOutput("plot3"))
           )
    )
    )
))