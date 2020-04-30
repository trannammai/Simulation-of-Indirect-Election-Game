# Recall shiny library
library(shiny)

# Define the user interface for the application which draws a Cleveland dot chart
shinyUI <- fluidPage(
   titlePanel("Excercice 4"),
   sidebarLayout(
      sidebarPanel(
        numericInput("n", "Parameter size n:", min = 5, step = 2, value = 5),
        selectInput("cas", "Probability model:", c("IC"="IC","IAC_star"="IAC_star")),
        textInput("gd_electeurs", "Vector of the number of electors", value = "1,1,2,2,3,4,5,10,15"), 
        numericInput("B", "Number of replications", min = 1000, max = 1000000, step = 1000, value = 100000)),
      mainPanel(plotOutput("distPlot"))))

# Define the server logic required to draw the Cleveland dot chart
shinyServer <- function(input, output) {
   output$distPlot <- renderPlot({
  
     # Create the process function
     processus <- function(cas, 
                           nb_state,
                           gd_electeurs,
                           pop_state) {
       
       # Convert gd_electors to numeric
       gd_electeurs <- as.numeric(unlist(strsplit(input$gd_electeurs,",")))
       
       # Initialize the number of pivots by states
       pivots <- numeric(nb_state)
       
       # Initialize the total number of electors
       nb_gd_electeurs <- sum(gd_electeurs)
       
       # Initialize the number of voters required to win  
       seuil_gd_electeurs <- (nb_gd_electeurs + 1)/2
       
       # Voter choice simulation
       vec_etat <- switch(cas, IC = rbinom(nb_state, pop_state, 0.5),
                          IAC_star = rbinom(nb_state, pop_state, 
                                            runif(nb_state)))
       
       # Winner of the election: the reference is Demo - Winner yes / no 
       # I count the number of big voters won by the Demo
       # At least threshold_gd_electors are required to win the election
       etat_gagnant <- vec_etat >= (pop_state + 1)/2
       elect_gagnants <- sum(etat_gagnant * gd_electeurs)
       winn_D <- elect_gagnants >= seuil_gd_electeurs
       
       # Look at the two situations:
       # Number of pivots when D won and number of pivots when R won
       for (i in 1:nb_state) {
         if((winn_D  &&                      # case D won
             (etat_gagnant[i] == winn_D) &&   # the state was won by the winner
             vec_etat[i] == (pop_state[i] + 1)/2 && # 1 vote apart
             elect_gagnants - gd_electeurs[i] < seuil_gd_electeurs) | # number of sufficent big voters
            ( !winn_D &&                       # case where R won with the same inverted conditions
              (etat_gagnant[i] == winn_D) &&  # the state was won by the winner
              (pop_state[i] - 1)/2 == vec_etat[i] && # 1 vote apart
              elect_gagnants + gd_electeurs[i] >= seuil_gd_electeurs) # number of sufficent big voters
         ) {
           pivots[i] <- (pop_state[i] + 1)/2
         }
       }
       return(pivots)
     }
  
     # Create the simul elec function
     simul_elec <- function(n, cas, B = 1000, gd_electeurs) {
       
       # Convert gd_electors to numeric
       gd_electeurs <- as.numeric(unlist(strsplit(input$gd_electeurs,",")))
       
       # Verify the result 
       stopifnot(n%%2 == 1, cas %in% c("IC", "IAC_star"))
       
       # Initialize the number of states
       nb_state <- length(gd_electeurs)
       
       # Initialize the number of voters by state
       # if a state contains a number of large odd gd voters we will do gd * n, otherwise gd * n + 1
       pop_state <- ifelse(gd_electeurs%%2 == 0, n * gd_electeurs + 1, n * gd_electeurs)
       
       # processus() function for the replication
       res_simul <- replicate(B, processus(cas = cas, 
                                           nb_state = nb_state, 
                                           gd_electeurs = gd_electeurs,
                                           pop_state = pop_state))
       
       # Return the results in the form data frame which has 2 columns:
       # First column is the probability of being pivotal
       # Second column is the names of the states
       # Third column is the identifying numbers of the states (in numeric)
       return(as.data.frame(list('Proba' = (rowMeans(res_simul)/pop_state), 'Etat_Nom' = paste('State',seq(1,length(gd_electeurs))), 'Etat_ID' = c(1:length(gd_electeurs)))))
     } 
     
     # Get the result of user input
     my_result <- simul_elec(input$n, input$cas, input$B, input$gd_electeurs)
     
     # Show the Cleveland dot chart
     require(ggplot2)
     ggplot(my_result,
            aes(x = my_result[,1],
                y = reorder(my_result[,2], my_result[,3]))) + geom_point() + xlab("Probability of being pivotal") + ylab("Number of ordered states")
   }) # Order the x-axis by the number identifying states (third column)
   # instead of the second column to guarantee the order if the user puts more than 10 number of gd_electors
}

#  Run the application directly
shinyApp(ui = shinyUI, server = shinyServer)
