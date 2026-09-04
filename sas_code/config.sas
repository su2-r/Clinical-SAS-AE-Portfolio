/* ==================================================================== */
/* Program: config.sas                                                  */
/* Purpose: Global Environment Configuration & Library Definitions      */
/* ==================================================================== */

/* Root project directory */
%let root = %str(C:\Clinical_SAS_Portfolio); 

/* Define domain library references */
libname raw  "&root\raw_data";
libname sdtm "&root\outputs\sdtm";
libname adam "&root\outputs\adam";

/* Set system options for clean logs */
options nodate number linesize=120 pagesize=60;
