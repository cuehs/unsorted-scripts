# General comments

# Tutorial:
# https://shiny.rstudio.com/tutorial/

# Needs a computer to run the R session in the back
# Currently, this is the (our/my) local machine
# Eventually, we want a server to host this (if this should be accessible to all)

# Inputs: Sensitivity, specificity, prevalence
# Outputs: Plots, tables, text

library("shiny")
library("tidyverse")
library("rsconnect")
library("DiagrammeR")

# library("Graphviz") instead: https://rdrr.io/cran/ndtv/man/install.graphviz.html
# custom labels: https://bookdown.org/yihui/rmarkdown-cookbook/diagrams.html

# sets up a server object
# use the server function to assemble inputs into outputs
 
server <- function(input,output) {
  input <<- input 

  
  output$table1 <- renderTable({ 
    populationSize <<- 100000
    
    richtig_positiv <<- round(input$prev*(input$sens/100), digits = 0)
    falsch_negativ <<- input$prev - richtig_positiv
    
    nicht_infiziert <<- populationSize - input$prev
    richtig_negativ <<- round(nicht_infiziert*(input$spec/100), digits = 0)
    falsch_positiv <<- nicht_infiziert - richtig_negativ

    
    results <- tibble(
      Status = c("infiziert", "infiziert", "nicht infiziert", "nicht infiziert"),
      Test = c("richtig positiv", "falsch negativ", "richtig negativ", "falsch positiv"),
      Anzahl = c(richtig_positiv,falsch_negativ,richtig_negativ,falsch_positiv) 
    )
    
    data.frame(results) 
  }, rownames = T)
  
  output$table2 <- renderTable({ 
    
    # populationSize <- 100000
    
    richtig_positiv <- round(input$prev*(input$sens/100), digits = 0)
    falsch_negativ <- input$prev - richtig_positiv
    
    nicht_infiziert <- 100000 - input$prev
    richtig_negativ <- round(nicht_infiziert*(input$spec/100), digits = 0)
    falsch_positiv <- nicht_infiziert - richtig_negativ
    
    ppV <- round((richtig_positiv / (richtig_positiv + falsch_positiv))*100, digits = 0)
    npV <- round((richtig_negativ / (richtig_negativ + falsch_negativ))*100, digits = 0)
    
    predvals <- tibble(
      Kennzahl = c("Positiver Vorhersagewert","Negativer Vorhersagewert"),
      Wert = c(ppV,npV) 
    )
    
    data.frame(predvals) 
  }, rownames = T)
  
  # create tree diagram
  output$tree <- renderGrViz({
    
    populationSize <<- 100000
    
    richtig_positiv <<- round(input$prev*(input$sens/100), digits = 0)
    falsch_negativ <<- input$prev - richtig_positiv
    
    nicht_infiziert <<- populationSize - input$prev
    richtig_negativ <<- round(nicht_infiziert*(input$spec/100), digits = 0)
    falsch_positiv <<- nicht_infiziert - richtig_negativ
    
      # this is in Graphviz DOT language
      # colors etc. https://cran.r-project.org/web/packages/DiagrammeR/vignettes/graphviz-mermaid.html
      grViz("

          digraph boxes_and_circles {
          
          # add node node definitions with substituted label text
          
          node [shape = box]
          '100,000 Menschen' [label = '@@1']; 
          'infiziert' [label = '@@2']; 'nicht infiziert' [label = '@@3']; 
          'richtig positiv' [label = '@@4']; 'falsch negativ' [label = '@@5'];
          'richtig negativ' [label = '@@6']; 'falsch positiv' [label = '@@7']
          '100,000 Menschen'; 
          'infiziert'; 'nicht infiziert'; 
          'richtig positiv'; 'falsch negativ';
          'richtig negativ'; 'falsch positiv'
          
          # add edge statements
          '100,000 Menschen' -> 'infiziert'; '100,000 Menschen' -> 'nicht infiziert';
          infiziert -> 'richtig positiv'; infiziert -> 'falsch negativ';
          'nicht infiziert' -> 'richtig negativ'; 'nicht infiziert' -> 'falsch positiv'
          }

          [1]: paste('Tests:', format(populationSize,digits = 3, big.mark=',', scientific = FALSE) )
          [2]:  paste('infiziert:', format(input$prev,digits = 3, big.mark=',', scientific = FALSE))
          [3]:  paste('nicht infiziert:', format(populationSize - input$prev,digits = 3, big.mark=',', scientific = FALSE))
          [4]:  paste('richtig positiv:',  format(richtig_positiv,digits = 3, big.mark=',', scientific = FALSE) )
          [5]:  paste('falsch negativ:', format(falsch_negativ,digits = 3, big.mark=',', scientific = FALSE))
          [6]:  paste('richtig negativ:', format(richtig_negativ,digits = 3, big.mark=',', scientific = FALSE))
          [7]:  paste('falsch positiv:', format(falsch_positiv,digits = 3, big.mark=',', scientific = FALSE))
        
        ")
      
      }
  )
}

