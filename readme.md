# Portfolio Genetic Optimization Algorithm

This repository contains the MATLAB implementation of a genetic algorithm to optimize stock portfolios based on their Sharpe Ratio. The algorithm employs evolutionary principles such as selection, recombination, and mutation to create and improve portfolios. 

## Project Overview

- **Topic**: Optimization Methods Project  
- **Author**: Luca Sanfilippo  
- **Date**: May 29, 2022  

The main goal of this project is to construct stock portfolios using NASDAQ-100 tickers, calculate their returns, and optimize the portfolio composition by maximizing the Sharpe Ratio through iterative simulations.

---

## Features

1. **Data Acquisition**: Fetch historical stock prices and benchmark data from Yahoo Finance.
2. **Portfolio Creation**: Randomly select stocks to form portfolios.
3. **Performance Evaluation**: Compute portfolio returns and Sharpe Ratios.
4. **Genetic Algorithm**: 
   - **Selection**: Retain top-performing portfolios.
   - **Recombination**: Swap stocks between portfolios to create new combinations.
   - **Mutation**: Replace a random stock in the portfolio with another.
5. **Visualization**: Generate cumulative return and portfolio value plots.

---

## Requirements

- MATLAB R2022a (or compatible version)
- Financial Toolbox for MATLAB (optional, but recommended)

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/PortfolioGeneticOptimization.git
   cd PortfolioGeneticOptimization
   ```

2. Ensure all the necessary functions and dependencies are loaded:
   - Confirm that the `getMarketDataViaYahoo` function is available for downloading historical stock data.
   - Place all required `.mat` files (e.g., `tableAdjPrices.mat`) in the working directory.

3. Verify the functions `getMarketDataViaYahoo` and any other required utility scripts are properly loaded and accessible in your MATLAB path. These functions are critical for fetching market data and ensuring the script runs correctly.

---
## How to Use

1. **Modify the list of stock tickers** (`NASDAQ100Tickers`) if needed. The default list includes the NASDAQ-100 companies.
2. **Run the script** `PortfolioGeneticOptimization.m` in MATLAB.
3. **Adjust key parameters**:
   - Number of stocks per portfolio
   - Number of portfolios
   - Number of simulations (`Nsim`)
4. **View the outputs**:
   - Portfolio statistics
   - Generated plots of cumulative returns and portfolio values in dollars

---

## Key Files

- **`PortfolioGeneticOptimization.m`**: Main script implementing the algorithm.
- **`tableAdjPrices.mat`**: Cached data of adjusted prices for the NASDAQ-100 stocks.
- **`PortfoliosValues.xlsx`**: Excel file with detailed results including Sharpe Ratios, portfolio compositions, and returns.

---

## Configuration Parameters

### Key Parameters in the Script

- **Start Date (`startDate`)**: Defines the start of the historical data period. Default is 3 years prior to the current date.
- **Number of Stocks per Portfolio (`numberStocksPortfolio`)**: The number of stocks in each portfolio. Default is 12.
- **Number of Portfolios (`numberPortfolios`)**: Number of portfolios to create during each iteration. Default is 5.
- **Number of Simulations (`Nsim`)**: Total number of genetic algorithm iterations. Default is 1000.

---

## Output Files

The script generates the following outputs:

1. **`PortfoliosValues.xlsx`**: Contains:
   - Adjusted stock prices (`TableAdjPrices`)
   - Sharpe Ratios and performance statistics for portfolios
   - Final portfolio compositions after simulations

2. **Plots**:
   - Cumulative returns for all portfolios over time.
   - Portfolio values in USD over time.

3. **MATLAB Figures**: Saved during each simulation for review.

---

## Results

The algorithm evaluates portfolios based on their Sharpe Ratio, aiming to maximize returns relative to risk. Iterative simulations refine portfolio composition to converge towards optimal solutions. The results include:

- **Best Portfolios**: Detailed components and performance metrics.
- **Comparison with Benchmark**: Sharpe Ratio of optimized portfolios vs. NASDAQ-100 index.
- **Cumulative Return Plots**: Visual representation of portfolio performance.

---

## License

This project is licensed under the [MIT License](LICENSE).