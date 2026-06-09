# Exercise 2: Data Contract Evolution

The business wants to track *how many* units of an item are bought per order. The orders team introduces a new column `quantity` in the `line_items` table. It defaults to 1, but it is still a breaking change for data consumers — any downstream pipeline or report that relies on a fixed set of columns will need to be updated. So you release it as a new major version: `orders_v2`.

The database already contains the new version in the schema [`orders_v2`](/data/orders_v2/):

```sql
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

## Plan the Migration

Form teams of two. One person is responsible for v1, the other for v2. Play through the migration process together:

4. Think through the lifecycle of v1 and v2:
   - The v1 owner: set status to `deprecated` and add an `endOfSupport` SLA property with a concrete date
   - The v2 owner: set status to `active` once consumers have been notified
   - The v1 owner: eventually set status to `retired`
   - Who needs to be informed? How would the `support` channels from exercise 1 help here?
