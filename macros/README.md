# Reusable SAS Utility Macros

This directory contains modular, project-wide utility macros designed to support SDTM/ADaM domain generation and QC log auditing.

## Macro Standards
- **Explicit Scoping:** All macro variables must be explicitly scoped using `%LOCAL`.
- **Log Hygiene:** Macros must execute with 0 errors, 0 warnings, and 0 implicit conversion notes.
- **Header Documentation:** Every macro file must contain a header detailing parameters, inputs, outputs, and usage examples.
