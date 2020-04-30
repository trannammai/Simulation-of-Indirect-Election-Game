# Simulation of election game (programming in R)
## Presentation of the problem
The objective of this project is to check whether in a fictitious presidential election, all voters have the same influence on the result of the vote. The context is as follows: there are two candidates for the office of president: one candidate D and candidate R. The country is made up of 4 states which respectively contain n1 = n (where n is odd), n2 = 2n + 1, n3 = 3n and n4 = 5n voters.

The mechanism of the election is indirect: the voters will elect in states 1, 2, 3 and 4 respectively 1, 2, 3 and 5 electors representing party D or R. The president-elect will be the one with the largest number of major voters

Example: Assuming that n = 3
• in state 1, n1 = 3, there were 2 votes for D and 1 vote for R. D wins the election in state 1 and he therefore wins 1 large voter.
• in state 2, n2 = 2n + 1 = 7, there were 5 votes for D and 2 votes for R. D wins the election in state 1 and so it wins 2 big voters.
• in state 3, n3 = 3n = 9, there were 6 votes for D and 3 votes for R. D won the election in state 3 and he therefore wins 3 great voters.
• in state 4, n4 = 5n = 15, there were 7 votes for D and 8 votes for R. R wins the election in state 4 and so it wins 5 great voters.

In the end, D wins 1 + 2 + 3 = 6 voters, R has 5. D wins the election.
