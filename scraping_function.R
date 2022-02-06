library(dplyr)
library(rvest)

# URL from where the dat should be sourced. 
# If exhanged with another similar website, some of the cleaning steps
# will have to be adjusted
main = "https://en.wikipedia.org/wiki/"

# function to obtain the basic links 
get_links <- function(x) {
  url <- paste0(main,x) 
  html_data <- tryCatch(read_html(url), error = function(e) return())
 
  
  if (!is.null(html_data)) {
    # "p a" will select only the blue links of the wikipedia page
    blue_links <- html_data %>% 
      html_nodes("p a") 
    if(length(blue_links) == 0) {
      print(paste("wiki page for", x,"does not exist"))
    } else {
    
    # header of the wikipedia page
    header <- html_data %>% 
      html_nodes("#firstHeading") %>%
      html_text()
    
    # obtain Target names
    Target <- blue_links %>%
      html_text() %>%
      tolower()
    
    # obtain URL from the bluelinks
    URL <- blue_links %>%
      html_attr('href')
    
    # combine name, URL and source of bluelinks
    url_df <- data.frame(Source = tolower(header),
                         Target, 
                         URL) %>%
      filter(str_detect(URL,"/wiki")) %>%
      filter(!str_detect(URL, "/wiki/Wikipedia")) %>%
      unique() %>%
      mutate(URL = str_remove(URL, "/wiki/")) %>%
      filter(!str_detect(URL, "help"))
    
    return(url_df)
    }
  }
  else {
    # error handling for blue links that do not have a wikipedia page with the same as the text of the bluelink
    print(paste("wiki page for", x,"does not exist"))
  }
}

