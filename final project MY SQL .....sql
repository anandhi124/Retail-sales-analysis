create database retail_sales_analysis;
use retail_sales_analysis;
-- add primary key
alter table categories
add constraint pk_category PRIMARY KEY (category_id);

alter table stores
add constraint pk_store PRIMARY KEY (store_id);

alter table customer
add constraint pk_customer PRIMARY KEY (customer_id);

alter table staffs
add constraint pk_staff PRIMARY KEY (staff_id);

alter table products
add constraint pk_product PRIMARY KEY (product_id);

alter table orders
add constraint pk_order PRIMARY KEY (order_id);

alter table orders_item
add constraint pk_orders_item PRIMARY KEY (order_id,item_id);

alter table stocks
add constraint pk_stocks PRIMARY KEY (store_id,product_id);

alter table brand
add constraint pk_brand PRIMARY KEY (brand_id);

SHOW columns FROM brand;

-- Add Forgien Key
ALTER TABLE Products
ADD CONSTRAINT fk_products_brand
FOREIGN KEY (brand_id) REFERENCES Brand(brand_id);
ALTER TABLE Products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id) REFERENCES Categories(category_id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE orders
ADD CONSTRAINT fk_orders_store
FOREIGN KEY (store_id) REFERENCES stores(store_id);
ALTER TABLE orders
ADD CONSTRAINT fk_orders_staff
FOREIGN KEY (staff_id) REFERENCES staffs(staff_id);

ALTER TABLE orders_item
ADD CONSTRAINT fk_orderitems_order
FOREIGN KEY (order_id) REFERENCES orders(order_id);
ALTER TABLE orders_item
ADD CONSTRAINT fk_orderitems_product
FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE stocks
ADD CONSTRAINT fk_stocks_store
FOREIGN KEY (store_id) REFERENCES stores(store_id);
ALTER TABLE stocks
ADD CONSTRAINT fk_stocks_product
FOREIGN KEY (product_id) REFERENCES products(product_id);

-- inner join for order details
SELECT 
    o.order_id,
    o.order_date,
    oi.item_id,
    oi.product_id,
    p.product_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    (oi.quantity * oi.list_price) AS total_price
FROM orders o
JOIN orders_item oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id;
    
    -- total sales by store
    SELECT 
    o.store_id,
    SUM(oi.quantity * oi.list_price) AS total_sales
FROM orders o
JOIN orders_item oi 
    ON o.order_id = oi.order_id
GROUP BY o.store_id;

-- top 5 selling products
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM orders_item oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 5;

-- customer purchase summary
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    
    COUNT(DISTINCT o.order_id) AS total_orders,
    
    SUM(oi.quantity) AS total_items,
    
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue

FROM customer c

LEFT JOIN orders o 
    ON c.customer_id = o.customer_id

LEFT JOIN orders_item oi 
    ON o.order_id = oi.order_id

GROUP BY 
    c.customer_id, c.first_name, c.last_name;
    
    -- segment customer by total spend
    SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending,
    
    CASE 
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) < 50000 THEN 'Low'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) BETWEEN 50000 AND 150000 THEN 'Medium'
        ELSE 'High'
    END AS spending_category

FROM customer c

LEFT JOIN orders o 
    ON c.customer_id = o.customer_id

LEFT JOIN orders_item oi 
    ON o.order_id = oi.order_id

GROUP BY 
    c.customer_id, c.first_name, c.last_name;
    -- staff performance analysis
    SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    
    COUNT(DISTINCT o.order_id) AS total_orders,
    
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue

FROM staffs s

LEFT JOIN orders o 
    ON s.staff_id = o.staff_id

LEFT JOIN orders_item oi 
    ON o.order_id = oi.order_id

GROUP BY 
    s.staff_id, s.first_name, s.last_name;
    
    -- stock alert query
    SELECT 
    p.product_id,
    p.product_name,
    s.store_id,
    st.quantity
FROM stocks st
JOIN products p 
    ON st.product_id = p.product_id
JOIN stores s 
    ON st.store_id = s.store_id
WHERE st.quantity < 10;

-- 10.creat final segmentation table
CREATE TABLE customer_segments (
    customer_id INT,
    segment VARCHAR(50),
    total_spending DECIMAL(10,2),
    total_orders INT,
    avg_order_value DECIMAL(10,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (customer_id),
    
    CONSTRAINT fk_customer_segment
    FOREIGN KEY (customer_id) 
    REFERENCES customer(customer_id)
);
    




























































 
