# NCD Insurance Profitability

## Overview

This project delves into the profitability and design of a **No-Claim-Discount (NCD) car insurance scheme** for Skippie Insurance. It addresses the critical issue of the scheme's low-profit margin and its long-term viability by evaluating the current design, projecting future financial outcomes, and proposing actionable improvements. The analysis was developed within the context of the ACTL2102 Foundations of Actuarial Models / ACTL5103 Stochastic Modeling for Actuaries university course.

For more project information, visit this [project web page](https://quenstance.pages.dev/projects/ncd-insurance-profitability/).

---

## How to Use

To replicate the analysis and run the R code, follow these steps:

### Prerequisites

* **R statistical software:** Ensure R is installed on your system.

* **Required R packages:**

    * `markovchain`

    * `igraph`

    * `ggplot2`

    You can install these packages within R using:
    ```R
    install.packages("markovchain")
    install.packages("igraph")
    install.packages("ggplot2")
    ```

## Installation and Configuration

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/quenstance/2019_NCD_Insurance_Profitability_Analysis.git](https://github.com/quenstance/2019_NCD_Insurance_Profitability_Analysis.git)
    cd 2019_NCD_Insurance_Profitability_Analysis
    ```

2.  **Place data file:** Ensure `claimsdata.csv` is in your working directory or adjust the `setwd()` command in the R script to point to its location.

## Running the Project

1.  **Open the R script:** Open the `ACTL2102_RCode.R` file (or its equivalent if named differently) in an R environment (e.g., RStudio).

2.  **Execute the code:** Run the script line by line or entirely to perform the analysis. The script will:

    * Load necessary data and packages.

    * Estimate the Markov chain transition matrix.

    * Perform Monte Carlo simulations for 2020 premiums.

    * Calculate profitability for 2018, 2019, and the long run.

    * Generate and export several plots (e.g., transition matrix, premium histograms, profitability projections) to the working directory.

---

## Methodology

The project modeled the NCD scheme using **discrete-time stationary Markov chains** to trace policyholder transitions across five discount levels (-2, -1, 0, 1, 2). The **probability transition matrix** ($P$) was carefully estimated using the **Maximum Likelihood Estimation (MLE)** method, specifically following the well-established framework by Anderson and Goodman (1957). This estimation was based on historical claims data from 2018 to 2019.

To forecast the total expected premium for 2020, the project conducted a **Monte Carlo simulation** with 1,000 iterations. This process involved simulating NCD states for each policyholder, which then allowed for the calculation of their expected premiums based on assigned discount levels. These individual premiums were then aggregated to project the total portfolio premium.

Profitability was comprehensively assessed across three key timeframes:

* **2018:** Utilizing historical data.

* **2019:** Employing the simulated data.

* **Long-Run:** Determined by deriving the **limiting probabilities** from the Markov chain, after establishing its ergodicity and irreducibility to confirm the existence of these long-term probabilities.

For an in-depth explanation of the mathematical calculations, functions, and design philosophy, please refer to the [TECHNICAL.md](https://github.com/quenstance/2019_ACTL2102_NCD_Insurance_Profitability/blob/474caf832ef90bcb3fa49a47d273679de91ae215/TECHNICAL.md) file.

---

## Key Findings

The analysis identified significant concerns regarding the financial health of Skippie Insurance's NCD scheme:

* **Low Profit Margin:** The scheme demonstrated a very narrow profit margin of **3.88% in 2018**, indicating high exposure to risk.

* **Tail Risk:** Despite a majority of individual policyholders being profitable, the aggregate portfolio showed susceptibility to substantial losses due to **tail risk events**.

* **Unsustainable Long-Run Profitability:** Long-term projections based on limiting probabilities revealed a consistent pattern of **negative profitability**, highlighting the unsustainability of the current scheme design.

* **Recommendations:** Proposed improvements include:

    * **Revised NCD Eligibility:** Introducing criteria such as minimum driving experience and age.

    * **Tiered Claimability:** Restricting full claim payouts based on fault and claim type to control claim costs.

    * **Adjusted Discount Ratings:** Modifying the NCD level adjustments following claims.

---

## Limitations

The project's scope faced several constraints:

* **Ceteris Paribus Assumption:** When evaluating updated discount ratings, the analysis assumed *ceteris paribus*, meaning other factors like claim costs and standard premiums remained constant. In reality, these variables are dynamic.

* **Limited Historical Data:** The analysis relied on historical claims and NCD levels exclusively from 2018 and 2019.

* **Simulation Parameters:** The 2020 expected premium simulations presumed a stable policyholder base where all existing clients renewed and no new clients entered the scheme.

* **Simplified Long-Run Assumptions:** Long-run profitability assessments used simplified assumptions for maximum and minimum claimable claims, treating policyholders within a given state as acting in unison.



## Last Update: Jul 2019

Disclaimer: This project was developed using technologies and methods prevalent back then. Users are advised to review and update the code for compatibility with current R versions and package dependencies.

---

## Author

**Quenstance Lau**

* **Web Portfolio:** <https://quenstance.pages.dev/>

* **LinkedIn:** <https://www.linkedin.com/in/quenstance/>

* **GitHub:** <https://github.com/quenstance>
