# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

![Data Architecture](Docs/data_architecture.png)

- **Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
- **Silver Layer:** This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
- **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.

---

## Project Overview

This project involves:
- **Data Architecture:** Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.
- **ETL Pipelines:** Extracting, transforming, and loading data from source systems into the warehouse.
- **Data Modeling:** Developing fact and dimension tables optimized for analytical queries.
- **Analytics & Reporting:** Creating SQL-based reports and dashboards for actionable insights.

---

## Key Capabilities Demonstrated

This repository showcases expertise in:
- SQL Development
- Data Architecture
- Data Engineering
- ETL Pipeline Development
- Data Modeling
- Data Analytics

---

## Tools & Technologies Used

- **Database:** SQL Server Express / SSMS (SQL Server Management Studio)
- **Version Control:** Git & GitHub
- **Diagrams & Modeling:** Draw.io
- **Documentation:** Markdown

---

## Project Requirements

### Building the Data Warehouse (Data Engineering)
- **Data Sources:** Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only; historization of data is not required.
- **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.

### BI: Analytics & Reporting (Data Analysis)
Develop SQL-based analytics to deliver detailed insights into:
- Customer Behavior
- Product Performance
- Sales Trends

---

## Repository Structure

```text
sql-data-warehouse-project/
│
├── Datasets/                           # Raw datasets used for the project (ERP and CRM data)
├── Docs/                               # Project documentation and architecture details
├── Scripts/                            # SQL scripts for ETL and transformations
├── Tests/                              # Test scripts and quality files
├── LICENSE                             # License information for the repository
└── README.md                           # Project overview and instructions
