# Clinical SAS Portfolio: Adverse Events (AE) Data Pipeline

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![SAS Version](https://img.shields.io/badge/SAS-9.4-orange.svg)](#requirements)
<!-- Add CI / coverage badges here when available -->

## Project Summary
An end-to-end Clinical SAS programming pipeline for processing, deriving, validating, and reporting Adverse Event (AE) safety data following CDISC standards (SDTM $\rightarrow$ ADaM). This repository includes production SAS code, reusable macros, mapping specifications, QC logs, and submission-ready TFL outputs (`ADAE` / `ADAET`).

**Clinical Trial Context:** Phase 3 trial evaluating **Daraxonrasib (RMC-6236)** in subjects with RAS-mutant Metastatic Pancreatic Ductal Adenocarcinoma (mPDAC).

## Table of contents
- [Objectives](#objectives)
- [Quick start](#quick-start)
- [Requirements](#requirements)
- [Repository structure](#repository-structure)
- [Pipeline overview](#pipeline-overview)
- [Running the code](#running-the-code)
- [Validation & QC](#validation--qc)
- [Data & privacy](#data--privacy)
- [Contributing](#contributing)
- [License & citation](#license--citation)
- [Contact](#contact)

## Objectives
- Map raw safety data to SDTM AE structure and derive analysis-ready ADaM AE datasets (`ADAE`, `ADAET`).
- Derive treatment-emergent flags, analysis-day variables (ASTDY/AENDY), and severity/relationship classifications.
- Produce submission-style tables, listings, and figures (TFLs) with validation logs and reconciliation output.

## Quick start
1. Clone the repository:
   git clone https://github.com/su2-r/Clinical-SAS-AE-Portfolio.git
2. Prepare your configuration (see `specs/` and `sas_code/config.sas`).
3. Run the main script (example):
   sas sas_code/run_adae.sas -log outputs/run_adae.log

(See [Running the code](#running-the-code) for more details and examples.)

## Requirements
- SAS 9.4 (or later) with appropriate components to run DATA steps and PROC REPORT.
- Optional: access to a Unix/Windows shell for batch runs.
- Example datasets in `raw_data/` (not included in this repo for privacy reasons).
- Recommended: an environment or container for reproducible runs (documented CI later if available).

## Repository structure
- `raw_data/` — raw input datasets used as source (placeholders / sample CSVs).
- `specs/` — variable mappings, CDISC mapping tables, data dictionaries, and derivation rules.
- `sas_code/` — SAS programs, macros, and validation scripts.
  - `sas_code/macros/` — reusable macros (e.g., TEAE flagging, date handling).
  - `sas_code/run_adae.sas` — orchestration script to generate ADAE/ADAET outputs.
- `outputs/` — generated logs (`.log`), SAS datasets, TFLs, and QC reports.
- `docs/` — design notes and derivation rules (optional).
- `README.md` — this file.

## Pipeline overview
1. Data ingestion & SDTM standardization
   - Map raw AE records to SDTM AE domain according to SDTM v1.7.
2. ADaM dataset construction (ADAE)
   - Use SDTM AE + ADSL to derive analysis variables:
     - TRTEMFL: treatment-emergent flag.
     - ASTDY/AENDY: day variables relative to `TRTSDT`.
     - Severity / relationship mappings (MedDRA SOC/PT).
3. Validation & QC
   - Independent double-programming and reconciliation of results.
4. Reporting
   - Generate submission-ready summary tables and listings using `PROC REPORT` and macros.

## Running the code
Example run (batch):
- Linux/Windows command line:
  sas sas_code/run_adae.sas -log outputs/run_adae.log

Inside SAS (interactive):
- %include 'sas_code/config.sas';
- %include 'sas_code/run_adae.sas';

Notes:
- Update `sas_code/config.sas` (or similar) with paths to raw datasets, the ADSL dataset, and output folders before running.
- Tests: run `sas_code/run_validation.sas` to produce reconciliation tables comparing production vs. validation programs.

## Validation & QC
- The repository includes double-programming validation scripts that:
  - Compare derived variables row-wise between primary and validation programs.
  - Output reconciliation reports and summaries to `outputs/qc/`.
- Aim for exact numeric and character reconciliation; document known tolerances (e.g., rounding).

## Data & privacy
- This repo contains no real patient data. If you add real clinical data, ensure compliance with local privacy rules and remove PHI/identifiers prior to committing.
- Prefer synthetic or anonymized sample data in `raw_data/` for examples.

## Contributing
- Contributions are welcome. Suggested workflow:
  1. Fork the repo and create a feature branch.
  2. Add/modify SAS programs or specs and include tests or example datasets when possible.
  3. Open a pull request describing changes and QC evidence.
- Add coding standards in `CONTRIBUTING.md` for macros, style, and QC requirements.

## License & citation
- Add a `LICENSE` file (e.g., MIT or repository-appropriate license).
- Suggested citation (if used in a portfolio or report): include title, author, year, and GitHub URL.

## Contact
- Repository owner: su2-r
- For questions or issues: open a GitHub Issue or contact via the repo.

## Roadmap / To do
- Add small sample synthetic datasets for quick demos.
- Add a CI workflow to run linting / basic tests (if possible).
- Add a `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `CHANGELOG.md`.
