library(shiny)
library(networkD3)
library(shinydashboard)

shinyUI(fluidPage(
  tags$head(
  tags$style(paste('
        body{background-color: #FFFFFF !important}
        .nodetext{fill: #000000}
        .legend text{fill: #FF0000}
      '),
    HTML(".shiny-notification {
             position:fixed;
             top: calc(0%);
             left: calc(50%);
             }
             "), sep = ",")
    ), 
  shinyWidgets::useShinydashboard(),
  titlePanel("Wikipedia Network"), 
  fluidRow(
  box(htmlOutput("intro_text"),
      title = "Additional Info",
      collapsible = TRUE,
      collapsed = TRUE)),
  sidebarLayout(
    sidebarPanel(width = 3,
      textInput("wiki_word", "Wikipedia Word", "Statistics"),
      verbatimTextOutput("value"),
      fluidRow(
        column(width = 6,
      numericInput("input_num_links", 
                   #width = "50%",
                   min = 0,
                   label = "Max. links per page",
                   value = 50)),
      column(width =6,
      h6("Leave empty to obtain every link. Note that this may take several minutes."),
      )),
      hr(style = "border-top: 0px solid #000000;"),
      actionButton("go", "Create new network",
                   style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
      hr(style = "border-top: 1px solid #000000;"),
      h4("Graph specifications"),
      
        numericInput("input_min_connections", width = "50%",
                           #width = "50%",
                           min = 1,
                           label = "Min. connections",
                           value = 5),
      
               actionButton("refresh", "Refresh graph",
                            style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
      
          
        hr(style = "border-top: 1px solid #000000;"),
      h4("Summary Stats"),
      h6("(Create graph to display summary stats)"),
      htmlOutput("summary")
    ),
 
    
    mainPanel(
      fillPage(
        tags$style(type = "text/css", "#net {height: calc(100vh - 80px) !important;}"),
        forceNetworkOutput(outputId = "net")
      )
      
    )
  )))
