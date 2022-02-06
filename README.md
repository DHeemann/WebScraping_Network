# Web scraping network chart 
R Shiny dashboard to scrape content from Wikipedia and show the connection (network) between different pages. 

The logic is as follows: 

1. Clicking on "**Create new network**" will retrieve every linked word (blue link) in the the main body of the specified wikipedia article 
2.  Next, the same process is repeated for every linked article retrieved in the first step.
3. In the background a data frame is created showing the source and target of all these links. 
4. Using networkD3, the connections are visualized in a graph. 
5. Only those pages connecting to at least one of the articles mentioned on the initial wikipedia page will be displayed.


<img width="972" alt="R shiny app" src="https://user-images.githubusercontent.com/36103689/152701971-9a59d80b-a367-496d-975d-2e2b8d2f8dae.png">
