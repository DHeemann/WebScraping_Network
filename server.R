##### Server part of the R Shiny application #####


#### Loading packages ####
library(shiny)
library(networkD3)
library(htmltools)
library(htmlwidgets)
library(shinyWidgets)
library(igraph)
library(stringr)
library(dplyr)
library(rvest)

##### server function #####

shinyServer(function(input, output) {
  # sourcing the scraping script to retrieve the bluelinks #
  source("scraping_function.R") 
  source("create_d3_object.R")
  source("custom_js.R")
  
  # this is used in the collapsable info box
  output$intro_text <- renderUI({
    HTML('This is a personal web scraping project applied to Wikipedia articles.<br/><br/>
          Clicking on "Create new network" will retrieve every linked word in the the 
          main body of the wikipedia article. <br/>
          Next, the same process is repeated for every linked article 
          retrieved in the first step. <br/> <br/>
          Only those pages connecting to at least one of the articles mentioned on 
         the initial wikipedia page will be displayed. <br/> <br/>')
  })
  
  rv <- reactiveValues(
    value_store = character()
  )
  
  # will run if "Make new graph" is clicked
  observeEvent(input$go,{
    
    rv$value_store <- input$wiki_word
    url <- str_replace_all(rv$value_store, " ", "_") 
    df1 <- get_links(url)
    
    # if the wikipedia page cannot be found, 
    # this will check a different capitalization
    if (str_detect(df1[[1]][1], "does not exist")) {
      url <- gsub("(^.|_.)","\\U\\1",url,perl=TRUE)  
      df1 <- get_links(url)
    }

    # if the page can still not be found, we just show a pop-up message
    if (!str_detect(df1[[1]][1], "does not exist")) {
      
      # number of links that should be retrieved from the first wikipedia page
      num_pages <- if (is.na(input$input_num_links)){
        nrow(df1)
      } else {
        min(input$input_num_links, nrow(df1))
      }
        
    # The scraping process may take some time, so a progressbar is included
    withProgress(message = 'Creating the plot', value = 0, {
      df2.1 <- lapply(1:num_pages, function(i) {
        incProgress(1/num_pages, 
                    detail = paste("Scraping Wikipedia.", 
                                   round(i/num_pages*100),"%" ))
        return(get_links(df1$URL[i]))
        })
    })
    
    # used as input to create the d3 object
    scraped_data <- do.call(what=rbind, df2.1) %>% 
      rbind(df1)
    
    # run if graph speficiations are changed or a new graph is created
    observeEvent(input$refresh|input$go,{
      # create d3_object 
      d3_object <- create_d3_object(scraped_data, 
                                    min_links = input$input_min_connections)
      
      # create network graph
      output$net <- renderForceNetwork(
        onRender(forceNetwork(
          Links  = d3_object$links, Nodes = d3_object$nodes,
          zoom = TRUE,
          opacityNoHover = 0.5, fontSize = 15, Nodesize = 'size',
          Source = "source", Target  = "target",
          NodeID  = "name",
          linkDistance = 350,
          Group  = "group",  opacity = 1),customJS))
      
      output$summary <- renderUI({
        # summary KPI of pages accesses and number of nodes
        num_accessed <- n_distinct(scraped_data$Target)
        num_nodes <- n_distinct(d3_object$nodes$name)
        
        kpi1 <- paste('<span style="font-size: 25px;">',
              num_accessed,
              '</span> <span style="font-size: 15px;">accessed wiki pages</span>')
        kpi2 <- paste('<span style="font-size: 25px;">',
                      num_nodes,
                      '</span> <span style="font-size: 15px;">nodes in graph</span>')
        HTML(paste(kpi1,kpi2, sep = '<br/>'))
        
      })
      showNotification(ui = paste("Hover over nodes to highlight connections"),
                       type = "message", duration = 5)
    })
    } else {
    showNotification(ui = paste("There is no Wikipedia page for",  input$wiki_word),
                     type = "error")
    }
  })
})
