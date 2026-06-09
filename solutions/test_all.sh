#!/bin/bash
set -e
export DATACONTRACT_POSTGRES_USERNAME=workshop
export DATACONTRACT_POSTGRES_PASSWORD=workshop

# create the analytics view from exercise 3
docker compose exec -T postgres psql -U workshop -d workshop -v ON_ERROR_STOP=1 < solutions/sku_sales_per_year.sql

for f in solutions/*.odcs.yaml; do
  echo "=== Testing $f ==="
  datacontract test "$f"
  echo ""
done

for f in solutions/*.odps.yaml; do
  echo "=== Validating $f ==="
  uvx check-jsonschema --schemafile https://raw.githubusercontent.com/bitol-io/open-data-product-standard/main/schema/odps-json-schema-latest.json "$f"
  echo ""
done
