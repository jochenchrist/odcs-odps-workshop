# Exercise 6: Consumer-Driven Data Contracts

A consumer-driven data contract lets the *consumer* define what subset of data they need and what quality they expect. This enables the producer to understand actual usage and avoid breaking real consumers.

**Scenario:** The **controlling team** needs order totals for financial reporting. They don't care about line items or customer emails — they only need `order_id` and `order_total`, and they require every order total to be greater than 0.

## Create the Consumer Contract

1. Copy your data contract from [Exercise 2](../part-a/exercise2-data-contract-evolution.md) to `orders_v2.consumer_controlling.odcs.yaml` and open it in the [Data Contract Editor](https://editor.datacontract.com) (use the hamburger menu to load files). Set the ID to `orders_v2_consumer_controlling` and the version to `1.0.0`.
2. The controlling team is only interested in `order_id` and `order_total` from the `orders` object. Remove the `line_items` object entirely and remove all other properties from `orders` except `order_id` and `order_total`.
3. The consumer requires orders to have an `order_total` greater than 0. Add this as a quality check.
4. Run the tests and make sure they pass:

   ```
   export DATACONTRACT_POSTGRES_USERNAME=workshop
   export DATACONTRACT_POSTGRES_PASSWORD=workshop
   datacontract test orders_v2.consumer_controlling.odcs.yaml
   ```

## Bonus

- Use the Data Contract CLI to generate an SQL view that does the projection from the provider-driven contract, so the consumer only works on their subset:

  ```
  datacontract export --format sql-query orders_v2.consumer_controlling.odcs.yaml
  ```

  Save the result to `consumer-view.sql`.
