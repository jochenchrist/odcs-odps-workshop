CREATE SCHEMA IF NOT EXISTS controlling;

CREATE OR REPLACE VIEW controlling.orders AS
SELECT order_id, order_total FROM orders_v2.orders;
