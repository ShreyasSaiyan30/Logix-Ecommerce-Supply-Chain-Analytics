-- ====================================================================
-- PROJECT: Enterprise E-Commerce Supply Chain Optimization Pipeline
-- PHASE 4: POST-CLEANING QUALITY ASSURANCE & REGRESSION TESTING
-- FILE NAME: 05_post_cleaning_qa.sql
-- OBJECTIVE: Execute diagnostic testing directly against compiled views
--            to mathematically verify zero anomaly rates before data load.
-- ====================================================================

-- ====================================================================
-- QA BLOCK 01: CUSTOMER MIGRATION & TEXT STANDARDIZATION VALIDATION
-- ====================================================================

-- --------------------------------------------------------------------
-- QA CHECK 01A: Structural Integrity Check
-- Target View: v_clean_customers
-- Expected Output: outer_space_count = 0 | missing_city_count = 0
-- --------------------------------------------------------------------
SELECT 
    COUNT(*) FILTER (WHERE LENGTH(city) != LENGTH(TRIM(city))) AS outer_space_count,
    COUNT(*) FILTER (WHERE city IS NULL OR city = '') AS missing_city_count
FROM v_clean_customers;

-- --------------------------------------------------------------------
-- QA CHECK 01B: Semantic Consolidation Distribution
-- Target View: v_clean_customers
-- Expected Output: 'Bangalore' and 'BLR' must be completely missing.
--                  All variations consolidated under 'Bengaluru'.
--                  Blank records safely shifted to 'Unknown'.
-- --------------------------------------------------------------------
SELECT 
    city, 
    COUNT(*) AS record_count
FROM v_clean_customers
GROUP BY city
ORDER BY city ASC;


-- ====================================================================
-- QA BLOCK 02: TRANSACTIONAL DEDUPLICATION & FEATURE ENGINEERING
-- ====================================================================

-- --------------------------------------------------------------------
-- QA CHECK 02A: Composite Key Uniqueness Test
-- Target View: v_clean_orders
-- Expected Output: Empty Result Grid (Zero rows returned)
-- --------------------------------------------------------------------
SELECT 
    order_id, 
    product_id, 
    COUNT(*) AS entry_count
FROM v_clean_orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- --------------------------------------------------------------------
-- QA CHECK 02B: Shipping Status SLA Logic Verification
-- Target View: v_clean_orders
-- Expected Output: Operational distribution matrix.
--                  'In Transit' must equal exactly 496 rows.
-- --------------------------------------------------------------------
SELECT 
    shipping_status, 
    COUNT(*) AS order_count
FROM v_clean_orders
GROUP BY shipping_status
ORDER BY order_count DESC;