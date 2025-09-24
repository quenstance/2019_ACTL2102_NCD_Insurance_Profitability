# Technical Details: NCD Insurance Profitability

This document expands on the technical methodology employed in the No-Claim-Discount (NCD) insurance scheme analysis, detailing the mathematical underpinnings and specific R functions used.

## 1. Markov Chain Modeling

The NCD scheme is modeled as a **discrete-time stationary Markov chain** $X_n$ with a finite state space $S = \{-2, -1, 0, 1, 2\}$, where each state corresponds to a specific discount level. The Markov property dictates that the future state depends only on the current state, not on the sequence of events that preceded it. Stationarity implies that the transition probabilities do not change over time.

### 1.1. Probability Transition Matrix Estimation

The one-step **probability transition matrix** $P = [p_{i,j}]$ is estimated using **Maximum Likelihood Estimation (MLE)**. Following Anderson and Goodman (1957), the MLE of $p_{i,j}$ (the probability of moving from state $i$ to state $j$) is given by:

$$\hat{p}_{i,j} = \frac{n_{i,j}}{n_i^*}$$

where:

* $n_{i,j}$ is the observed number of policyholders who transitioned from state $i$ in year $t$ to state $j$ in year $t+1$.

* $n_i^* = \sum_{j \in S} n_{i,j}$ is the total number of policyholders who were in state $i$ in year $t$.

This estimation is implemented in R using a custom function `pij(i,j)` that counts transitions from `claimsdata$ncdlevel18 == i` to `claimsdata$ncdlevel19 == j` and divides by the total `claimsdata$ncdlevel18 == i`. The `outer()` function in R is then used to construct the full $P$ matrix.

**R Code Snippet:**
  ```R
  pij <- function(i, j) {
    sum(claimsdata$ncdlevel18 == i & claimsdata$ncdlevel19 == j) / sum(claimsdata$ncdlevel18 == i)
  }

  i <- -2:2; names(i) <- i
  j <- -2:2; names(j) <- j

  P <- outer(i, j, Vectorize(pij))
  round(P, 4) # Prints the transition matrix
  ```

The standard errors (SE) of the MLEs are also calculated using:
  $$
  SE(\hat{p}_{i,j}) = \frac{\sqrt{n_{i,j}}}{n_i^*}
  $$


**R Code Snippet for SE:**
  ``` R
  SEij <- function(i, j) {
    (sqrt(sum(claimsdata$ncdlevel18 == i & claimsdata$ncdlevel19 == j))) / sum(claimsdata$ncdlevel18 == i)
  }
  SE_ij <- outer(i, j, Vectorize(SEij))
  round(SE_ij, 4)
  The markovchain package is then used to create a Markov chain object:
  ```

  The `markovchain` package is then used to create a Markov chain object:

  ``` 
  library(markovchain)
  NCD <- new("markovchain", states = c(as.character(-2:2)), transitionMatrix = P)
  ```


### 1.2. Markov Chain Properties

To understand the long-term behavior of the scheme, the properties of the Markov chain `NCD` are analyzed:

* **Irreducibility:** Checked by examining the connectivity of states. If all states communicate (i.e., it's possible to get from any state to any other state), the chain is irreducible. The graphical representation (`NCD.igraph <- as(NCD, "igraph"); plot(NCD.igraph)`) confirms that all states form a single communicating class.

* **Periodicity:** The `period(NCD)` function is used to determine the period. A period of 1 indicates aperiodicity.

* **Ergodicity:** Since the chain is found to be irreducible, aperiodic, and positive recurrent (due to its finite state space), it is ergodic. This guarantees the existence of **limiting probabilities**.

## 2. Monte Carlo Simulation for 2020 Expected Premiums

To project the total expected premium for 2020, a **Monte Carlo simulation** with 1,000 iterations is performed. This approach leverages the Law of Large Numbers, where the average of a large number of simulated outcomes approximates the true expected value.

The simulation process for each of the 10,000 policyholders over 1,000 runs involves:

1.  **Simulating NCD states:** The `rmarkovchain(n=1, object=NCD, t0=claimsdata[i,5])` function is used to simulate the next NCD level (state) for each policyholder based on their 2019 NCD level (`ncdlevel19`) and the estimated transition matrix `NCD`.

2.  **Matching discounts:** Each simulated NCD state is mapped to its corresponding discount percentage using a lookup table (`DiscountAwarded`).

3.  **Calculating expected premium:** For each policyholder and simulation, the expected premium is calculated as `\$300 * (1 - Discount %)`.

4.  **Aggregating portfolio premium:** The individual expected premiums are summed across all 10,000 policyholders for each of the 1,000 simulations to get the `Portfolio Expected Premium 20perSim`.

5.  **Estimating total expected premium:** The mean of these 1,000 simulated portfolio premiums provides the `PortfolioExpectedPremium20`.

**R Code Snippet:**
  ``` 
  set.seed(1) # For reproducibility

  sim <- matrix(0, nrow(claimsdata), 1000)
  for (i in 1:nrow(claimsdata)) {
    sim[i,] <- as.numeric(replicate(1000, rmarkovchain(n = 1, object = NCD, t0 = claimsdata[i, 5])))
  }

  DiscountAwarded <- data.frame(States = c(-2:2), Discount = c(-0.20, -0.10, 0, 0.10, 0.20))

  ExpectedPremium20perSim <- sim
  ExpectedPremium20perSim[] <- 300 * (1 - DiscountAwarded$Discount[match(sim, DiscountAwarded$States)])

  PortfolioExpectedPremium20perSim <- colSums(ExpectedPremium20perSim)
  PortfolioExpectedPremium20 <- mean(PortfolioExpectedPremium20perSim)
  ```

## 3. Profitability Evaluation

### 3.1. 2018 Profitability

Profitability for 2018 is calculated using historical data:

* **Premium18:** `\$300 * (1 - DiscountAwarded$Discount[match(claimsdata$ncdlevel18, DiscountAwarded$States)])`

* **ClaimCost18:** `AverageClaimCost * Number_of_Claims_2018` (capped at 2 claims, where `AverageClaimCost = $2000`).

* **PL18 (Profit/Loss):** `Premium18 - ClaimCost18`
    The total `Portfolio Profitability18` is the sum of individual `PL18` values.

### 3.2. 2019 Profitability

For 2019, profitability is assessed across the 1,000 Monte Carlo simulations:

* **Premium19:** Calculated based on `claimsdata$ncdlevel19`.

* **ClaimableCost19:** The number of claims for each policyholder in each simulation is inferred from the transition between their `ncdlevel19` and the simulated `sim` (simulated `ncdlevel20`).

    * If `sim[r,c] >= claimsdata[r,5]` (state moved up or stayed same), `ClaimableCost19 = 0 * 2000`.

    * If `claimsdata[r,5] - sim[r,c] == 1` (state moved down by 1), `ClaimableCost19 = 1 * 2000`.

    * Else (state moved down by 2), `ClaimableCost19 = 2 * 2000`.

* **PL19:** `Premium19 - ClaimableCost19` for each policyholder and simulation.
    The `Portfolio Profitability19` for each simulation is the sum of individual `PL19` values.

### 3.3. Long-Run Profitability

The **limiting probabilities** (also known as stationary probabilities) $\pi = [\pi_{-2}, \pi_{-1}, \pi_0, \pi_1, \pi_2]$ are computed using `steadyStates(NCD)`. These probabilities represent the long-run proportion of time the Markov chain will spend in each state.

**R Code Snippet:**
  ```
  LimitingProb <- round(steadyStates(NCD), 4)
  # Output: [1,] 0.0013 0.0058 0.028 0.1305 0.8344  
  ```

Long-run profitability is then estimated based on these limiting probabilities and assumptions about maximum and minimum claimable claims for each state:

* `LRPremium = 10000 * LimitingProb * 300 * (1 - DiscountAwarded$Discount)`

* `LRNo.OfClaimsMax` and `LRNo.OfClaimsMin` are defined based on the number of claims required to transition between states.

* `LRClaimCostMax` and `LRClaimCostMin` are calculated using these claim numbers, `LimitingProb`, and `AverageClaimCost`.

* `LRProfitMax` and `LRProfitMin` are derived from these premium and claim cost estimates.

This provides a range of long-run profitability scenarios for the portfolio.

## 4. Profitability Improvement Recommendations

Recommendations are proposed to improve the NCD scheme's design and profitability based on the insights gained from the profitability analyses and an understanding of actuarial principles. These include:

* **NCD Eligibility Criteria:** Introducing policyholder-specific conditions (e.g., driving experience, age) to mitigate adverse selection.

* **Partial Claimability:** Differentiating claim payouts based on fault and claim type (e.g., at-fault, not-at-fault without third party, natural disasters) to control claim costs.

* **Revised NCD Rating Adjustments:** Modifying the reduction in NCD level for different claim events.

* **Discount Value Adjustments:** A sensitivity analysis is performed by reducing certain discount percentages (`Discount<-c(-0.20,0.10,0,0.01,0.02)` for states -2 to 2 respectively) to observe the impact on profitability. This confirms that adjusting discount levels can improve, but not fully resolve, the long-run negative profitability, indicating a need to also address underlying claim costs or standard premiums.