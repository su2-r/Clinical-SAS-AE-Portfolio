/* ==================================================================== */
/* Program: config.sas                                                  */
/* Purpose: Global Environment Configuration & Library Definitions      */
/* ==================================================================== */

/* Automatically create physical folders on disk if they do not exist */
options dlcreatedir;

/* Define Project Root directory */
%let root = %sysfunc(filename(root, ..));

/* Define domain library references */
libname raw  "&root/data/raw";
libname sdtm "&root/data/sdtm";
libname adam "&root/data/adam";

/* Set system options for clean logs */
options nodate number linesize=120 pagesize=60;
