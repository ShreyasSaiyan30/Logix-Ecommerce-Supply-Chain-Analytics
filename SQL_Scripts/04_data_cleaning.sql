CREATE OR REPLACE VIEW V_CLEAN_CUSTOMERS AS
SELECT
	CUSTOMER_ID,
	CUSTOMER_NAME,
	SEGMENT,
	CASE
		WHEN TRIM(CITY) IS NULL
		OR TRIM(CITY) = '' THEN 'Unknown'
		WHEN TRIM(CITY) IN ('Bengaluru', 'Bangalore', 'BLR') THEN 'Bengaluru'
		ELSE TRIM(CITY)
	END AS CITY
FROM
	CUSTOMERS

-- ====================================================================
-- VIEW 2: v_clean_orders
-- OBJECTIVE: Deduplicate transaction-level records and inject 
--            operational supply chain fulfillment KPIs (SLA status).
-- ====================================================================
CREATE OR REPLACE VIEW V_CLEAN_ORDERS AS
WITH
	DEDUPLICATED_STAGE AS (
		SELECT
			ORDER_ID,
			ORDER_DATE,
			SHIP_DATE,
			CUSTOMER_ID,
			PRODUCT_ID,
			QUANTITY,
			DISCOUNT_PERCENT,
			COURIER_PARTNER,
			ROW_NUMBER() OVER (
				PARTITION BY
					ORDER_ID,
					PRODUCT_ID
				ORDER BY
					ORDER_DATE ASC
			) AS ROW_NUM
		FROM
			ORDERS
	)
SELECT
	ORDER_ID,
	ORDER_DATE,
	SHIP_DATE,
	CUSTOMER_ID,
	PRODUCT_ID,
	QUANTITY,
	DISCOUNT_PERCENT,
	COURIER_PARTNER,
	CASE
		WHEN SHIP_DATE IS NULL THEN 'In Transit'
		WHEN (SHIP_DATE - ORDER_DATE) > 5 THEN 'Severe Delay'
		ELSE 'On Time'
	END AS SHIPPING_STATUS
FROM
	DEDUPLICATED_STAGE
WHERE
	ROW_NUM = 1;

-- ====================================================================
-- VIEW 3: v_clean_products
-- OBJECTIVE: Provide a secure, decoupled pass-through lens for the 
--            product catalog to maintain pipeline uniformity.
-- ====================================================================
CREATE OR REPLACE VIEW V_CLEAN_PRODUCTS AS
SELECT
	PRODUCT_ID,
	PRODUCT_NAME,
	CATEGORY,
	COST_PRICE,
	LIST_PRICE
FROM
	PRODUCTS;

-- ====================================================================
-- VIEW 4: v_clean_returns
-- OBJECTIVE: Provide a secure, decoupled pass-through lens for the 
--            reverse logistics catalog to maintain pipeline uniformity.
-- ====================================================================
CREATE OR REPLACE VIEW V_CLEAN_RETURNS AS
SELECT
	RETURN_ID,
	ORDER_ID,
	RETURN_REASON
FROM
	RETURNS;