/*******************************************************************************
 * Program Name : 01_sdtm_ae.sas
 * Purpose      : Map Raw EDC AE records to CDISC SDTM AE Domain (v1.7)
 * Trial        : Daraxonrasib (RMC-6236) in RAS-Mutant mPDAC
 *******************************************************************************/

/* Load Configuration Paths */
%include "sas_code/config.sas";

data sdtm_ae;
    set raw_ae;
    
    /* 1. Identifiers */
    STUDYID = 'RMC-6236-001';
    DOMAIN  = 'AE';
    USUBJID = catx('-', STUDYID, SUBJ);
    
    /* 2. Topic Term Mapping */
    AETERM  = RAW_TERM;
    
    /* 3. ISO 8601 Date Formats */
    if not missing(START_DT) then AESTDTC = put(START_DT, yymmdd10.);
    if not missing(END_DT)   then AEENDTC = put(END_DT, yymmdd10.);
    
    /* 4. Toxicity Grade Mapping */
    AETOXGR = put(TOX_GR, best.);
run;
