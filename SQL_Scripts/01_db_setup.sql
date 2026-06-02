CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    segment VARCHAR(50),
    city VARCHAR(100)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL, 
    category VARCHAR(100),
    cost_price INT, 
    list_price INT 
);

CREATE TABLE orders (
    order_id VARCHAR(50), 
    customer_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL, 
    order_date DATE,
    ship_date DATE,
    quantity INT,
    discount_percent FLOAT,
    courier_partner VARCHAR(100)
);

CREATE TABLE returns (
    return_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    return_reason VARCHAR(255)
);