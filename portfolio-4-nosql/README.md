# Portfolio 4: NoSQL and Advanced Data Models

## Overview
This portfolio models the Home of Fantasies store in **MongoDB**, a document database, running locally and used through MongoDB Compass and its shell. I chose a document model for the parts of the business where the relational design from Portfolio 1 was awkward: the product catalogue and the order record. All commands are in `mongo-commands.js`.

## The document model
**`products` collection:** one document per product. Each product has its own `attributes` object:
- Lamp: `wattage`, `bulbType`, `colour`
- Pillowcase set: `size`, `material`, `threadCount`, `colours`
- Rug: `diameterCm`, `material`, `washable`
- Candle: `scent`, `burnHours`, `weightG`

The supplier is embedded inside each product, and `tags` is an array.

**`orders` collection:** one document per order. The customer, shipping address, items and payment are all **embedded** in the order document, so a single read returns the complete order.

## Implementation and queries
1. **Nested field query:** `db.products.find({ "attributes.material": "cotton" })` returned the pillowcase set. (`query-nested-material.jpg`)
2. **Filter with projection:** products under 30, showing only name and price: the pillowcase set (18.9) and the candle (12.5). (`query-price-under-30.jpg`)
3. **Query on an embedded customer field:** `db.orders.find({ "customer.country": "Nigeria" })` returned order HOF-1001 with all its items, payment and shipping address in one document. (`query-orders-nigeria-1.jpg`, `query-orders-nigeria-2.jpg`)
4. **Update:** `$inc` reduced the candle's stock by 3, leaving 197. (`update-stock.jpg`)
5. **Aggregation:** `$unwind` splits each order into its items, `$group` totals units sold and revenue per product, and `$sort` ranks them. The candle came first with 7 units and 87.5 revenue, then the lamp (2 units, 69), the rug (1 unit, 45) and the pillowcase set (1 unit, 18.9). (`aggregation-revenue.jpg`)

## Why a document database suits this data
- **Products with different attributes.** A lamp, bedding and a rug need different fields. In PostgreSQL I would need many mostly-empty columns or extra attribute tables. In MongoDB each product just carries its own fields, and I can still query inside them.
- **Orders as one unit.** An order is always read as a whole (customer, items, payment, address). Embedding them avoids joining several tables for every order page.
- **Flexible growth.** If a new product type needs new fields, there is no schema change.

## Trade-offs compared with the relational design
- **Duplication.** Item names and prices are copied into each order. That is deliberate, because an order should keep the price that was paid, as I also did with `unit_price` in `order_item` in Portfolio 1. The downside is that a product name change would not update old orders.
- **No enforced relationships.** MongoDB does not check that an order item's `sku` exists in `products`, so the application has to keep them consistent. The foreign keys and `CHECK` constraints in PostgreSQL are stronger here.
- **Consistency across several records.** Stock control, with its commit, rollback and row locks in Portfolio 3, is better handled in PostgreSQL.
- **Conclusion.** The best design for this store would use both: PostgreSQL for orders, payments and stock, where correctness matters most, and MongoDB for the flexible product catalogue.

## Files in this folder
- `mongo-commands.js`: all commands
- `query-nested-material.jpg`, `query-price-under-30.jpg`, `query-orders-nigeria-1.jpg`, `query-orders-nigeria-2.jpg`, `update-stock.jpg`, `aggregation-revenue.jpg`: screenshots of each result

## AI Use Declaration
- **Tools used:** Claude (Anthropic).
