/*******************************************************************
* Portfolio Project: CDISC SDTM/ADaM Pipeline
* Macro:             check_log.sas
* Purpose:           Automated clinical log scanner to verify log 
*                    cleanliness for audit and regulatory compliance.
* Usage:             %check_log(file=../../outputs/logs/11_adam_adsl.log);
*******************************************************************/

%macro check_log(file=);
    %local logfile;
    %let logfile = &file;

    /* 1. Verify file existence before opening */
    %if not %sysfunc(fileexist(&logfile)) %then %do;
        %put %str(ERR)OR: [CHECK_LOG] Target log file "&logfile" does not exist.;
        %return;
    %end;

    /* 2. Scan log file for regulatory flags */
    data _null_;
        infile "&logfile" lrecl=32767 truncover end=eof;
        input line $char1000.;
        retain err_cnt warn_cnt note_cnt 0;

        /* RegEx matching for critical clinical log issues */
        if prxmatch('/(ERROR:|WARNING:|NOTE: Uninitialized|NOTE: Numeric values have been converted|WANTING PATTERN)/i', strip(line)) then do;
            if prxmatch('/ERROR:/i', strip(line)) then err_cnt + 1;
            else if prxmatch('/WARNING:/i', strip(line)) then warn_cnt + 1;
            else note_cnt + 1;

            put "ATTENTION [LOG AUDIT]: " line;
        end;

        if eof then do;
            put "==================================================";
            put "LOG AUDIT SUMMARY FOR: &logfile";
            put "ERRORS FOUND:   " err_cnt;
            put "WARNINGS FOUND: " warn_cnt;
            put "NOTES/ISSUES:   " note_cnt;
            if err_cnt = 0 and warn_cnt = 0 then 
                put "STATUS: CLEAN - Log satisfies QC standards.";
            else 
                put "STATUS: ACTION REQUIRED - Review flagged entries above.";
            put "==================================================";
        end;
    run;
%macroend check_log;
