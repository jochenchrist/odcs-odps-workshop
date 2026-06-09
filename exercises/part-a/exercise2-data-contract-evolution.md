# Exercise 2: Data Contract Evolution

The business wants to track *how many* units of an item are bought per order. The orders team introduces a new column `quantity` in the `line_items` table. It defaults to 1, but it is still a breaking change for data consumers — any downstream pipeline or report that relies on a fixed set of columns will need to be updated. So you release it as a new major version: `orders_v2`.

The database already contains the new version in the schema [`orders_v2`](/data/orders_v2/). It holds both tables — `orders` is unchanged, `line_items` has the new `quantity` column:

```sql
\dt orders_v2.*
SELECT * FROM orders_v2.orders LIMIT 5;
SELECT * FROM orders_v2.line_items LIMIT 5;
```

## Create v2

1. Copy your data contract from [Exercise 1](exercise1-put-your-data-under-contract.md) to `orders_v2.odcs.yaml` and open it in the [Data Contract Editor](https://editor.datacontract.com) (use the hamburger menu to load files).
2. Introduce the new major version:
   - Update the ID to `orders_v2` and the contract version to `2.0.0`
   - Update the server schema to `orders_v2` (and the schema name in your quality check queries!)
   - Set `status` to `draft`
   - Add the `quantity` property (physicalType `bigint`) to `line_items`, including a quality check (e.g., `quantity` must be greater than 0)
3. Run the tests and make sure they pass:

   ```
   datacontract test orders_v2.odcs.yaml
   ```

## Execute the Migration

You own both versions. A full migration goes through this lifecycle: release v2 (`active`), deprecate v1 (`deprecated` plus an `endOfSupport` SLA property with a concrete date), announce the migration in the support channel, and — once nobody queries v1 anymore — retire it (`retired`).

4. Shortcut for this workshop: set v1 to `retired` and v2 to `active` in your contract files.
