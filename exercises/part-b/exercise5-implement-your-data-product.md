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

## Survive a Breaking Change

In exercise 2 you were the producer driving a migration. Now experience the other side: the orders team announces `orders_v3`, which renames `quantity` to `item_count` — a breaking change. The v2 contract gets an `endOfSupport` date six months from now.

6. As the owner of **SKU sales**, plan your migration:
   - Which of your three artifacts (view, ODCS contract, ODPS file) need to change? Write down the concrete edits — assume `orders_v3` lives in a schema `orders_v3`.
   - In which order do you apply them, so that your consumers never see a broken or untested view?
   - Does *your* contract version change? Major, minor, or patch — and why?
   - How would the orders team have found out that you are affected? Which line in your ODPS file makes your dependency visible?

## Bonus

- Export the HTML documentation:
  ```
  datacontract export --format html sku_sales_per_year.odcs.yaml > sku_sales_per_year.odcs.html
  ```
- The source contract marks `customer_email_address` as confidential PII. Verify that your derived product does not leak it — which contract field documents this?
- Draw the data product graph (products, ports, contracts) of this workshop — for example as a [Mermaid](https://mermaid.live) diagram
- Run all reference solutions end-to-end: `./solutions/test_all.sh`
