# Data Catalog for Gold Layer

## Overview

The Gold Layer represents the business-level data model of the data warehouse.
It is structured to support analytical queries, reporting, and business intelligence use cases.

The Gold Layer follows a dimensional modeling approach consisting of:

- **Dimension Views**: Provide descriptive business entities such as customers and products.
- **Fact Views**: Store measurable business events such as sales transactions.

The Gold Layer is built on top of the cleansed and standardized **Silver Layer**.

---

## 1. gold.dim_customers

### Purpose

Stores customer information enriched with demographic and geographic attributes.
This view combines CRM customer data with ERP demographic and location data.

### Grain

One row represents **one unique customer**.

### Source Tables

- `silver.crm_cust_info`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| customer_key | BIGINT | Surrogate key uniquely identifying each customer within the Gold dimension. |
| customer_id | INT | Unique identifier of the customer from the CRM system. |
| customer_number | VARCHAR | Business identifier assigned to the customer. |
| first_name | VARCHAR | Customer's first name. |
| last_name | VARCHAR | Customer's last name. |
| country | VARCHAR | Customer's country of residence. |
| marital_status | VARCHAR | Customer's marital status. |
| gender | VARCHAR | Customer's gender. CRM is treated as the master source; ERP gender is used as a fallback when CRM contains `n/a`. |
| birthdate | DATE | Customer's date of birth. |
| create_date | DATE | Date when the customer record was created in the CRM system. |

### Transformation Logic

- `customer_key` is generated using `ROW_NUMBER()` and serves as a surrogate key.
- Customer master data is sourced from `silver.crm_cust_info`.
- Geographic information is enriched from `silver.erp_loc_a101`.
- Demographic information is enriched from `silver.erp_cust_az12`.
- CRM is considered the master source for gender.
- ERP gender is used only when the CRM gender value is `n/a`.
- Missing gender values are standardized to `n/a`.

---

## 2. gold.dim_products

### Purpose

Stores the current product catalog enriched with product category and
subcategory information.

Historical product records are excluded so that the dimension represents
the **currently active product records**.

### Grain

One row represents **one current product**.

### Source Tables

- `silver.crm_prd_info`
- `silver.erp_px_cat_g1v2`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| product_key | BIGINT | Surrogate key uniquely identifying each product within the Gold dimension. |
| product_id | INT | Unique identifier of the product from the CRM system. |
| product_number | VARCHAR | Business identifier assigned to the product. |
| product_name | VARCHAR | Name of the product. |
| category_id | VARCHAR | Identifier of the product category. |
| category | VARCHAR | Product category. |
| subcategory | VARCHAR | Product subcategory. |
| maintenance | VARCHAR | Product maintenance classification. |
| cost | INT | Cost associated with the product. |
| product_line | VARCHAR | Product line or product type classification. |
| start_date | DATE | Date when the current product record became effective. |

### Transformation Logic

- `product_key` is generated using `ROW_NUMBER()` and serves as a surrogate key.
- Product information is sourced from `silver.crm_prd_info`.
- Category information is enriched from `silver.erp_px_cat_g1v2`.
- Only the current product records are retained using:
  `WHERE prd_end_dt IS NULL`.
- Historical product records are excluded from the Gold dimension.

---

## 3. gold.fact_sales

### Purpose

Stores sales transaction data and connects sales transactions to the
customer and product dimensions.

This fact view provides the measurable business events used for sales
analysis and reporting.

### Grain

One row represents **one sales line item**.

### Source Tables

- `silver.crm_sales_details`
- `gold.dim_products`
- `gold.dim_customers`

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| order_number | VARCHAR | Sales order number identifying the customer order. |
| product_key | BIGINT | Surrogate key referencing `gold.dim_products`. |
| customer_key | BIGINT | Surrogate key referencing `gold.dim_customers`. |
| order_date | DATE | Date when the sales order was placed. |
| shipping_date | DATE | Date when the order was shipped. |
| due_date | DATE | Expected delivery or due date of the order. |
| sales_amount | DECIMAL | Total sales amount associated with the sales line. |
| quantity | INT | Quantity of products sold. |
| price | DECIMAL | Unit selling price of the product. |

### Transformation Logic

- Sales transaction data is sourced from `silver.crm_sales_details`.
- `product_key` is resolved by joining the sales product number with
  `gold.dim_products.product_number`.
- `customer_key` is resolved by joining the sales customer ID with
  `gold.dim_customers.customer_id`.
- Dimension surrogate keys are used instead of source-system business keys
  in the fact table.
- Sales measures such as `sales_amount`, `quantity`, and `price` are retained
  for analytical calculations.

---

## 4. Gold Layer Relationships

The Gold Layer follows a star-schema structure where the sales fact is
connected to the customer and product dimensions.

```text
                    gold.dim_customers
                           |
                           | customer_key
                           |
                           v
                    gold.fact_sales
                           ^
                           |
                           | product_key
                           |
                    gold.dim_products
