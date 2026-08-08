/************************************************************************
* Program: 02_ae_summary_table.sas
* Purpose: Generate Summary Table of Treatment-Emergent Adverse Events (TRTEMFL)
* Project: Clinical SAS AE Portfolio
************************************************************************/

/* Step 1: Execute ADaM Derivation Script */
%include "../sas_code/01_adae_derivation.sas";

/* Step 2: Calculate AE Frequencies by Severity for Treatment-Emergent AEs */
proc freq data=work.adae noprint;
    where TRTEMFL = 'Y';
    tables AESEV / out=work.ae_summary(drop=percent);
run;

/* Step 3: Format and Display Safety Summary Report */
title1 "Table 14.2.1: Summary of Treatment-Emergent Adverse Events by Severity";
proc report data=work.ae_summary nowd;
    column AESEV count;
    define AESEV / display "Adverse Event Severity";
    define count / display "Number of Events (n)";
run;
title1;
