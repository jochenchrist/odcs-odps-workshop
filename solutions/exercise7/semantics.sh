#!/bin/bash
# Bonus: create the semantic concepts and relationships (requires the Semantics feature).
set -e
cd "$(dirname "$0")"
if [ -f ../../.env ]; then set -a; . ../../.env; set +a; fi

printf 'name: Main\n' | entropy-data semantics namespaces put main --file -

printf 'name: Order\nkind: entity\ndescription: A customer order in the e-commerce platform\n' \
  | entropy-data semantics concepts put main order --file -
printf 'name: Order ID\nkind: shared_property\ndescription: Unique identifier of an order (UUID)\ndata_type: string\n' \
  | entropy-data semantics concepts put main order_id --file -
printf 'name: Order Total\nkind: shared_property\ndescription: Total amount of an order in cents, never negative\ndata_type: integer\n' \
  | entropy-data semantics concepts put main order_total --file -

printf 'name: Article\nkind: entity\ndescription: A product that can be bought in the e-commerce platform\n' \
  | entropy-data semantics concepts put main article --file -
printf 'name: SKU\nkind: shared_property\ndescription: Stock keeping unit, the unique identifier of an article\ndata_type: string\n' \
  | entropy-data semantics concepts put main sku --file -

printf 'type: hasProperty\nroles:\n- concept: order\n- concept: order_id\n' \
  | entropy-data semantics relationships put main order-has-order-id --file -
printf 'type: hasProperty\nroles:\n- concept: order\n- concept: order_total\n' \
  | entropy-data semantics relationships put main order-has-order-total --file -
printf 'type: hasProperty\nroles:\n- concept: article\n- concept: sku\n' \
  | entropy-data semantics relationships put main article-has-sku --file -

# link the concepts from the data contract via authoritativeDefinitions (type: semantics)
# and re-publish it; duplicated text descriptions are removed - the definition lives in the concept
datacontract lint orders_v2.with-semantics.odcs.yaml
entropy-data datacontracts put orders_v2 --file orders_v2.with-semantics.odcs.yaml
