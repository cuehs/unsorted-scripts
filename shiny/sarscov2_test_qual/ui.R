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
library("devtools")

# sets up a ui object
ui <- fluidPage(
  titlePanel('Wie gut ist ein SARS-CoV-2 Testresultat?'),
  
  sidebarPanel(
    
    numericInput(inputId = "prev", 
               value = 100, min = 0, max = 100000,
               label = "Wieviele von 100,000 Menschen sind tatsächlich mit dem Coronavirus infiziert? (Prävalenz)"
              ),
    
    p("Sensitivität: Bei wieviel % der Infizierten wird die Infektion erkannt?"),
    
    sliderInput(inputId = "sens",
                label = "Sensitivität (in %)",
                value = 99.9, min = 0, max = 100, step = 0.1),
    
    p("Spezifität: Bei wieviel % der Nicht-Infizierten wird die Infektion ausgeschlossen?"),

    sliderInput(inputId = "spec",
                label = "Spezifität (in %)",
                value = 99.9, min = 0, max = 100, step = 0.1),
    
    submitButton(text = "Berechnen!")
    ),
    
    mainPanel(
      h4("Hinweise zur Nutzung des Tools"),
      p("Die Berechnungen des Tools können für PCR Tests und für Antigentests genutzt werden. Der",
        span(strong("PCR Test"), style = "color:darkgrey"),"gilt als Goldstandard mit einer Sensitivität und Spezifität von jeweils ca. 99.9%. Der", 
        span(strong("Antigentest"), style = "color:darkgrey"),"erreicht eine Sensitivität von 98% und eine Spezifität von 80%. Diese Werte hängen jedoch 
        stark von weiteren Variablen ab (Testzeitpunkt; Basisrate bzw. Prävalenz der Infektionen innerhalb der Getesteten)."),
      
      tabsetPanel(
        tabPanel("Tabellen",
                 tableOutput(outputId = "table1"),
                 h4("Kennzahlen"),
                 p(span(strong("Positiver Vorhersagewert:"), style = "color:green")," 
                   Eine Person hat ein positives Testergebnis. Wie wahrscheinlich ist sie tatsächlich infiziert?"),
                 p(span(strong("Negativer Vorhersagewert:"), style = "color:blue")," 
                   Eine Person hat ein negatives Testergebnis. Wie wahrscheinlich ist sie tatsächlich nicht infiziert?"),
                 tableOutput(outputId = "table2")),
        #tabPanel("Baumdiagramm")
        tabPanel("Baumdiagramm", 
                 grVizOutput(outputId = "tree", width = "100%", height = "300px"))
    )
  )
)
