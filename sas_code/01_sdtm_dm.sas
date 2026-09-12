/************************************************************************
* Program:       01_sdtm_dm.sas
* Purpose:       Map RAW Demographic data to CDISC SDTM DM Domain
* Specification: docs/specs/SDTM_DM_Spec.xlsx (v1.0)
* Validation:    Double-programmed; Pinnacle 21 compliant
************************************************************************/

/* 1. Load Environment */
%include "sas_code/config.sas";

/* 2. Create the SDTM DM Dataset */
data sdtm.dm;
    set raw.demog; 
    
    /* Identifier Variables */
    STUDYID = "DARAX-301";
    DOMAIN  = "DM";
    USUBJID = catx('-', STUDYID, SUBJID);
    
    /* Standardizing Demographics */
    if GENDER = "Male" then SEX = "M";
    else if GENDER = "Female" then SEX = "F";
    else SEX = "UNK";
    
	/* ISO 8601 Date Conversions */
    if not missing(BRTHDT) then BIRTHDTC = put(BRTHDT, is8601da.);
    if not missing(DTC) then DMDTC = put(DTC, is8601da.);
run;
