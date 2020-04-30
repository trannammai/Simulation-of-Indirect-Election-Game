# Universite Toulouse 1 Capitole
# Master 2 - Statistiques et Econometrie
# Programmation R avancé
# Devoir 4 - Visualisation des données
# TRAN Nam Mai

# Appel de la libraire "shiny" 
library(shiny)

# On définit l'interface utilisateur pour l'application qui dessine un Cleveland dot chart
shinyUI <- fluidPage(
   titlePanel("Excercice 4"),
   sidebarLayout(
      sidebarPanel(
        numericInput("n", "Taille du paramètre n:", min = 5, step = 2, value = 5),
        selectInput("cas", "Modèle proba:", c("IC"="IC","IAC_star"="IAC_star")),
        textInput("gd_electeurs", "Vecteur du nombre de gd electeurs", value = "1,1,2,2,3,4,5,10,15"), 
        numericInput("B", "Nombre de réplications", min = 1000, max = 1000000, step = 1000, value = 100000)),
      mainPanel(plotOutput("distPlot"))))

# On définit la logique du serveur requise pour dessiner le Cleveland dot chart 
shinyServer <- function(input, output) {
   output$distPlot <- renderPlot({
  
     # On crée la fonction processus
     processus <- function(cas, 
                           nb_state,
                           gd_electeurs,
                           pop_state) {
       
       # convertir gd_electeurs en numeric
       gd_electeurs <- as.numeric(unlist(strsplit(input$gd_electeurs,",")))
       
       # initialisation : nombre de pivots par états
       pivots <- numeric(nb_state)
       
       # initialisation : nombre total de grands électeurs
       nb_gd_electeurs <- sum(gd_electeurs)
       
       # initialisation : nombre de grands électeurs necessaires pour gagner    
       seuil_gd_electeurs <- (nb_gd_electeurs + 1)/2
       
       # simulation du choix des électeurs 
       vec_etat <- switch(cas, IC = rbinom(nb_state, pop_state, 0.5),
                          IAC_star = rbinom(nb_state, pop_state, 
                                            runif(nb_state)))
       
       # vainqueur de l'élection : la référence est Demo - Winner oui/non 
       # on compte le nombre de grands électeurs gagnés par les Demo
       # il en faut au moins seuil_gd_electeurs pour remporter l'élection
       etat_gagnant <- vec_etat >= (pop_state + 1)/2
       elect_gagnants <- sum(etat_gagnant * gd_electeurs)
       winn_D <- elect_gagnants >= seuil_gd_electeurs
       
       # on regarde les deux situations :
       # Nombre de pivots quand D a gagné et nombre de pivots quand R a gagné
       for (i in 1:nb_state) {
         if((winn_D  &&                      # cas où D a gagné 
             (etat_gagnant[i] == winn_D) &&   # l'état a été gagné par le winner
             vec_etat[i] == (pop_state[i] + 1)/2 && # avec 1 voix d'écart
             elect_gagnants - gd_electeurs[i] < seuil_gd_electeurs) | # nombre de gd electeurs suffisament grands
            ( !winn_D &&                       # cas où R a gagné avec les mêmes conditions inversées
              (etat_gagnant[i] == winn_D) &&  # l'état a été gagné par le winner
              (pop_state[i] - 1)/2 == vec_etat[i] && # avec 1 voix d'écart
              elect_gagnants + gd_electeurs[i] >= seuil_gd_electeurs) # nombre de gd electeurs suffisament grands
         ) {
           pivots[i] <- (pop_state[i] + 1)/2
         }
       }
       return(pivots)
     }
  
     # On crée la fonction simul_elec
     simul_elec <- function(n, cas, B = 1000, gd_electeurs) {
       
       # on converti gd_electeurs en numeric
       gd_electeurs <- as.numeric(unlist(strsplit(input$gd_electeurs,",")))
       
       # verification 
       stopifnot(n%%2 == 1, cas %in% c("IC", "IAC_star"))
       
       # initialisation: nombre d etats
       nb_state <- length(gd_electeurs)
       
       # initialisation: nombre d electeurs par états
       # si un etat contient un nombre de grands electeurs gd impairs on fera gd * n, sinon gd * n +1
       pop_state <- ifelse(gd_electeurs%%2 == 0, n * gd_electeurs + 1, n * gd_electeurs)
       
       # réplication de la fonction processus()
       res_simul <- replicate(B, processus(cas = cas, 
                                           nb_state = nb_state, 
                                           gd_electeurs = gd_electeurs,
                                           pop_state = pop_state))
       
       # on retourne les résultats sous la forme data frame qui a 2 colonnes:
       # Premiere colonne est la probabilité d'être pivot
       # Deuxième colonne est les noms des états
       # Troisieme colonne est les numéros identifiants des états (en numeric)
       return(as.data.frame(list('Proba' = (rowMeans(res_simul)/pop_state), 'Etat_Nom' = paste('State',seq(1,length(gd_electeurs))), 'Etat_ID' = c(1:length(gd_electeurs)))))
     } 
     
     # on obtient le résultat de l'entrée de l'utilisateur
     my_result <- simul_elec(input$n, input$cas, input$B, input$gd_electeurs)
     
     # on représente le Cleveland dot chart
     require(ggplot2)
     ggplot(my_result,
            aes(x = my_result[,1],
                y = reorder(my_result[,2], my_result[,3]))) + geom_point() + xlab("Probabilité d'être pivot") + ylab("Numéro des états ordonnés")
   }) # On ordonné l'axe x par le nombre identifiant d'états (troisième colonne) 
   # au lieu de la deuxième colonne pour garantir l'ordre si l'utilisateur met plus de 10 nombre de gd_electeurs
}

# On peut exécuter directement l'application
shinyApp(ui = shinyUI, server = shinyServer)

