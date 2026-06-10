# Exercise 1: Put Your Data Under Contract

You are the owner of the **orders** data in your company's e-commerce platform. The data lives in a PostgreSQL database and consists of two tables: `orders` (containing order details like timestamps, totals, and customer information) and `line_items` (containing the individual items in each order, linked by `order_id`). Your goal is to define a data contract so that consumers of your data know exactly what to expect.

## Start the Database

1. Start PostgreSQL with the preloaded data:

   ```
   docker compose up -d
   ```

2. Explore the data:

   ```
   docker compose exec postgres psql -U workshop -d workshop
   ```

   ```sql
   \dt orders_v1.*
   SELECT * FROM orders_v1.orders LIMIT 5;
   SELECT * FROM orders_v1.line_items LIMIT 5;
   ```

   You should see the two tables `orders` and `line_items`, and 5 rows of example data from each `SELECT`. If you get no output at all, check for typos — `psql` returns nothing for a misspelled schema or table name.

   The raw data is also available as JSON files in [`data/orders_v1/`](/data/orders_v1/).

## Create the Contract

3. Go to [editor.datacontract.com](https://editor.datacontract.com) and create a new data contract. Use the **Form** editor to get started.
   - Set the contract name to `Orders`, ID to `orders_v1`, version to `1.0.0`, and status to `draft`
4. Save the contract locally as `orders_v1.odcs.yaml` (use the save button on the top right) — this is the file you will keep updating and testing throughout the exercise
5. Set up the server connection: open **Servers** in the left navigation (or use the direct link [editor.datacontract.com/#/servers](https://editor.datacontract.com/#/servers)) and add a server with type `postgres`, host `localhost`, port `5433`, database `workshop`, schema `orders_v1`
6. Add the two schemas `orders` and `line_items` with all their properties and logical types.

   > **Hint:** Each property needs a `logicalType` (the abstract type like `string`, `integer`, `date`) and a `physicalType` (the actual database type like `text`, `bigint`, `timestamptz`). Here are the columns you should find:
   >
   > Schema `orders`:
   >
   > | Property | logicalType | physicalType |
   > |----------|-------------|--------------|
   > | `order_id` | `string` | `text` |
   > | `order_timestamp` | `date` | `timestamptz` |
   > | `order_total` | `integer` | `bigint` |
   > | `customer_id` | `string` | `text` |
   > | `customer_email_address` | `string` | `text` |
   >
   > Schema `line_items`:
   >
   > | Property | logicalType | physicalType |
   > |----------|-------------|--------------|
   > | `lines_item_id` | `string` | `text` |
   > | `order_id` | `string` | `text` |
   > | `sku` | `string` | `text` |

## Test the Contract

7. Save the contract again so `orders_v1.odcs.yaml` contains the server and schema changes
8. Run the tests with the Data Contract CLI (see [`scripts/install.sh`](/scripts/install.sh) for installation). The database credentials come from the `.env` file:

   ```
   cp .env.example .env
   set -a; source .env; set +a
   datacontract test orders_v1.odcs.yaml
   ```

9. Fix any wrong types and run the tests again
10. Verify tests can also fail: change `physicalType` of `customer_email_address` to `integer` (or remove a column), then run the tests again. Revert afterwards.

## Enrich the Contract

Make sure all tests pass before continuing, then:

11. Add a `description` with `purpose` (e.g., "Order data for analytics and reporting") and `limitations`
12. Add `tags`, e.g., `['orders', 'ecommerce']`
13. Mark `customer_email_address` with `classification: confidential` (it's PII)
14. Add `examples` for `customer_email_address` based on the data, e.g., `examples: ['test394@example.org']`
15. Make `customer_email_address` a required field: `required: true` — run the tests again

## Define Relationships

16. Add a `relationship` from `line_items.order_id` to `orders.order_id` to express the foreign key

    ```yaml
    relationships:
      - type: foreignKey
        to: orders.order_id
    ```

## Add Quality Checks

17. Add a SQL quality check to ensure that `customer_email_address` contains an `@` sign (find invalid rows):

    ```yaml
    quality:
      - type: sql
        description: Ensure email addresses are valid
        query: SELECT COUNT(*) FROM orders_v1.orders WHERE customer_email_address NOT LIKE '%@%';
        mustBe: 0
    ```

18. Add more constraints (if time allows):
    - Every `order_id` in `line_items` must exist in `orders`
    - `order_total` must be greater than or equal to 0
    - Think of your own additional constraints

    Reference for quality checks:

    ```yaml
    properties:
      - name: field
        quality:
          - type: text
            description: Ensure that ...
          - type: sql
            description: Ensure that ...
            query: SELECT COUNT(*) FROM ... WHERE ...;
            mustBe: 0
            # mustBeGreaterThan: 0
    ```

    Documentation: https://bitol-io.github.io/open-data-contract-standard/latest/#sql

## Add Ownership

19. Add a `team` and `support` channel:

    ```yaml
    team:
      name: order_data_team
      members:
        - username: owner@example.com
          role: Owner

    support:
      - channel: "#order-data-help"
        url: https://example.slack.com/archives/order-data-help
        tool: slack
    ```

## Add SLA Properties

20. Define service-level expectations:

    ```yaml
    slaProperties:
      - property: retention
        value: 1
        unit: y
        description: Order data retained for 1 year
      - property: frequency
        value: 1
        unit: d
        description: Data updated daily
    ```

## Publish

21. Your contract is complete — set `status` to `active` to publish it!

## Bonus

- Use the **export** command to create an HTML documentation of the data contract:
  ```
  datacontract export html orders_v1.odcs.yaml --output orders_v1.odcs.html
  ```
- Export to SQL DDL ([exports](https://cli.datacontract.com/#export)):
  ```
  datacontract export sql orders_v1.odcs.yaml
  ```
- Use the **catalog** command to create a data contract catalog:
  ```
  datacontract catalog
  ```
