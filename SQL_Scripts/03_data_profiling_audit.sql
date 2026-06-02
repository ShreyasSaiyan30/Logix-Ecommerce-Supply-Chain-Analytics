-- ====================================================================
-- PROJECT: Enterprise E-Commerce Supply Chain Optimization Pipeline
-- PHASE 2: DATA PROFILING & AUTOMATED QUALITY DIAGNOSTICS
-- FILE NAME: 03_data_profiling_audit.sql
-- OBJECTIVE: Perform an exhaustive, zero-knowledge audit across all 
--            relational dimensions to catch structural failures, 
--            semantic drift, and whitespace corruption.
-- ====================================================================

-- ====================================================================
-- AUDIT CHECK 01: CATEGORICAL FREQUENCY & SEMANTIC SPELLING AUDITS
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 01A: Customer Segment Frequency Distribution
-- Target Table: customers | Target Column: segment
-- Objective: Map total record distribution and check for low-volume 
--            typographical anomalies.
-- --------------------------------------------------------------------
SELECT 
    segment, 
    COUNT(*) AS record_count, 
    ROUND((COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM customers) * 100), 2) AS percentage_share
FROM customers
GROUP BY segment
ORDER BY record_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 01B: Customer City Semantic Distribution
-- Target Table: customers | Target Column: city
-- Objective: Detect geographic fragmentation splits and spelling variations.
-- --------------------------------------------------------------------
SELECT 
    city, 
    COUNT(*) AS record_count, 
    ROUND((COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM customers) * 100), 2) AS percentage_share
FROM customers
GROUP BY city
ORDER BY city ASC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 01C: Product Category Catalog Distribution
-- Target Table: products | Target Column: category
-- Objective: Validate structural categorization distribution across inventory.
-- --------------------------------------------------------------------
SELECT 
    category, 
    COUNT(*) AS record_count
FROM products
GROUP BY category
ORDER BY record_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 01D: Product Name Frequency Distribution
-- Target Table: products | Target Column: product_name
-- Objective: Audit high-cardinality item strings for name repetition.
-- --------------------------------------------------------------------
SELECT 
    product_name, 
    COUNT(*) AS record_count
FROM products
GROUP BY product_name
ORDER BY record_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 01E: Logistics Courier Partner Distribution
-- Target Table: orders | Target Column: courier_partner
-- Objective: Evaluate volume allocation across fulfillment vendors.
-- --------------------------------------------------------------------
SELECT 
    courier_partner, 
    COUNT(*) AS record_count, 
    ROUND((COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM orders) * 100), 2) AS percentage_share
FROM orders
GROUP BY courier_partner
ORDER BY record_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 01F: Reverse Logistics Return Reason Distribution
-- Target Table: returns | Target Column: return_reason
-- Objective: Verify reason classifications and evaluate data entry integrity.
-- --------------------------------------------------------------------
SELECT 
    return_reason, 
    COUNT(*) AS record_count
FROM returns
GROUP BY return_reason
ORDER BY record_count DESC;


-- ====================================================================
-- AUDIT CHECK 02: GLOBAL COMPLETENESS AUDITS (NULL & BLANK HUNTING)
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 02A: Customers Table Missing Fields
-- Target Columns: customer_id, customer_name, segment, city
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE customer_id IS NULL OR customer_id = '') AS missing_customer_ids,
    COUNT(*) FILTER (WHERE customer_name IS NULL OR customer_name = '') AS missing_customer_names,
    COUNT(*) FILTER (WHERE segment IS NULL OR segment = '') AS missing_segments,
    COUNT(*) FILTER (WHERE city IS NULL OR city = '') AS missing_cities
FROM customers;

-- --------------------------------------------------------------------
-- AUDIT CHECK 02B: Products Table Missing Fields
-- Target Columns: product_id, product_name, category, cost_price, list_price
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE product_id IS NULL OR product_id = '') AS missing_product_ids,
    COUNT(*) FILTER (WHERE product_name IS NULL OR product_name = '') AS missing_product_names,
    COUNT(*) FILTER (WHERE category IS NULL OR category = '') AS missing_categories,
    COUNT(*) FILTER (WHERE cost_price IS NULL) AS missing_cost_prices,
    COUNT(*) FILTER (WHERE list_price IS NULL) AS missing_list_prices
FROM products;

-- --------------------------------------------------------------------
-- AUDIT CHECK 02C: Orders Table Missing Fields
-- Target Columns: order_id, order_date, ship_date, quantity, discount_percent
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS missing_order_ids,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS missing_order_dates,
    COUNT(*) FILTER (WHERE ship_date IS NULL) AS unshipped_orders_count,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantities,
    COUNT(*) FILTER (WHERE discount_percent IS NULL) AS missing_discounts
FROM orders;

-- --------------------------------------------------------------------
-- AUDIT CHECK 02D: Returns Table Missing Fields
-- Target Columns: return_id, order_id, return_reason
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE return_id IS NULL OR return_id = '') AS missing_return_ids,
    COUNT(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS missing_order_ids,
    COUNT(*) FILTER (WHERE return_reason IS NULL OR return_reason = '') AS missing_return_reasons
FROM returns;


-- ====================================================================
-- AUDIT CHECK 03: ENTITY INTEGRITY & PRIMARY KEY UNIQUENESS VALIDATION
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 03A: Customers Primary Key Uniqueness Validation
-- Target Column: customer_id
-- --------------------------------------------------------------------
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 03B: Products Primary Key Uniqueness Validation
-- Target Column: product_id
-- --------------------------------------------------------------------
SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 03C: Orders Transaction-Level Duplicate Verification
-- Target Composite Key: order_id + product_id
-- --------------------------------------------------------------------
SELECT order_id, product_id, COUNT(*) AS transaction_entry_count
FROM orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY transaction_entry_count DESC;

-- --------------------------------------------------------------------
-- AUDIT CHECK 03D: Returns Primary Key Uniqueness Validation
-- Target Column: return_id
-- --------------------------------------------------------------------
SELECT return_id, COUNT(*) AS duplicate_count
FROM returns
GROUP BY return_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ====================================================================
-- AUDIT CHECK 04: VALUE VALIDITY & DOMAIN BOUNDARY AUDITS
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 04A: Products Pricing Boundary Validation
-- Target Columns: cost_price, list_price
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE cost_price < 0) AS negative_cost_count,
    COUNT(*) FILTER (WHERE cost_price = 0) AS zero_cost_count,
    COUNT(*) FILTER (WHERE list_price < 0) AS negative_list_count,
    COUNT(*) FILTER (WHERE list_price = 0) AS zero_list_count,
    COUNT(*) FILTER (WHERE cost_price > list_price) AS cost_exceeds_retail_count
FROM products;

-- --------------------------------------------------------------------
-- AUDIT CHECK 04B: Orders Quantitative Metric Validation
-- Target Columns: quantity, discount_percent
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_quantity_count,
    COUNT(*) FILTER (WHERE quantity = 0) AS zero_quantity_count,
    COUNT(*) FILTER (WHERE discount_percent < 0.00) AS negative_discount_count,
    COUNT(*) FILTER (WHERE discount_percent > 1.00) AS impossible_discount_count
FROM orders;

-- --------------------------------------------------------------------
-- AUDIT CHECK 04C: Orders Quantity Outlier Detection (Simplified MySQL)
-- Target Table: orders | Target Column: quantity
-- Objective: Count rows where quantity exceeds 3 standard deviations above average.
-- --------------------------------------------------------------------
SELECT COUNT(*) AS extreme_quantity_outliers
FROM orders
WHERE quantity > (SELECT AVG(quantity) + (3 * STDDEV(quantity)) FROM orders);

-- ====================================================================
-- AUDIT CHECK 05A: CHRONOLOGICAL & TEMPORAL SEQUENCE AUDITS
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 05A: Orders Temporal Sequence & Anomaly Validation
-- Target Columns: order_date, ship_date
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE ship_date < order_date) AS shipping_pre_dates_order_count,
    COUNT(*) FILTER (WHERE order_date < '2020-01-01') AS extreme_past_date_count,
    COUNT(*) FILTER (WHERE order_date > '2027-12-31') AS extreme_future_date_count
FROM orders;

-- --------------------------------------------------------------------
-- AUDIT CHECK 05B: Cross-Field Logistics Alignment Validation
-- Target Columns: ship_date, courier_partner
-- Objective: Identify logical contradictions between shipment execution 
--            dates and logistic vendor assignments.
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE ship_date IS NOT NULL AND (courier_partner IS NULL OR courier_partner = '')) AS shipped_without_carrier_count,
    COUNT(*) FILTER (WHERE ship_date IS NULL AND courier_partner IS NOT NULL AND courier_partner != '') AS unexecuted_carrier_assignment_count
FROM orders;


-- ====================================================================
-- AUDIT CHECK 06: OUTER EDGE (LEADING/TRAILING) WHITESPACE AUDITS
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 06A: Customers Leading/Trailing Whitespace Validation
-- Target Columns: customer_id, customer_name, segment, city
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE LENGTH(customer_id) != LENGTH(TRIM(customer_id))) AS cust_id_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(customer_name) != LENGTH(TRIM(customer_name))) AS cust_name_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(segment) != LENGTH(TRIM(segment))) AS segment_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(city) != LENGTH(TRIM(city))) AS city_outer_spaces
FROM customers;

-- --------------------------------------------------------------------
-- AUDIT CHECK 06B: Products Leading/Trailing Whitespace Validation
-- Target Columns: product_id, product_name, category
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE LENGTH(product_id) != LENGTH(TRIM(product_id))) AS prod_id_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(product_name) != LENGTH(TRIM(product_name))) AS prod_name_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(category) != LENGTH(TRIM(category))) AS cat_outer_spaces
FROM products;

-- --------------------------------------------------------------------
-- AUDIT CHECK 06C: Orders Leading/Trailing Whitespace Validation
-- Target Columns: order_id, customer_id, product_id, courier_partner
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE LENGTH(order_id) != LENGTH(TRIM(order_id))) AS order_id_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(customer_id) != LENGTH(TRIM(customer_id))) AS cust_id_fk_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(product_id) != LENGTH(TRIM(product_id))) AS prod_id_fk_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(courier_partner) != LENGTH(TRIM(courier_partner))) AS courier_outer_spaces
FROM orders;

-- --------------------------------------------------------------------
-- AUDIT CHECK 06D: Returns Leading/Trailing Whitespace Validation
-- Target Columns: return_id, order_id, return_reason
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE LENGTH(return_id) != LENGTH(TRIM(return_id))) AS return_id_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(order_id) != LENGTH(TRIM(order_id))) AS order_id_fk_outer_spaces,
    COUNT(*) FILTER (WHERE LENGTH(return_reason) != LENGTH(TRIM(return_reason))) AS reason_outer_spaces
FROM returns;


-- ====================================================================
-- AUDIT CHECK 07: INTERNAL MULTI-WORD WHITESPACE AUDITS
-- ====================================================================

-- --------------------------------------------------------------------
-- AUDIT CHECK 07A: Customers Internal Whitespace Validation
-- Target Columns: customer_name, segment, city
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE customer_name LIKE '%  %') AS name_internal_space_count,
    COUNT(*) FILTER (WHERE segment LIKE '%  %') AS segment_internal_space_count,
    COUNT(*) FILTER (WHERE city LIKE '%  %') AS city_internal_space_count
FROM customers;

-- --------------------------------------------------------------------
-- AUDIT CHECK 07B: Products Internal Whitespace Validation
-- Target Columns: product_name, category
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE product_name LIKE '%  %') AS prod_name_internal_space_count,
    COUNT(*) FILTER (WHERE category LIKE '%  %') AS cat_internal_space_count
FROM products;

-- --------------------------------------------------------------------
-- AUDIT CHECK 07C: Orders Internal Whitespace Validation
-- Target Column: courier_partner
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE courier_partner LIKE '%  %') AS courier_internal_space_count
FROM orders;

-- --------------------------------------------------------------------
-- AUDIT CHECK 07D: Returns Internal Whitespace Validation
-- Target Column: return_reason
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE return_reason LIKE '%  %') AS reason_internal_space_count
FROM returns;