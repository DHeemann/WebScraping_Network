# Script to create the D3 object to be plotted in the Shiny application # 
library(dplyr)
library(stringr)


create_d3_object <- function(df2, min_links = 1) {
  # Args:
  # df2: data.frame containing the source and targets columns
  # min_links: Minimum number of times a node should be appearing as a target
  # Returns: d3_object
  # 
  # we omit all connections of links that do not link back to any other
  df3 <- df2[df2$Target %in% unique(df2$Source), ]
  df3 <- df3[complete.cases(df3), ]
  
  # cleaning target and source strings
  df3 <- df3 %>%
    mutate_all(~ str_replace_all(., "_", " ")) %>%
    mutate_all(~ str_to_title(.))
  
  # we want filter out all nodes that do not have at 
  # least min_links connections to them
  selected_links <- as.data.frame(table(df3$Target)) %>% 
    filter(Freq > min_links) %>% 
    pull(Var1) %>% 
    unique()
  
  df3 <- df3 %>% 
    filter(Target %in% selected_links, 
           Source %in% selected_links)
  
  # now we transform the data via igraph into the d3_object
  relations <- data.frame(from = df3$Source, 
                          to = df3$Target)
  
  actors <- data.frame(name = unique(c(as.character(df3$Source), as.character(df3$Target))))
  
  g <- graph_from_data_frame(relations, directed=TRUE, vertices=actors)
  
  wc <- cluster_walktrap(g)
  members <- membership(wc)
  d3_object <- igraph_to_networkD3(g, group = members)
  d3_object$nodes$size = degree(g)
  return(d3_object)
}
