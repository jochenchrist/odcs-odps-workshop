# Exercise 5: Implement Your Data Product

In [Exercise 4](exercise4-design-your-data-product.md) you designed the contract — now fulfill it. You implement the data product as a plain SQL view on top of the `orders_v2` schema and iterate until the contract tests pass.

## Build the Transformation

1. Connect to the database:

   ```
   docker compose exec postgres psql -U workshop -d workshop
   ```

2. Create the `analytics` schema and the `sku_sales_per_year` view. Join `line_items` with `orders` and aggregate per SKU and year, exactly as your contract specifies:

   ```sql
   CREATE SCHEMA IF NOT EXISTS analytics;

   CREATE OR REPLACE VIEW analytics.sku_sales_per_year AS
   SELECT
       -- your transformation here
   FROM orders_v2.line_items li
   JOIN orders_v2.orders o ON li.order_id = o.order_id
   GROUP BY ...;
   ```

   > **Hint:** `EXTRACT(YEAR FROM order_timestamp)` returns a `numeric` in PostgreSQL — cast it with `::int`. The same goes for `SUM(quantity)`, which returns `numeric` — cast it with `::bigint`. Types matter: they are part of your contract!

3. Sanity-check the result:

   ```sql
   SELECT * FROM analytics.sku_sales_per_year ORDER BY total_quantity DESC LIMIT 10;
   SELECT min(year), max(year) FROM analytics.sku_sales_per_year;
   ```

## Make the Contract Tests Pass

4. Run the tests from Exercise 4 again — and iterate on your view until everything is green:

   ```
   export DATACONTRACT_POSTGRES_USERNAME=workshop
   export DATACONTRACT_POSTGRES_PASSWORD=workshop
   datacontract test sku_sales_per_year.odcs.yaml
   ```

5. Your data product is live — set the `status` to `active` in both the contract and the ODPS file!

## Play Through the Lifecycle

Form teams of two. One person owns the **orders** data product (Part A), the other owns **SKU sales** (Part B). Play through an evolution scenario together:

6. The orders team wants to rename `quantity` to `item_count` — a breaking change, so they plan `orders_v3`.
   - The orders owner: how do you find out who is affected? How do the input ports of downstream products help?
   - The orders owner: announce the change via the `support` channel, add an `endOfSupport` SLA property to the v2 contract with a concrete date
   - The SKU sales owner: what do you need to change, and in which order? Does *your* contract version change too?

## Bonus

- Export the HTML documentation:
  ```
  datacontract export --format html sku_sales_per_year.odcs.yaml > sku_sales_per_year.odcs.html
  ```
- The source contract marks `customer_email_address` as confidential PII. Verify that your derived product does not leak it — which contract field documents this?
- Draw the data product graph (products, ports, contracts) of this workshop — for example as a [Mermaid](https://mermaid.live) diagram
- Run all reference solutions end-to-end: `./solutions/test_all.sh`
