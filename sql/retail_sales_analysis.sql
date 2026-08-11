-- ============================================================
-- RETAIL SALES DATA ANALYSIS
-- PostgreSQL
--
-- Dataset: Superstore Retail Sales
-- Records: 51,290
--
-- Workflow:
-- 1. Raw/staging table
-- 2. Data cleaning
-- 3. Data quality checks
-- 4. KPI analysis
-- 5. Sales analysis
-- 6. Product analysis
-- 7. Customer analysis
-- 8. Regional analysis
-- 9. Shipping analysis
-- 10. Business insights
-- ============================================================


-- ============================================================
-- 1. RAW / STAGING TABLE
-- ============================================================

DROP TABLE IF EXISTS public.retail_sales_raw;

CREATE TABLE public.retail_sales_raw (
    order_id TEXT,
    order_date TEXT,
    ship_date TEXT,
    ship_mode TEXT,
    customer_name TEXT,
    segment TEXT,
    state TEXT,
    country TEXT,
    market TEXT,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales TEXT,
    quantity TEXT,
    discount TEXT,
    profit TEXT,
    shipping_cost TEXT,
    order_priority TEXT,
    year TEXT
);


-- ============================================================
-- NOTE:
-- Import the CSV into retail_sales_raw using pgAdmin
-- before running the remaining sections.
-- ============================================================


-- ============================================================
-- 2. RAW DATA EXPLORATION
-- ============================================================

-- Total records
SELECT COUNT(*) AS total_records
FROM retail_sales_raw;


-- Preview raw data
SELECT *
FROM retail_sales_raw
LIMIT 10;


-- Check raw table structure
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'retail_sales_raw'
ORDER BY ordinal_position;


-- Unique orders, customers and products
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_name) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products
FROM retail_sales_raw;


-- ============================================================
-- 3. CREATE CLEAN ANALYTICAL TABLE
-- ============================================================

DROP TABLE IF EXISTS public.retail_sales_clean;

CREATE TABLE public.retail_sales_clean AS
SELECT

    -- Text cleaning
    TRIM(order_id) AS order_id,

    -- Date conversion
    TRIM(order_date)::DATE AS order_date,
    TRIM(ship_date)::DATE AS ship_date,

    TRIM(ship_mode) AS ship_mode,
    TRIM(customer_name) AS customer_name,
    TRIM(segment) AS segment,
    TRIM(state) AS state,
    TRIM(country) AS country,
    TRIM(market) AS market,
    TRIM(region) AS region,
    TRIM(product_id) AS product_id,
    TRIM(category) AS category,
    TRIM(sub_category) AS sub_category,
    TRIM(product_name) AS product_name,

    -- Numeric conversions
    -- Removes comma separators such as '1,648'
    REPLACE(TRIM(sales), ',', '')::NUMERIC(12,2) AS sales,

    REPLACE(TRIM(quantity), ',', '')::INTEGER AS quantity,

    REPLACE(TRIM(discount), ',', '')::NUMERIC(5,2) AS discount,

    REPLACE(TRIM(profit), ',', '')::NUMERIC(12,2) AS profit,

    REPLACE(TRIM(shipping_cost), ',', '')::NUMERIC(12,2)
        AS shipping_cost,

    TRIM(order_priority) AS order_priority,

    TRIM(year)::INTEGER AS year

FROM public.retail_sales_raw;


-- ============================================================
-- 4. VERIFY CLEAN TABLE
-- ============================================================

SELECT *
FROM public.retail_sales_clean
LIMIT 10;


-- Check cleaned data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'retail_sales_clean'
ORDER BY ordinal_position;


-- ============================================================
-- 5. DATA QUALITY CHECKS
-- ============================================================

-- Missing values
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ) AS null_order_id,

    COUNT(*) FILTER (
        WHERE order_date IS NULL
    ) AS null_order_date,

    COUNT(*) FILTER (
        WHERE customer_name IS NULL
    ) AS null_customer,

    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS null_product,

    COUNT(*) FILTER (
        WHERE sales IS NULL
    ) AS null_sales,

    COUNT(*) FILTER (
        WHERE profit IS NULL
    ) AS null_profit

FROM public.retail_sales_clean;


-- Empty strings in raw data
SELECT
    COUNT(*) FILTER (
        WHERE TRIM(order_id) = ''
    ) AS empty_order_id,

    COUNT(*) FILTER (
        WHERE TRIM(customer_name) = ''
    ) AS empty_customer,

    COUNT(*) FILTER (
        WHERE TRIM(product_id) = ''
    ) AS empty_product,

    COUNT(*) FILTER (
        WHERE TRIM(product_name) = ''
    ) AS empty_product_name

FROM public.retail_sales_raw;


-- Duplicate transaction check
SELECT
    order_id,
    product_id,
    order_date,
    customer_name,
    product_name,
    sales,
    quantity,
    COUNT(*) AS duplicate_count

FROM public.retail_sales_clean

GROUP BY
    order_id,
    product_id,
    order_date,
    customer_name,
    product_name,
    sales,
    quantity

HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC;


-- Negative / zero / invalid values
SELECT
    COUNT(*) FILTER (
        WHERE sales < 0
    ) AS negative_sales,

    COUNT(*) FILTER (
        WHERE sales = 0
    ) AS zero_sales,

    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE profit IS NULL
    ) AS missing_profit,

    COUNT(*) FILTER (
        WHERE ship_date < order_date
    ) AS invalid_ship_dates

FROM public.retail_sales_clean;


-- Discount range
SELECT
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    ROUND(AVG(discount), 4) AS avg_discount
FROM public.retail_sales_clean;


-- Discount validation
SELECT
    COUNT(*) FILTER (
        WHERE discount < 0
    ) AS negative_discount,

    COUNT(*) FILTER (
        WHERE discount > 1
    ) AS discount_over_100_percent

FROM public.retail_sales_clean;


-- ============================================================
-- 6. CREATE INDEXES
-- ============================================================

CREATE INDEX idx_retail_sales_order_id
ON public.retail_sales_clean(order_id);

CREATE INDEX idx_retail_sales_customer
ON public.retail_sales_clean(customer_name);

CREATE INDEX idx_retail_sales_product
ON public.retail_sales_clean(product_id);

CREATE INDEX idx_retail_sales_order_date
ON public.retail_sales_clean(order_date);

CREATE INDEX idx_retail_sales_region
ON public.retail_sales_clean(region);


-- ============================================================
-- 7. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT customer_name) AS total_customers,

    COUNT(DISTINCT product_id) AS total_products,

    SUM(quantity) AS total_units_sold,

    ROUND(SUM(sales), 2) AS total_sales,

    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean;


-- ============================================================
-- 8. DATE ANALYSIS
-- ============================================================

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT year) AS number_of_years

FROM public.retail_sales_clean;


-- ============================================================
-- 9. MONTHLY SALES TREND
-- ============================================================

SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,

    EXTRACT(YEAR FROM order_date) AS year,

    EXTRACT(MONTH FROM order_date) AS month_number,

    TO_CHAR(order_date, 'Mon') AS month_name,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS total_sales,

    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY
    DATE_TRUNC('month', order_date),
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date),
    TO_CHAR(order_date, 'Mon')

ORDER BY month;


-- ============================================================
-- 10. REGIONAL PERFORMANCE
-- ============================================================

SELECT
    region,

    COUNT(DISTINCT order_id) AS orders,

    COUNT(DISTINCT customer_name) AS customers,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY region

ORDER BY sales DESC;


-- ============================================================
-- 11. MARKET PERFORMANCE
-- ============================================================

SELECT
    market,

    COUNT(DISTINCT order_id) AS orders,

    COUNT(DISTINCT customer_name) AS customers,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY market

ORDER BY sales DESC;


-- ============================================================
-- 12. CATEGORY PERFORMANCE
-- ============================================================

SELECT
    category,

    COUNT(DISTINCT product_id) AS products,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY category

ORDER BY sales DESC;


-- ============================================================
-- 13. SUB-CATEGORY PERFORMANCE
-- ============================================================

SELECT
    sub_category,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY sub_category

ORDER BY profit DESC;


-- ============================================================
-- 14. TOP 10 PRODUCTS BY SALES
-- ============================================================

SELECT
    product_name,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS total_sales,

    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY product_name

ORDER BY total_sales DESC

LIMIT 10;


-- ============================================================
-- 15. TOP 10 PRODUCTS BY PROFIT
-- ============================================================

SELECT
    product_name,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS total_sales,

    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY product_name

ORDER BY total_profit DESC

LIMIT 10;


-- ============================================================
-- 16. LOWEST PROFIT PRODUCTS
-- ============================================================

SELECT
    product_name,

    ROUND(SUM(sales), 2) AS total_sales,

    ROUND(SUM(profit), 2) AS total_profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY product_name

ORDER BY total_profit ASC

LIMIT 10;


-- ============================================================
-- 17. CUSTOMER SEGMENT ANALYSIS
-- ============================================================

SELECT
    segment,

    COUNT(DISTINCT customer_name) AS customers,

    COUNT(DISTINCT order_id) AS orders,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY segment

ORDER BY sales DESC;


-- ============================================================
-- 18. TOP 10 CUSTOMERS BY SALES
-- ============================================================

SELECT
    customer_name,

    COUNT(DISTINCT order_id) AS orders,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit

FROM public.retail_sales_clean

GROUP BY customer_name

ORDER BY sales DESC

LIMIT 10;


-- ============================================================
-- 19. TOP 10 CUSTOMERS BY PROFIT
-- ============================================================

SELECT
    customer_name,

    COUNT(DISTINCT order_id) AS orders,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit

FROM public.retail_sales_clean

GROUP BY customer_name

ORDER BY profit DESC

LIMIT 10;


-- ============================================================
-- 20. DISCOUNT VS PROFITABILITY
-- ============================================================

SELECT
    discount,

    COUNT(*) AS transactions,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY discount

ORDER BY discount;


-- ============================================================
-- 21. SHIPPING MODE ANALYSIS
-- ============================================================

SELECT
    ship_mode,

    COUNT(DISTINCT order_id) AS orders,

    SUM(quantity) AS units_sold,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        AVG(ship_date - order_date),
        2
    ) AS avg_shipping_days

FROM public.retail_sales_clean

GROUP BY ship_mode

ORDER BY sales DESC;


-- ============================================================
-- 22. SALES BY STATE
-- ============================================================

SELECT
    state,

    COUNT(DISTINCT order_id) AS orders,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY state

ORDER BY sales DESC;


-- ============================================================
-- 23. TOP 10 STATES BY SALES
-- ============================================================

SELECT
    state,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit

FROM public.retail_sales_clean

GROUP BY state

ORDER BY sales DESC

LIMIT 10;


-- ============================================================
-- 24. LOSS-MAKING SUB-CATEGORIES
-- ============================================================

SELECT
    sub_category,

    ROUND(SUM(sales), 2) AS sales,

    ROUND(SUM(profit), 2) AS profit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin

FROM public.retail_sales_clean

GROUP BY sub_category

HAVING SUM(profit) < 0

ORDER BY profit ASC;


-- ============================================================
-- 25. PRODUCT ID / PRODUCT NAME VALIDATION
-- ============================================================

SELECT
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(DISTINCT product_name) AS unique_product_names

FROM public.retail_sales_clean;


SELECT
    product_id,
    COUNT(DISTINCT product_name) AS product_names

FROM public.retail_sales_clean

GROUP BY product_id

HAVING COUNT(DISTINCT product_name) > 1

ORDER BY product_names DESC;


-- ============================================================
-- END OF RETAIL SALES ANALYSIS
-- ============================================================