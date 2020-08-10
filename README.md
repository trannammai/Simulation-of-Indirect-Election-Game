# Simulation of election game
This individual project is carried out during my senior year of the MSc. Statistics and Econometrics. The objective is to check whether in a fictitious presidential election, all voters have the same influence on the result of the vote. More specifically, I aimed to:
1. Simulate the indirect election game and observe the probability of being pivotal voter of a voter within a state. 
2. Visualize the result in an interactive application where users can adjust their choices of vote for the elector.
The programming language used in this project is R and the application is built on RShiny

For more details:
1. Indirect election: https://en.wikipedia.org/wiki/Indirect_election
2. Pivotal elector: https://www.sciencedirect.com/science/article/pii/S0261379413000309

## Context
Supposingly, there are two candidates for the office of president: one candidate D and candidate R. The country is made up of 4 states which respectively contain n1 = n (where n is odd), n2 = 2n + 1, n3 = 3n and n4 = 5n voters.

As mentioned above, the mechanism of the election is indirect, which means that the voters will elect in states 1, 2, 3 and 4 respectively 1, 2, 3 and 5 electors representing party D or R. The president-elect will be the one with the largest number of major voters.

For example: Assuming that n = 3
• in state 1, n1 = 3, there were 2 votes for D and 1 vote for R. D wins the election in state 1 and he therefore wins 1 large voter.
• in state 2, n2 = 2n + 1 = 7, there were 5 votes for D and 2 votes for R. D wins the election in state 1 and so it wins 2 big voters.
• in state 3, n3 = 3n = 9, there were 6 votes for D and 3 votes for R. D won the election in state 3 and he therefore wins 3 great voters.
• in state 4, n4 = 5n = 15, there were 7 votes for D and 8 votes for R. R wins the election in state 4 and so it wins 5 great voters.
In the end, D wins 1 + 2 + 3 = 6 voters, R has 5. D wins the election.

I will focus here on the probability that an elector belonging to a certain state is pivotal. By definition, a voter is said to be pivotal if by changing his vote, he also changes the result of the election and a pivotal voter is one who necessarily voted for the winner. 

## Consequence for the algorithm: 

Taking into account all details of the simulation, I come up with a first thought on the algorithm:

To be considered as the pivotal within a state, all of the following conditions must be met:
• the state was won by the winner of the election (1)
• the difference in votes between the winner and the loser in the state is equal to 1 (2)
• the number of electors in the state is large enough for a change of camp to tip the election (3)

If all three conditions are met, the number of pivot in state k will be equal to (nk + 1) / 2.

Regarding the choice of voters, there are two possible cases:
• case IC: a voter of the country chooses his candidate according to a Bernoulli of parameter p = 1/2
• case IAC: in each state k (k = 1, ..., 4), an elector chooses his candidate according to a Bernoulli of pk parameter, where each pk is simulated according to a Uniform law [0,1].

Please note that I am more interested in knowing the number of voters who voted D or R inside of a state. Thus, rather than simulating in each state nk Bernoulli, I can directly simulate the number of people who voted for D using a Binomial parameter (nk, pk) (rbinom () function) where pk depends on the above model.

Hence, I create a function, having as input arguments an integer n corresponding to the value of n defined above, a case character string which gives the simulation model of the choice of an elector and an integer B which gives the number of replications. Inside the function, I will replicate B times the following simulation process:
• simulate, as appropriate, the choice of voters in each state. The objective is therefore to obtain a vector size 4 (one value per state), containing the number of people who voted for one of the two candidate, let's choose D for example, within each state. It will be a question of properly setting the function rbinom ().
• determine the winner of the election. Here, I always choose D as a reference, in other words we see whether or not D won the election.
• calculate the number of voters who are pivotal in each state (care must be taken to consider the case where D is the winner and the “symmetrical” case where R is the winner).
