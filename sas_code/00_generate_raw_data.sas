/*******************************************************************************
 * Program Name : 00_generate_raw_data.sas
 * Purpose      : Generate Synthetic Raw Data (300 subjects) for Daraxonrasib Trial
 * Trial        : Daraxonrasib (RMC-6236) in RAS-Mutant mPDAC
 *******************************************************************************/

/* Load paths */
%include "config.sas";

/* 1. Generate Raw Demographics (raw.demog) */
data raw.demog;
    length SUBJ $10 SEX $1 ARMCD $10;
    format BRTHDT RANDDT TRTSDT yymmdd10.;
    
    call streaminit(12345); /* Fixed seed for reproducibility */
    
    do i = 1 to 300;
        SUBJ = put(1000 + i, z4.);
        
        /* Age distribution: 40 to 85 years */
        age_yrs = round(40 + rand("Uniform") * 45);
        BRTHDT  = intnx('year', '15JAN2026'd, -age_yrs);
        
        /* Gender: ~55% Male, 45% Female */
        if rand("Uniform") > 0.45 then SEX = 'M';
        else SEX = 'F';
        
        /* 1:1 Randomization: DARAX vs PBO */
        if rand("Uniform") > 0.5 then ARMCD = 'DARAX';
        else ARMCD = 'PBO';
        
        /* Randomization & Dosing Dates */
        RANDDT = '01JAN2026'd + round(rand("Uniform") * 60);
        
        /* 5% Screen Failures (no dose date) */
        if rand("Uniform") > 0.05 then TRTSDT = RANDDT + round(rand("Uniform") * 3);
        else TRTSDT = .;
        
        output;
    end;
    drop i age_yrs;
run;

/* 2. Generate Raw Adverse Events (raw_ae) with Edge Cases */
data raw.ae;
    length SUBJ $10 RAW_TERM $100 TOX_GR 8 AESTDTC AEENDTC $10;
    call streaminit(67890);
    
    /* Array of common mPDAC / RAS-inhibitor AEs */
    array terms [5] $50 ('Stomatitis' 'Rash maculo-papular' 'Diarrhea' 'Fatigue' 'Nausea');
    
    set raw.demog(keep=SUBJ TRTSDT);
    where not missing(TRTSDT); /* Dosed subjects only for AE records */
    
    /* Each subject experiences between 1 and 6 AE records */
    num_aes = ceil(rand("Uniform") * 6);
    
    do j = 1 to num_aes;
        term_idx = ceil(rand("Uniform") * 5);
        RAW_TERM = terms[term_idx];
        
        /* CTCAE Toxicity Grade 1 to 5 */
        TOX_GR = ceil(rand("Uniform") * 4); /* Mostly Grades 1-4 */
        if rand("Uniform") < 0.02 then TOX_GR = 5; /* Rare Grade 5 event */
        
        /* Event Start Date relative to Treatment Start Date */
        st_date = TRTSDT + round(rand("Uniform") * 90) - 10; /* Some pre-treatment */
        
        /* Edge Case 1: Partial Dates (Missing Day) */
        if rand("Uniform") < 0.08 then AESTDTC = put(st_date, yymm7.);
        else AESTDTC = put(st_date, yymmdd10.);
        
        /* Event End Date */
        end_date = st_date + ceil(rand("Uniform") * 14);
        
        /* Edge Case 2: Ongoing Events (Missing End Date) */
        if rand("Uniform") < 0.15 then AEENDTC = "";
        else AEENDTC = put(end_date, yymmdd10.);
        
        output;
    end;
    drop j num_aes term_idx st_date end_date;
run;

/* Export synthetic raw data to CSV in raw_data folder */
proc export data=raw.demog
    outfile="&root/raw_data/raw_demog.csv"
    dbms=csv replace;
run;

proc export data=raw.ae
    outfile="&root/raw_data/raw_ae.csv"
    dbms=csv replace;
run;
