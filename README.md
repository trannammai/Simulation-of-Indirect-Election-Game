# Simulation of Indirect Election Game in R

This project simulates a fictitious presidential election to determine whether all voters have the same influence on the outcome. It includes an analysis of pivotal voters and an interactive visualization built using **RShiny**.

---

## Table of Contents
1. [Context](#context)
2. [Objectives](#objectives)
3. [Example Scenario](#example-scenario)
4. [Simulation Methodology](#simulation-methodology)
5. [Algorithm](#algorithm)
6. [Interactive Application](#interactive-application)
7. [References](#references)

---

## Context

An **indirect election** involves voters electing representatives (electors) who then vote to determine the winner.  
- Learn more about [indirect elections](https://en.wikipedia.org/wiki/Indirect_election).  
- Read about [pivotal electors](https://www.sciencedirect.com/science/article/pii/S0261379413000309).

The setup:
- Two candidates: **Candidate D** and **Candidate R**.
- Four states with the following distribution of voters and electors:

| **State** | **Number of Voters (nk)** | **Electors Representing the State** |
|-----------|---------------------------|-------------------------------------|
| State 1   | \( n_1 = n \)             | 1                                   |
| State 2   | \( n_2 = 2n + 1 \)        | 2                                   |
| State 3   | \( n_3 = 3n \)            | 3                                   |
| State 4   | \( n_4 = 5n \)            | 5                                   |

---

## Objectives

1. **Simulate the election game** to analyze the probability of being a pivotal voter in each state.
2. Build an **interactive RShiny app** to allow users to visualize and adjust the voting probabilities.

---

## Example Scenario

When \( n = 3 \):
- **State 1**: \( n_1 = 3 \), Votes: 2 for D, 1 for R → **D wins 1 elector**.
- **State 2**: \( n_2 = 7 \), Votes: 5 for D, 2 for R → **D wins 2 electors**.
- **State 3**: \( n_3 = 9 \), Votes: 6 for D, 3 for R → **D wins 3 electors**.
- **State 4**: \( n_4 = 15 \), Votes: 7 for D, 8 for R → **R wins 5 electors**.

**Final Tally**:
- Candidate D: \( 1 + 2 + 3 = 6 \) electors  
- Candidate R: \( 5 \) electors  

**Result**: Candidate **D wins the election**.

---

## Simulation Methodology

### Definition of a Pivotal Voter
A voter is pivotal if:
1. The state was won by the overall election winner.
2. The difference in votes between the winner and loser in the state is exactly 1.
3. Changing the winner's votes in the state flips the election result.

The number of pivotal voters in state \( k \) is given by:  
\[
\text{Pivotal voters in state } k = \frac{(n_k + 1)}{2}.
\]

### Voter Choice Models
1. **Case IC**: Each voter chooses a candidate using a Bernoulli distribution with \( p = 0.5 \).
2. **Case IAC**: Each voter chooses a candidate using a Bernoulli distribution with \( p_k \), where \( p_k \sim U(0, 1) \).

### Optimization
Instead of simulating individual voters:
- Use the binomial distribution to simulate the total number of votes for **Candidate D**:
  \[
  \text{Votes for D in state } k \sim \text{Binomial}(n_k, p_k)
  \]

---

## Algorithm

### Input Parameters
- `n`: Integer, determines the number of voters in state 1.
- `case`: String, specifies the simulation model (`IC` or `IAC`).
- `B`: Integer, number of replications.

### Steps
1. **Simulate Voter Choices**:  
   - Use `rbinom()` to simulate votes for **Candidate D** in each state.
2. **Determine the Winner**:  
   - Calculate the total number of electors for **Candidate D** and **Candidate R**.
3. **Calculate Pivotal Voters**:  
   - Identify pivotal voters for both cases where **D** wins and **R** wins.

---

## Interactive Application

The **RShiny app** allows users to:
- Adjust voter probabilities and parameters.
- Visualize the pivotal voter probabilities across states.

---

## Code Example

Here’s a snippet of the core simulation logic:

```r
simulate_election <- function(n, case, B) {
  results <- replicate(B, {
    # Simulate voter choices
    if (case == "IC") {
      p <- 0.5
    } else {
      p <- runif(4)  # Random probabilities for IAC case
    }
    votes <- sapply(c(n, 2*n+1, 3*n, 5*n), function(nk) rbinom(1, nk, p))
    
    # Determine winners and pivotal voters
    # Add logic for election result and pivotal voter calculation here
  })
  return(results)
}
