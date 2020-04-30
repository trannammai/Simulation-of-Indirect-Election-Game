# Create the function simul_elec()
simul_elec <- function(n,cas,B){

  # Check that the input arguments are adequate to the problem: n odd, case equal to "IC" or "IAC_star"
  stopifnot(n%%2 == 1, (cas == "IC" | cas == "IAC_star")) 
  
  # Create a table indicating the number of votes for D in each state, with the probability method inserted by the user of this function
  voix <- as.table(replicate(B, rbinom(4, c(n, 2*n + 1, 3*n, 5*n), prob = ifelse(cas == "IC", 0.5, runif(4)))))
  
  # Create a table showing the total number of votes in each state, replicate B times
  population <- as.table(replicate(B, c(n, 2*n + 1, 3*n, 5*n)))
  
  # Create a table indicating whether D has the major vote in each state
  majeur <- as.table(t(voix > population /2))
  
  # If D has the major vote in state X, X will represent its major voters who will vote for D during the national round.
  # So, I replace the large elector value by 1,2,3 and 5 respectively for states 1, 2, 3 and 4 if the D has more than half of the votes in each state  majeur[,1][which(majeur[,1] == TRUE)] = 1
  majeur[,2][which(majeur[,2] == TRUE)] = 2
  majeur[,3][which(majeur[,3] == TRUE)] = 3
  majeur[,4][which(majeur[,4] == TRUE)] = 5
  
  # Create a table indicating if D wins according to the indirect election mechanism (Yes = 1, No = 0)
  # This means that the number of grand voters voting for D should be more than half the total of the great voters in this country (11 being the total number of great voters in this country)  gagne <- ifelse(rowSums(majeur) > 11/2, 1, 0)
  gagne <- t(t(gagne))
  gagne <- as.table(cbind(gagne, gagne, gagne, gagne))
  
  # Create a table indicating if the difference in vote between D and the other candidate is equal to 1 (Yes = 1, No = 0)
  voix <- as.table(t(voix))
  voix[,1] <- ifelse(voix[,1] == (n + 1)/2, 1, 0)
  voix[,2] <- ifelse(voix[,2] == (2*n + 2)/2, 1, 0)
  voix[,3] <- ifelse(voix[,3] == (3*n + 1)/2, 1, 0)
  voix[,4] <- ifelse(voix[,4] == (5*n + 1)/2, 1, 0)
  
  # Create another table indicating the number of pivot electors according to the calculation formula
  majeur[,1][which(majeur[,1] == 1)] = (n + 1)/2
  majeur[,2][which(majeur[,2] == 2)] = (2*n + 2)/2
  majeur[,3][which(majeur[,3] == 3)] = (3*n + 1)/2
  majeur[,4][which(majeur[,4] == 5)] = (5*n + 1)/2
  
  # Calculate the probability of being a pivot voter 
  pivot <- (majeur*gagne*voix) / t(population)
  
  # The general algorithm conditions:
  # The state was won by the winner of the election: verified
  # The difference in voice between the winner and the loser in the state is equal to 1: verified
  # The number of large voters in the state is large enough for a change of camp to tip the election: verified
  
  # Give the means of probability to be a pivot voter
  colnames(pivot) <- c("etat_1", "etat_2", "etat_3", "etat_4")
  return(colMeans(pivot))
} 

# Take the following examples to verify that the function works well:
res_IC <- simul_elec(n = 5, cas = "IC", B = 100000)
res_IC; system.time(res_IC)

res_IAC_star <- simul_elec(n = 5, cas = "IAC_star", B = 100000)
res_IAC_star; system.time(res_IAC_star)

# Voters do not have the same impact on the election result depending on whether they are in 1,2,3, and 4 state because the probability that an elector belonging to it is pivotal is very small and different in one state of another.
# By trying n larger, we deduce that the probability that an elector is pivot converges to 0
# The speed of convergence towards 0 of res_IAC_star is faster than that of res_IC, which means that: The more rational in the vote, the less likely to have pivotal voters

res_IC_large <- simul_elec(n = 123456781, cas = "IC", B = 100000)
res_IC_large

res_IAC_star_large <- simul_elec(n = 123456781, cas = "IAC_star", B = 100000)
res_IAC_star_large
