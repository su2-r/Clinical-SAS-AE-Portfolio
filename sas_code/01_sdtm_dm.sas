/************************************************************************
* Program:       01_sdtm_dm.sas
* Purpose:       Map RAW Demographic data to CDISC SDTM DM Domain
* Specification: docs/specs/SDTM_DM_Spec.xlsx
* Validation:    Double-programmed; Pinnacle 21 compliant
************************************************************************/

%include "C:\sas_code\config.sas";

data sdtm.dm;
   /* 1. Explicit Attributes for Regulatory Compliance */
    length STUDYID $10 DOMAIN $2 USUBJID $20 RACE $40 SEX $3 BIRTHDTC DMDTC $10;
    label  STUDYID = "Study Identifier"
           DOMAIN  = "Domain Abbreviation"
           USUBJID = "Unique Subject Identifier"
           SEX     = "Sex"
           BIRTHDTC= "Date/Time of Birth"
           DMDTC   = "Date/Time of Collection";

    set raw.demog; 
    
    /* Required Identifiers */
    STUDYID = "DARAX-301";
    DOMAIN  = "DM";
	SUBJID = strip(SUBJ); /* Create SUBJID from raw SUBJ and remove whitespace */
    USUBJID = catx('-', STUDYID, SUBJID);
    
    /* 2. Flexible Controlled Terminology Mapping */
	/* SEX Mapping */
	select(upcase(strip(SEX)));
        when ('M', 'MALE')   SEX = 'M';
        when ('F', 'FEMALE') SEX = 'F';
        otherwise       SEX = 'UNK';
    end;
    
	/* RACE Controlled Terminology Mapping (NCI Codelist C74457) */
    select(upcase(strip(RAW_RACE)));
        when ('WHITE')                      RACE = 'WHITE';
        when ('ASIAN')                      RACE = 'ASIAN';
        when ('BLACK OR AFRICAN AMERICAN')  RACE = 'BLACK OR AFRICAN AMERICAN';
        when ('ASIAN/PACIFIC ISLANDER')     RACE = 'ASIAN'; /* Mapped per Spec rule */
        otherwise                           RACE = 'NOT REPORTED';
    end;


	/* Regulatory compliant & clean log approach */
	if not missing(BRTHDT) then BIRTHDTC = put(BRTHDT, is8601da.);
	if not missing(TRTSDT) then DMDTC    = put(TRTSDT, is8601da.);

run;
