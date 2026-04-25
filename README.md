# 🛒 E-Commerce Database System — PostgreSQL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL%20%2F%20PL%2FpgSQL-orange)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)


A fully normalised relational database system for an online store, built with **PostgreSQL**. The project covers schema design, data integrity, automated business logic via triggers, and analytical SQL queries for reporting.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [Features](#features)
- [Analytical Queries](#analytical-queries)
- [Sample Data](#sample-data)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Skills Demonstrated](#skills-demonstrated)

---

## Project Overview

This project simulates a real-world e-commerce platform database managing:

- Product catalogue with hierarchical categories
- Customer accounts and shipping addresses
- Order lifecycle (pending → confirmed → shipped → delivered)
- Payment tracking (eSewa, Khalti, credit card, PayPal, COD)
- Customer product reviews and ratings

The schema satisfies **Third Normal Form (3NF)** and uses foreign key constraints, check constraints, indexes, views, and PL/pgSQL triggers to enforce data integrity and automate business rules.

---

## Database Schema

### Entity Relationship Overview

```
category ──< product ──< order_item >── orders >── payment
                  └──< review                │
customer ──────────────────────────────────>─┘
    └──< address >── orders
```

### Tables

| Table        | Description                                      |
|--------------|--------------------------------------------------|
| `category`   | Hierarchical product categories                  |
| `customer`   | Registered customers                             |
| `address`    | Customer shipping addresses                      |
| `product`    | Product catalogue with stock and pricing         |
| `orders`     | Customer orders with status tracking             |
| `order_item` | Line items per order                             |
| `payment`    | Payment records per order                        |
| `review`     | Customer ratings and comments per product        |

---

## Features

### ✅ Schema Design
- Normalised to 3NF with no data redundancy
- Primary keys, foreign keys, and `CHECK` constraints on all tables
- `UNIQUE` constraints on email, SKU
- Self-referencing `parent_id` in `category` for subcategory support

### ⚡ Triggers & Functions (PL/pgSQL)
- **`trg_update_order_total`** — Automatically recalculates `total_amount` in `orders` whenever an order item is inserted or updated
- **`trg_reduce_stock`** — Automatically reduces product `stock_qty` when an order status changes from `pending` to `confirmed`

### 📊 Views
- **`vw_order_summary`** — Joins orders, customers, and payments for a complete order report
- **`vw_product_sales`** — Aggregates units sold, revenue, and average rating per product

### 🔍 Indexes
- Indexes on all foreign key columns and frequently queried fields (`status`, `category_id`, `order_id`)

---

## Analytical Queries

Five business-intelligence queries are included:

| # | Query | Purpose |
|---|-------|---------|
| 1 | Top 5 products by revenue | Identify best sellers |
| 2 | Monthly revenue report | Track sales trends over time |
| 3 | Top customers by spending | Loyalty and segmentation |
| 4 | Low stock alert (< 20 units) | Inventory management |
| 5 | Average rating by category | Product quality insights |

---

## Sample Data

The database is pre-loaded with realistic data:

| Entity      | Records | Notes                                      |
|-------------|--------:|--------------------------------------------|
| Categories  | 8       | 4 top-level + 4 subcategories              |
| Customers   | 5       | With addresses across Nepal                |
| Products    | 10      | Electronics, Clothing, Books, Home & Garden|
| Orders      | 8       | Mix of statuses including cancelled        |
| Order Items | 17      | Multiple items per order                   |
| Payments    | 8       | eSewa, Khalti, credit card, COD, PayPal    |
| Reviews     | 5       | Ratings 4–5 with comments                  |

---

## Getting Started

### Prerequisites

- [PostgreSQL 15+](https://www.postgresql.org/download/)
- psql CLI or [pgAdmin 4](https://www.pgadmin.org/)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/ecommerce-db-postgresql.git
cd ecommerce-db-postgresql

# 2. Create the database
psql -U postgres -c "CREATE DATABASE ecommerce_db;"

# 3. Run the schema file
psql -U postgres -d ecommerce_db -f schema.sql
```

### Verify Setup

```sql
-- List all tables
\dt ecommerce.*

-- Check sample data
SELECT * FROM ecommerce.vw_order_summary;
SELECT * FROM ecommerce.vw_product_sales;
```

---

## Project Structure

```
ecommerce-db-postgresql/
│
├── schema.sql                          # Full schema: tables, indexes, triggers, views, queries
├── Ecommerce_DB_Project_Documentation.docx  # Detailed project documentation
└── README.md                           # This file
```

---

## Skills Demonstrated

- **Relational Database Design** — ER modelling, normalisation (1NF → 3NF)
- **PostgreSQL** — DDL, DML, constraints, sequences, schemas
- **PL/pgSQL** — Stored functions and row-level triggers
- **Query Optimisation** — Indexes, query planning awareness
- **Business Intelligence** — Aggregation, grouping, analytical reporting
- **Documentation** — Technical writing and project documentation

---

## Author

**Rijan**  
IT Officer & Computing Student  
📍 Kathmandu, Nepal  
🔗 [GitHub](https://github.com/YOUR_USERNAME)

---

*This project was built as part of a portfolio to demonstrate database engineering skills for professional and academic purposes.*
