/*******************************************************************
* Portfolio Project: CDISC SDTM/ADaM Pipeline
* Macro:             unsupp.sas
* Purpose:           Dynamically transpose SUPP-- dataset and merge 
*                    qualifier variables back into the parent domain.
* Usage:             %unsupp(domain=DM);
*                    %unsupp(domain=AE);
*******************************************************************/

%macro unsupp(domain=);

    %local dom suppdom keyvar;
    %let dom = %upcase(&domain);
    %let suppdom = SUPP&dom;

    /* 1. Determine key variable: DM uses USUBJID only; other domains use USUBJID + --SEQ */
    %if &dom = DM %then %let keyvar = usubjid;
    %else %let keyvar = usubjid &dom.seq;

    /* 2. Verify that the supplemental dataset exists in the SDTM library */
    %if %sysfunc(exist(sdtm.&suppdom)) %then %do;

        /* 3. Transpose long-form QNAM/QVAL into wide columns */
        proc transpose data=sdtm.&suppdom out=work.t_&suppdom(drop=_name_ _label_);
            by &keyvar;
            id qnam;
            idlabel qlabel;
            var qval;
        run;

        /* 4. Merge transposed supplemental variables back to parent domain */
        data sdtm.&dom;
            merge sdtm.&dom(in=parent) work.t_&suppdom;
            by &keyvar;
            if parent;
        run;

        /* 5. Clean up temporary work dataset */
        proc delete data=work.t_&suppdom; run;

    %end;
    %else %do;
        %put NOTE: [MACRO UNSUPP] Dataset sdtm.&suppdom does not exist. Skipping transpose.;
    %end;

%macroend unsupp;
