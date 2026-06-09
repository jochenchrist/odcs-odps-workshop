# Exercise 6: Publish to Entropy Data

YAML files in a git repository work well for a single team — but how do *other* teams discover your data products, browse the contracts, and request access? For that you need a data product platform. In this exercise, you publish everything you built in Part A and Part B to [Entropy Data](https://entropy-data.com) using the [Entropy Data CLI](https://github.com/entropy-data/entropy-data-cli).

## Get Access

1. Log in at [app.entropy-data.com](https://app.entropy-data.com) — your trainers will provide an invitation to the workshop organization.
2. Create an API key in the organization settings.
3. Install the Entropy Data CLI:

   ```
   uv tool install entropy-data
   entropy-data --version
   ```

4. Configure the connection. Create a `.env` file in the repository root (it is gitignored, and the CLI picks it up automatically):

   ```bash
   # .env
   ENTROPY_DATA_API_KEY=ed_...
   ENTROPY_DATA_HOST=https://api.entropy-data.com
   ```

   Verify the connection:

   ```
   entropy-data connection test
   ```

## Publish Your Data Contracts

5. Publish all three data contracts. The ID argument must match the `id` field inside the contract:

   ```
   entropy-data datacontracts put orders_v1 --file orders_v1.odcs.yaml
   entropy-data datacontracts put orders_v2 --file orders_v2.odcs.yaml
   entropy-data datacontracts put sku_sales_per_year --file sku_sales_per_year.odcs.yaml
   ```

6. Check that they are there:

   ```
   entropy-data datacontracts list
   ```

## Publish Your Data Products

Entropy Data natively supports ODPS, so you can publish your data product files as they are.

7. Publish both data products. The ID argument must match the `id` field inside your ODPS file:

   ```
   entropy-data dataproducts put orders --file orders.odps.yaml
   entropy-data dataproducts put sku_sales --file sku_sales_per_year.odps.yaml
   ```

8. Check that they are there:

   ```
   entropy-data dataproducts list
   ```

## Explore the Platform

9. Open [app.entropy-data.com](https://app.entropy-data.com) and explore what the platform made out of your YAML files:
   - Find your two data products and their output ports
   - Open the `sku_sales_per_year` contract and compare it with the editor view
   - Follow the **input port** of the SKU Sales product — the dependency you declared in Exercise 4 is now a navigable link between the two data products
   - Look at your colleagues' data products: how would you find a data product about SKUs if you didn't know it existed?

## Publish Test Results

10. The platform shows whether a contract is *currently* upheld — if you feed it test results. Run your local tests again and publish the results:

    ```
    export ENTROPY_DATA_API_KEY=ed_...
    export DATACONTRACT_POSTGRES_USERNAME=workshop
    export DATACONTRACT_POSTGRES_PASSWORD=workshop
    datacontract test sku_sales_per_year.odcs.yaml --publish https://api.entropy-data.com/api/test-results
    ```

    Find the test results on the contract page in the UI.

## Discuss

11. Discuss with your neighbor:
    - What is the source of truth now — the YAML files in git, or the platform? Which one *should* it be?
    - In Exercise 5 you played through a breaking change via the support channel. Which parts of that process could the platform automate?

## Bonus

- Keep git as the source of truth: explore `entropy-data datacontracts import-from-git --help` and think about how you would wire this up in a CI/CD pipeline
- Publish test results automatically on every push: have a look at `datacontract ci --help`
