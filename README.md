# Retail Sales Data Analysis  SQL & Power BI

## Project Overview

This project analyzes a retail sales dataset containing over 51,000 transaction records.

The project uses PostgreSQL for data cleaning, transformation and business analysis, and Power BI for interactive dashboard development.

## Tools Used

- PostgreSQL
- pgAdmin
- Power BI Desktop
- SQL
- DAX
- Git  GitHub

## Dataset

The project uses a publicly available retail sales dataset.

The raw dataset is not included in this repository. Please refer to the original dataset source for download and licensing information.

## Dataset Overview

- Records 51,290
- Orders 25,035
- Customers 795
- Products 10,292
- Units Sold 178,312
- Total Sales $12.64M
- Total Profit $1.47M
- Profit Margin 11.62%

## SQL Analysis

The PostgreSQL analysis includes

- Data cleaning and type conversion
- Missing-value checks
- Duplicate transaction checks
- Sales and profit analysis
- Monthly sales trends
- Regional performance
- Market performance
- Category and sub-category analysis
- Product profitability
- Customer segmentation
- Discount vs profitability
- Shipping mode analysis

## Power BI Dashboard

The Power BI report contains three analytical pages

### 1. Retail Sales Analytics

Executive overview containing

- Total Sales
- Total Profit
- Total Orders
- Total Customers
- Profit Margin
- Monthly sales and profit trends
- Sales by region
- Sales by category
- Top products

### 2. Product & Customer Analysis

Includes

- Product performance
- Category analysis
- Sub-category profitability
- Top 10 products
- Customer segment analysis
- Product sales vs profitability

### 3. Regional Performance

Includes

- Sales by region
- Profit by region
- Sales by market
- State-level performance
- Regional profit margins

## Key Business Questions

- Which regions generate the highest sales
- Which categories generate the highest profit
- Which products are the top revenue contributors
- Which sub-categories have weak profitability
- Which customer segments contribute the most revenue
- How does discounting affect profitability
- Which shipping modes have the highest average delivery time
- What seasonal patterns exist in monthly sales

## Project Structure

```text
retail-sales-analysis
│
├── sql
│   └── retail_sales_analysis.sql
│
├── powerbi
│   └── Retail_Sales_Analysis.pbix
│
├── screenshots
│
├── README.md
└── .gitignore