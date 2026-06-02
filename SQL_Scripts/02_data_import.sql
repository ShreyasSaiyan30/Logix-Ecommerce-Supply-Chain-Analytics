-- ====================================================================
-- PHASE 1: DATA INGESTION & STAGING LAYER (REFERENCE SCRIPT)
-- ====================================================================
-- NOTE: For this local portfolio environment, data was ingested using 
-- the pgAdmin Import/Export GUI Wizard tool to bypass local OS file 
-- permission restrictions. 
--
-- The production-grade ANSI-SQL equivalent COPY commands are documented
-- below to demonstrate pipeline replication and automation capability.
-- ====================================================================

-- 1. Bulk Ingesting Customers Lookup File
-- COPY customers FROM 'C:\Enterprise_Supply_Chain_Project\dim_customers.csv' 
-- WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

-- 2. Bulk Ingesting Products Lookup File
-- COPY products FROM 'C:\Enterprise_Supply_Chain_Project\dim_products.csv' 
-- WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

-- 3. Bulk Ingesting Core Orders Transaction File
-- COPY orders FROM 'C:\Enterprise_Supply_Chain_Project\fact_orders.csv' 
-- WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

-- 4. Bulk Ingesting Returns Status File
-- COPY returns FROM 'C:\Enterprise_Supply_Chain_Project\fact_returns.csv' 
-- WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');


-- ====================================================================
-- INGESTION VALIDATION AUDIT
-- ====================================================================
-- Run this query post-import to verify that row counts match 
-- source data extraction exactly.

SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'returns', COUNT(*) FROM returns;
