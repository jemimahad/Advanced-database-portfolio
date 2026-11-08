# Portfolio 3: Transactions and Concurrency

## Overview
This portfolio uses the same Home of Fantasies database. I ran it on a local PostgreSQL 18 install, using pgAdmin 4, because showing a concurrency problem needs two database sessions open at the same time (one Query Tool tab per session). The scenario is stock control: placing an order must reduce a product's stock, and two customers must not be able to sell the same unit twice.

All SQL is in `transactions.sql`.

## 1. Commit
Placing an order is three changes that must succeed together: create the order, add the order item, and reduce stock. I wrapped them in one transaction:

`BEGIN;` → insert into `orders` → insert into `order_item` → `UPDATE product SET stock = stock - 2` → `COMMIT;`

Product 5 had stock 488 before and 486 after, and the order and its item row both exist. (Screenshots: `commit-stock-before.png`, `commit-stock-after.png`)

## 2. Rollback
**Rollback A (on purpose):** inside a transaction I reduced stock by 5, which showed the lower value inside the transaction. After `ROLLBACK;` the stock was back to its original value.

**Rollback B (a failed order):** I started an order for customer 2, then tried to reduce stock by 1000. The `CHECK (stock >= 0)` constraint from Portfolio 1 rejected it with an error. After `ROLLBACK;`, no order for customer 2 existed, so the half-finished order was never saved. (Screenshots: `rollback-a.png`, `rollback-b-error.png`)

This shows **atomicity**: an order is all-or-nothing. After the error, PostgreSQL marks the transaction as failed, so I had to roll back before running anything else.

## 3. The concurrency problem: lost update
I opened two sessions and both ran `BEGIN` and read the stock of product 5. Both saw **486**. Each then sold one unit, setting stock to 485 and committing.

Two units were sold, so the stock should have been 484, but it ended at **485**. The second session wrote a value based on a stale read, so one sale was lost. (Screenshot: `lost-update.png`)

PostgreSQL's default isolation level is **READ COMMITTED**. It only stops a session from reading uncommitted changes, so it does not prevent this problem when two sessions read first and write afterwards.

## 4. The fix: row locking with FOR UPDATE
I repeated the test, but each session read the stock with `SELECT ... FOR UPDATE`. Session 1 got the row lock first. Session 2's query then **waited**, and pgAdmin showed "Waiting for the query to complete" for almost three minutes. Once Session 1 set stock to 484 and committed, Session 2 continued and read the fresh value, **484**, then set it to 483.

Final stock was **483**, so both sales were counted. (Screenshots: `lock-waiting.png`, `lock-fixed.png`)

A later `UPDATE` in the waiting session took about 37 seconds for the same reason: it had to wait for the other session to release its lock.

## Analysis and trade-offs
- A **transaction** protects related changes so that they succeed or fail together.
- A **lost update** happens when two sessions read the same old value and both write back. The `CHECK` constraint helps protect data, but it cannot prevent this.
- `FOR UPDATE` fixes it by making the second session wait, so it works with the latest value. The cost is that sessions queue up, so it is important to keep locked transactions short, because long ones would slow down other customers.
- Another option would be a higher isolation level, such as REPEATABLE READ, which makes PostgreSQL abort the second update. The application would then have to retry. I used row locking because it is simpler for a stock counter.
- The `SERIAL` order number is not reused after a rollback, so rolled-back orders leave gaps in the numbering. That is normal.

## Files in this folder
- `transactions.sql`: all scripts for the four parts
- Screenshots: commit before and after, rollback A and B, lost update, lock waiting, and lock fixed

## AI Use Declaration
- **Tools used:** Claude (Anthropic).
