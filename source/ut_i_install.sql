SET TERMOUT OFF
SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF 
SET TTITLE OFF

SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED
SET DEFINE ON
SPOOL ut_i_install.log

----------------------------------------------------TABLES
SET TERMOUT ON
PROMPT &line1
PROMPT CREATING &UT TABLES
PROMPT &line1

DEFINE prompt_text='Creating &UT tables '

@@ut_i_tables

----------------------------------------------------SEQUENCES
SET TERMOUT ON
PROMPT &line1
PROMPT CREATING &UT SEQUENCES
PROMPT &line1

DEFINE prompt_text='Creating &UT sequence '

@@ut_i_sequences

----------------------------------------------------VIEWS
SET TERMOUT ON
PROMPT &line1
PROMPT CREATING &UT VIEWS
PROMPT &line1

DEFINE prompt_text='Creating &UT view '

@@ut_i_views

----------------------------------------------------PACKAGE HEADERS
SET TERMOUT ON
PROMPT &line1
PROMPT CREATING OUNIT PACKAGE HEADERS
PROMPT &line1

DEFINE prompt_text='Creating &UT package specification '

@@ut_i_packages

----------------------------------------------------PACKAGE BODIES
SET TERMOUT ON
PROMPT &line1
PROMPT CREATING OUNIT PACKAGE BODIES
PROMPT &line1

DEFINE prompt_text='Creating &UT package body '

@@ut_i_packages_b

SET TERMOUT OFF
SPOOL OFF

----------------------------------------------------GENERIC SCRIPTS

@@ut_i_synonyms

@@ut_i_grants
