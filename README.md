# E-Commerce Sales Analysis - SQL Portfolio Project

## Project Overview
Comprehensive SQL analysis of Brazilian e-commerce dataset (Olist) including 100k+ orders. Analyzed sales trends, customer behavior, delivery performance, and product profitability.

## Key Analyses Performed

### 1. Sales Performance
- **Daily/ Monthly/ Yearly Sales Trends** - Identified peak sales periods
- **Revenue Drop Detection** - Found months with negative growth using LAG()
- **Cumulative Revenue** - Tracked running total over time

### 2. Customer Analytics
- **RFM Segmentation** - Ranked customers by Recency, Frequency, Monetary value
- **Customer Retention** - Calculated month-over-month retention rates
- **Top Paying Customers** - Identified highest spenders with city and product info
- **Repeat Purchase Analysis** - Found customers buying same category multiple times

### 3. Product Insights
- **Category Profitability** - Ranked categories by total sales
- **Category Review Analysis** - Found lowest-rated product categories

### 4. Operational Analytics
- **Delivery Performance** - Average delivery time: 12 days
- **Late Delivery Rate** - 23.5% of orders delivered after 7+ days
- **Delivery Breakdown**:
  - Quick (≤3 days): 15%
  - Fast (4-7 days): 35%
  - Late (8-15 days): 35%
  - Very Late (≥16 days): 15%

## Key Findings

1. **Revenue Drop**: Identified specific months where revenue decreased vs previous month
2. **Customer Segments**: 
   - Champions - Most valuable customers
   - Lost customers - Low recency and frequency
3. **Delivery Impact**: 23.5% of orders take 7+ days to deliver
4. **Top Categories**: Categories generating the highest revenue
5. **Lowest Rated Categories**: Product categories with poorest customer reviews

## SQL Techniques Demonstrated

### Window Functions
- `RANK()` - Customer ranking by spend
- `NTILE(5)` - RFM scoring
- `LAG()` - Month-over-month revenue comparison
- `SUM() OVER()` - Cumulative revenue

### Advanced Queries
- CTEs (`WITH` clauses for RFM, retention analysis)
- Conditional aggregation (`FILTER` clause)
- Date functions (`DATE_TRUNC`, `EXTRACT`, `AGE`)
- NULL handling with `LEFT JOIN`

### Business Metrics
- Customer retention rates
- RFM segmentation
- Delivery time analysis
- Revenue trend detection

## Files
- `ecommerce_analysis.sql` - Complete SQL queries with comments
- `README.md` - Project documentation

## Data Source
Olist Brazilian E-Commerce Public Dataset (9 tables: customers, orders, payments, products, reviews, etc.)

## How to Use
1. Import Olist dataset into PostgreSQL
2. Run queries sequentially from `ecommerce_analysis.sql`
3. Each query includes comments explaining the business question

## Skills Demonstrated
- Complex SQL queries (joins, CTEs, window functions)
- Business metric calculation
- Customer segmentation (RFM)
- Time-series analysis
- Data cleaning (NULL handling, date parsing)
