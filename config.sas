/* ==================================================================== */
/* Program: config.sas                                                  */
/* Purpose: Global Environment Configuration & Library Definitions      */
/* ==================================================================== */

/* Automatically create physical folders on disk if they do not exist */
options dlcreatedir;

/* Define Project Root directory */
%let root = C:\Github_Project_2027; 

/* Define domain library references */
libname raw  "&root\raw_data";
libname sdtm "&root\outputs\sdtm";
libname adam "&root\outputs\adam";

/* Set system options for clean logs */
options nodate number linesize=120 pagesize=60;
