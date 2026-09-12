/************************************************************************
* Program:       01_sdtm_dm.sas
* Purpose:       Map RAW Demographic data to CDISC SDTM DM Domain
* Specification: docs/specs/SDTM_DM_Spec.xlsx
* Validation:    Double-programmed; Pinnacle 21 compliant
************************************************************************/

/* 1. Environment Setup */
%include "sas_code/config.sas";

/* 2. SDTM DM Transformation */
data sdtm.dm;
    set raw.demog; 
    
    /* Required Identifier */
    STUDYID = "DARAX-301";
    DOMAIN  = "DM";
    USUBJID = catx('-', STUDYID, SUBJID);
    
    /* Controlled Terminology Mapping */
	select(upcase(GENDER));
        when ('MALE')   SEX = 'M';
        when ('FEMALE') SEX = 'F';
        otherwise       SEX = 'UNK';
    end;
    
	/* ISO 8601 Character Date Conversions */
	if not missing(BRTHDT) then do;
    /* Convert character 'MM/DD/YYYY' to numeric date, then reformat to character ISO 8601 */
    _num_brthdt = input(strip(BRTHDT), mmddyy10.);
    BIRTHDTC    = put(_num_brthdt, is8601da.);
	end;

	if not missing(DTC) then do;
    _num_dtc = input(strip(DTC), mmddyy10.);
    DMDTC    = put(_num_dtc, is8601da.);
	end;
	drop _num_brthdt _num_dtc;
run;
