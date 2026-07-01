# BankPro-Analysis-Project
## BankPro Financial Services – SAS Analytics Case Study
This repository contains an end-to-end SAS analytics pipeline designed to ingest, cleanse, transform, and model data from fragmented business systems at BankPro Financial Services. The primary goal is to simulate an enterprise data warehouse workflow—turning raw operational ledgers into audit-ready datasets, forecasting liquidity trends, and delivering automated business intelligence reports to executive stakeholders.

## Repository Structure
The project files uploaded to this repository represent a complete analytical lifecycle package:

financial_project_dataset.xlsx – The raw input database workbook provided by BankPro containing isolated operational tracking sheets: Customers, Accounts, Transactions, and MonthlySummary.

BankPro.sas – The complete, monolithic SAS analytical script containing all processing modules (from initial ingestion and type conversion to matrix array operations and automation macros).

BankPro_Case_Study_Documentation.docx – Comprehensive structural narrative report detailing the business challenges solved, engineering specifications, and architectural choices.

BankPro_Analysis_Report.pdf – Executive Business Intelligence portfolio generated dynamically using the SAS Output Delivery System (ODS PDF) with advanced formatting.

BankPro_management_Report.xlsx – Multi-tab production management ledger featuring frozen panels and structured aggregations, built entirely using automated ODS programming.

## Core Analytics Pipeline Lifecycle
The underlying SAS script executes a continuous pipeline structured across the following architectural stages:

### 1. Data Ingestion & Transformation
Establishes a permanent library environment (FINANCE) and extracts messy raw sheets. Converts unstandardized character date arrays into numeric, mathematically valid SAS date values using the INPUT function paired with yymmdd10. boundaries.

### 2. Data Cleansing & Risk Profiling
Implements risk identification parameters to isolate negative credit positions (flagging accounts as Overdrawn or Active). Segments client tiers into high-value classifications based on dynamic balance thresholds.

### 3. Text Optimization & Behavioral Mining
Applies character functions (PROPCASE, CATX, SUBSTR) to eliminate manually keyed data entries and build unified consumer profiles. Uses the LAG function inside sorted BY-group processing data blocks to track transaction velocity and identify account dormancy indicators.

### 4. Forecasting & Array Sweeping
Compound Interest Projection: Runs a parameterized DO loop (months 0 to 12) simulating forward asset appreciation to generate an accurate liquidity trend baseline.

Horizontal Matrix Scanning: Leverages a 6-element numeric array (Jan through Jun) paired with the SCAN function to horizontally inspect ledger balances, instantly surfacing peak performance periods and volatile revenue dips per account.

### 5. Database Integration & Professional BI
Maintains strict multi-key matching rules via PROC SORT to execute structural joins, creating a unified 360-degree consumer data hub. The pipeline automates summary generation using custom macro frameworks (%SummaryReport) and validates internal logic checks using native pass-through PROC SQL groupings. All outputs are directly compiled via the SAS ODS framework into your final executive Word, PDF, and Excel artifacts.
