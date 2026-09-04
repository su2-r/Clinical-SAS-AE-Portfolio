/* 1. Load Environment */
%include "sas_code/config.sas";

/* 2. Create the SDTM DM Dataset */
data sdtm.dm;
    set raw.demog; /* Reading the raw dataset */
    
    /* Hardcoded identifiers for the study */
    STUDYID = "DARAX-301";
    DOMAIN  = "DM";
    
    /* Deriving USUBJID by combining STUDYID and site subject number */
    USUBJID = catx('-', STUDYID, SUBJID);
    
    /* Standardizing Sex */
    if GENDER = "Male" then SEX = "M";
    else if GENDER = "Female" then SEX = "F";
    else SEX = "UNK";
    
run;
