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

You own both versions. Play through the lifecycle by editing the two contract files:

4. Release v2: set its `status` from `draft` to `active`
5. Deprecate v1:
   - Set its `status` to `deprecated`
   - Add an `endOfSupport` SLA property with a concrete date (e.g., six months from today):

     ```yaml
     slaProperties:
       - property: endOfSupport
         value: "2026-12-09"
         description: v1 is deprecated, migrate to orders_v2
     ```

6. Notify your consumers: write the actual announcement message you would post in the `#order-data-help` support channel from exercise 1 (2–3 sentences). Make sure it answers: what changes, by when, what do consumers have to do, and where do they get help?
7. Retire v1: once the `endOfSupport` date has passed and nobody queries v1 anymore, set its `status` to `retired`
8. Reflect:
   - How do you *know* nobody queries v1 anymore? What would you need to measure?
   - When would you actually drop the `orders_v1` schema from the database?
