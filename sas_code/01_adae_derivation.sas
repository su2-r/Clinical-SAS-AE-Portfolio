/************************************************************************
* Program: 01_adae_derivation.sas
* Purpose: Import raw AE data and derive Treatment-Emergent Flag (TRTEMFL)
* Project: Clinical SAS AE Portfolio
************************************************************************/

/* Step 1: Import Raw AE Data */
proc import datafile="../raw_data/raw_ae.csv"
    out=work.raw_ae
    dbms=csv
    replace;
    getnames=yes;
run;

/* Step 2: Date Conversion & ADaM Derivations */
data adam.adae;
    set work.raw_ae;

    /* Sample  date format */
      format TRTSDT date9.;

    /* Convert ISO Character Date (AESTDTC) to Numeric SAS Date (AESTDT) */
    if length(AESTDTC) >= 10 then AESTDT = input(AESTDTC, yymmdd10.);
    format AESTDT date9.;

    /* Derive Treatment-Emergent Flag (TRTEMFL) */
    if AESTDT >= TRTSDT or (AESTDT < TRTSDT and TOX_GR >= 3) then TRTEMFL = 'Y';
    else TRTEMFL = 'N';
run;
