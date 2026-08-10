# Clinical SAS Portfolio: Adverse Events (AE) Data Pipeline

## 📌 Executive Summary
This repository contains a end-to-end Clinical SAS programming project focusing on processing, analyzing, and reporting **Adverse Events (AE)** data in accordance with CDISC standards.

## 🎯 Objectives
- Transform raw clinical trial safety data into standard CDISC SDTM / ADaM dataset structures (`ADAET` / `ADAE`).
- Derive clinical variables such as Treatment-Emergent Adverse Events (TEAE), treatment onset days, and severity levels.
- Generate standard summary tables and validation logs for Quality Control (QC).

## 📁 Repository Structure
- `/raw_data`: Source clinical datasets used for analysis.
- `/specs`: Data mapping specifications and variable data dictionaries.
- `/sas_code`: Production SAS scripts, macros, and double-programming validation programs.
- `/outputs`: Generated execution logs (`.log`), output summaries, and TFL reports.

## 🛠️ Standards & Tools Used
- **CDISC Standards:** SDTM v1.7 / ADaM v2.1 (`ADAE` implementation model)
- **Language:** SAS 9.4 (DATA step processing, PROC REPORT, PROC FREQ, SAS Macros)

---

## 📖 Extended Project Description

### Clinical Context & Study Design
In clinical trials, monitoring safety and tracking adverse events (AEs) is essential for evaluating patient risk profiles and regulatory compliance. This project simulates an end-to-end clinical data processing pipeline based on a randomized, multi-center safety evaluation trial. Raw clinical data collected across subject visits is standardized into CDISC-compliant models to enable accurate safety reporting for regulatory submissions (e.g., FDA/EMA).

### Pipeline Workflow & Methodology
1. **Data Ingestion & SDTM Standardization:** Raw subject-level records and event logs are mapped into the SDTM Adverse Events (`AE`) domain structure following CDISC SDTM v1.7 guidelines.
2. **ADaM Dataset Construction (`ADAE`):** Utilizing SDTM source inputs and Subject Level Analysis Data (`ADSL`), the pipeline derives key analysis variables including:
   - **Treatment-Emergent Flags (`TRTEMFL`):** Logic identifying whether an event started or worsened on or after the first dose date.
   - **Timing & Relative Days (`ASTDY`, `AENDY`):** Standardized start and end day calculations relative to the treatment initiation date (`TRTSDT`).
   - **Severity & Relationship Classifications:** Processing coded terminology (e.g., MedDRA System Organ Class and Preferred Terms).
3. **Validation & Quality Control (QC):** Implements independent double-programming logic to compare primary execution logs against validation datasets, ensuring 100% data reconciliation, zero SAS syntax warnings/errors, and complete audit readiness.
4. **Reporting & TFL Output Generation:** Produces submission-ready Summary Tables and Listings using `PROC REPORT` and custom SAS macros, highlighting Treatment-Emergent Adverse Events (TEAEs) broken down by severity and causal relationship. 
