# ADAE Mapping Specification (Oncology - Metastatic Pancreatic Cancer)

## Target Dataset: ADAE (Analysis Data Model - Adverse Events)
Study Context: Phase 3 RASolute Trial / Daraxonrasib (RMC-6236) in RAS-Mutant mPDAC
Source Datasets: SDTM.AE, ADaM.ADSL

| Target Variable | Variable Label | Source Domain / Variable | Derivation / Mapping Logic |
| :--- | :--- | :--- | :--- |
| `STUDYID` | Study Identifier | `SDTM.AE.STUDYID` | Direct copy from source AE dataset. |
| `USUBJID` | Unique Subject Identifier | `SDTM.AE.USUBJID` | Direct copy. Key merge variable with `ADSL`. |
| `ASTDT` | Analysis Start Date | `SDTM.AE.AESTDTC` | Convert ISO 8601 character date (`YYYY-MM-DD`) to numeric SAS date using `INPUT(SUBSTR(AESTDTC,1,10), YYMMDD10.)`. Impute partial dates (1st of month). |
| `ASTDY` | Analysis Start Relative Day | Derived | If `ASTDT >= TRTSDT` then `ASTDY = ASTDT - TRTSDT + 1`. If `ASTDT < TRTSDT` then `ASTDY = ASTDT - TRTSDT`. |
| `TRTEMFL` | Treatment-Emergent Flag | Derived | Set to `'Y'` if `ASTDT >= TRTSDT` and `ASTDT <= TRTEDT + 30`. Otherwise set to `'N'`. |
| `ATOXGR` | Analysis Toxicity Grade | `SDTM.AE.AETOXGR` | Numeric CTCAE Grade (1-5) derived from clinical source data (e.g., Grade 3+ Rash or Stomatitis). |
| `CQ01NAM` | Custom Query: RAS Inhibitor AE | `SDTM.AE.AEDECOD` | Set to `'RAS-TARGETED SKIN TOXICITY'` if `AEDECOD` in ('RASH', 'DERMATITIS', 'STOMATITIS') and subject received Daraxonrasib. |
