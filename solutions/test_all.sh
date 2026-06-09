#!/bin/bash
# Rechecks the reference solutions sequentially, exercise by exercise.
set -e
cd "$(dirname "$0")/.."

export DATACONTRACT_POSTGRES_USERNAME=workshop
export DATACONTRACT_POSTGRES_PASSWORD=workshop

ODCS_SCHEMA=https://raw.githubusercontent.com/bitol-io/open-data-contract-standard/main/schema/odcs-json-schema-v3.1.0.json
ODPS_SCHEMA=https://raw.githubusercontent.com/bitol-io/open-data-product-standard/main/schema/odps-json-schema-latest.json

check_odcs() {
  echo "=== Checking $1 ==="
  datacontract lint "$1"
  uvx check-jsonschema --schemafile "$ODCS_SCHEMA" "$1"
}

check_odps() {
  echo "=== Validating $1 ==="
  uvx check-jsonschema --schemafile "$ODPS_SCHEMA" "$1"
}

psql_file() {
  docker compose exec -T postgres psql -U workshop -d workshop -v ON_ERROR_STOP=1 < "$1"
}

echo "### Exercise 1: contract for orders_v1"
check_odcs solutions/exercise1/orders_v1.odcs.yaml
datacontract test solutions/exercise1/orders_v1.odcs.yaml

echo "### Exercise 2: contract for orders_v2"
check_odcs solutions/exercise2/orders_v2.odcs.yaml
datacontract test solutions/exercise2/orders_v2.odcs.yaml

echo "### Exercise 3: data product for orders"
check_odps solutions/exercise3/orders.odps.yaml

echo "### Exercise 4: design contract + data product for sku_sales (contract-first, not implemented yet)"
check_odcs solutions/exercise4/sku_sales_per_year.odcs.yaml
check_odps solutions/exercise4/sku_sales_per_year.odps.yaml

echo "### Exercise 5: implement the view, tests turn green"
psql_file solutions/exercise5/sku_sales_per_year.sql
datacontract test solutions/exercise4/sku_sales_per_year.odcs.yaml

echo "### Exercise 6: consumer-driven contract + input views, rebase the product view"
check_odcs solutions/exercise6/orders_v2.consumer_sku_sales.odcs.yaml
psql_file solutions/exercise6/sku_sales_input.sql
psql_file solutions/exercise6/sku_sales_per_year.sql
datacontract test solutions/exercise6/orders_v2.consumer_sku_sales.odcs.yaml
datacontract test solutions/exercise4/sku_sales_per_year.odcs.yaml

if [ -n "$ENTROPY_DATA_API_KEY" ]; then
  echo "### Exercise 7: publish to Entropy Data"
  ./solutions/exercise7/publish.sh
else
  echo "### Exercise 7: skipped (set ENTROPY_DATA_API_KEY and ENTROPY_DATA_HOST to publish)"
fi

echo "All checks passed."
