/*******************************************************************
* Portfolio Project: CDISC SDTM/ADaM Pipeline
* Program:           11_adam_adsl.sas
* Program Type:      ADaM Core Dataset
* Purpose:           Produce Subject-Level Analysis Dataset (ADSL)
* SAS Version:       9.4
*******************************************************************/

/* 1. Environment & Utility Setup */
%include "../../config.sas";

/* 2. Process SDTM Demographics & Supplemental DM */
data dm0;
    set sdtm.dm;
run;

proc sort data=dm0; by usubjid; run;

data suppdm0;
    set sdtm.suppdm;
run;

proc sort data=suppdm0; by usubjid; run;

proc transpose data=suppdm0 out=t_suppdm0 (drop=_name_ _label_);
    by usubjid;
    id qnam;
    idlabel qlabel;
    var qval;
run;

data dm1;
    merge dm0 t_suppdm0;
    by usubjid;
run;

/* 3. Derive Reproductive Status from RP Domain */

data rp0;
    set sdtm.rp;
    where rptestcd = 'CHILDPOT';
    length childpot $200;
    childpot = strip(rpstresc);
    keep usubjid childpot;
run;

proc sort data=rp0; by usubjid; run;

data dm1_rp;
    merge dm1 (in=a) rp0;
    by usubjid;
    if a;
run;

/* 4. PDisposition & Discontinuation Logic (DS / SUPPDS) */
data suppds0;
    set sdtm.suppds;
    dsseq = input(idvarval, ?? best.);
run;

proc sort data=suppds0; by usubjid dsseq; run;

proc transpose data=suppds0 out=t_suppds0 (drop=_name_ _label_);
    by usubjid dsseq;
    id qnam;
    idlabel qlabel;
    var qval;
run;

data ds1;
    merge sdtm.ds t_suppds0;
    by usubjid dsseq;
run;

data eos eot_o eot_n;
    set ds1;
    if upcase(dsscat) = "STUDY DISCONTINUATION" then output eos;
    if upcase(dsscat) = "TREATMENT TERMINATION" and dsgrpid = "AIRIS-101" then output eot_o;
    if upcase(dsscat) = "TREATMENT TERMINATION" and dsgrpid = "NAB-PACLITAXEL" then output eot_n;
run;

data eos1;
    set eos;
    length eosstt $50 dcsreas dcsreasp $200;
    if not missing(dsstdc) then eosstt = "DISCONTINUED";
    else eosstt = "ONGOING";
    eosdt = input(dsstdc, ?? e8601da.);
    dcsreas = strip(dsdecod);
    if upcase(dsdecod) = "OTHER" then dcsreasp = strip(dsterm);
    if upcase(dsdecod) = "WITHDRAWAL BY PATIENT FROM STUDY" then icwthdt = eosdt;
    keep usubjid eosstt dcsreas dcsreasp icwthdt eosdt;
run;

data eot_o1;
    set eot_o;
    length eosstt_o $50 dctreas dctreasp $200;
    if not missing(dsstdc) then eosstt_o = "DISCONTINUED";
    dctreas = strip(dsdecod);
    if upcase(dsdecod) = "OTHER" then dctreasp = strip(dsterm);
    if not missing(dsstdc) and length(dsstdc) = 10 then eotdt = input(dsstdc, ?? e8601da.);
    keep usubjid eosstt_o dctreas dctreasp eotdt;
run;

data eot_n1;
    set eot_n;
    length eosstt_n $50 dctrsnb dctrnbsp $200;
    if not missing(dsstdc) then eosstt_n = "DISCONTINUED";
    dctrsnb = strip(dsdecod);
    if upcase(dsdecod) = "OTHER" then dctrnbsp = strip(dsterm);
    keep usubjid eosstt_n dctrsnb dctrnbsp;
run;

data eot1;
    merge eot_o1 eot_n1 eos1;
    by usubjid;
    length eotstt $50;
    if dctreas ne '' or dctrsnb ne '' then eotstt = "DISCONTINUED";
run;

/* 5. Exposure & Dose Limiting Toxicity (DLT) Evaluation (EX) */
data aristrt nabtrt;
    set sdtm.ex;
    where exstdy < 28;
    if upcase(extrt) = "AIRIS-101" then output aristrt;
    if upcase(extrt) = "NAB-PACLITAXEL" then output nabtrt;
run;

proc sql;
    create table aristrt1 as
    select usubjid, count(exdose) as cnt_o
    from aristrt
    where exdose > 0
    group by usubjid;
quit;

proc sql;
    create table nabtrt1 as
    select usubjid, count(exdose) as cnt_o
    from nabtrt
    where exdose > 0
    group by usubjid;
quit;

data ex2;
    merge aristrt1 nabtrt1;
    by usubjid;
    length dltevlfl $1;
    if cnt_o > 11 then dltevlfl = "Y";
run;

/* 6. Population Flags & Date Derivatives */
data dm2;
    set dm1_rp;

    /* Age Grouping */
    length agegr1 $10;
    if . < age < 65 then agegr1 = "< 65";
    else if age >= 65 then agegr1 = ">= 65";

    /* Standard Flags */
    length saffl enrlfl $1;
    saffl  = ifc(not missing(rfxstdtc), "Y", "N");
    enrlfl = ifc(upcase(armcd) ne "SCRNFAIL", "Y", "N");

    /* ISO Date Parsing */
    if length(rfxstdtc) >= 10 then trtsdt = input(substr(rfxstdtc,1,10), ?? e8601da.);
    if length(rfxendtc) >= 10 then trtedt = input(substr(rfxendtc,1,10), ?? e8601da.);
    if length(rficdtc)  >= 10 then rficdt = input(substr(rficdtc,1,10),  ?? e8601da.);
    if length(dthdtc)   >= 10 then dthdt  = input(substr(dthdtc,1,10),   ?? e8601da.);

    format trtsdt trtedt rficdt dthdt date9.;
run;

/* 7. Merge All Population & Disposition Derivatives */
data dm3;
    merge dm2 (in=a) eot1 ex2;
    by usubjid;
    if a;
    length pkevlfl $1;
    pkevlfl = saffl;
run;

/* 8. Assemble Final ADSL Dataset Attributes */
proc sql noprint;
    create table final_adsl as
    select
        studyid  length=200 label="Study Identifier",
        usubjid  length=200 label="Unique Subject Identifier",
        subjid   length=50  label="Subject Identifier for the Study",
        siteid   length=50  label="Study Site Identifier",
        age                 label="Age",
        ageu     length=50  label="Age Units",
        agegr1   length=10  label="Pooled Age Group 1",
        sex      length=2   label="Sex",
        childpot length=200 label="Child-Bearing Potential (if female)",
        race     length=100 label="Race",
        ethnic   length=100 label="Ethnicity",
        saffl    length=1   label="Safety Population Flag",
        enrlfl   length=1   label="Enrolled Population Flag",
        dltevlfl length=1   label="DLT Evaluable Population Flag",
        pkevlfl  length=1   label="PK Evaluable Population Flag",
        arm      length=200 label="Description of Planned Arm",
        armcd    length=50  label="Planned Arm Code",
        actarmcd length=50  label="Actual Arm Code",
        actarm   length=200 label="Description of Actual Arm",
        trtsdt              label="Date of First Exposure to Treatment" format=date9.,
        trtedt              label="Date of Last Exposure to Treatment" format=date9.,
        rficdt              label="Date of Informed Consent" format=date9.,
        dthdt               label="Date of Death" format=date9.,
        eosstt   length=50  label="End of Study Status",
        eosdt               label="End of Study Date" format=date9.,
        dcsreas  length=200 label="Reason for Discontinuation from Study",
        dcsreasp length=200 label="Reason Spec for Discont from Study",
        icwthdt             label="Date of Consent Withdrawal" format=date9.,
        eotstt   length=50  label="End of Treatment Status",
        eotdt               label="End of Treatment Date" format=date9.,
        dctreas  length=200 label="Reason for Discontinuation of Treatment",
        dctreasp length=200 label="Reason Specify for Discont of Treatment",
        dctrsnb  length=200 label="Reason for Discontinuation from Nab-Pac",
        dctrnBSP length=200 label="Reason Specify for Discont of Nab-Pac"
    from dm3;
quit;

/* 9. Output Final Dataset */
data adam.adsl (label="Subject-Level Analysis Dataset");
    set final_adsl;
run;
