SET TERMOUT OFF
SET VERIFY OFF
SET PAGESIZE 0
SET FEEDBACK OFF
SET TRIMSPOOL ON

SET DEFINE ON
TTITLE OFF
SET SERVEROUTPUT ON SIZE 1000000 FORMAT WRAPPED

SET TERMOUT ON
PROMPT &line1
PROMPT DROPPING &UT PACKAGES
PROMPT &line1

drop package UTASSERT2;
drop package UTASSERT;
drop package UTCONFIG;
drop package UTGEN;
drop package UTOUTCOME;
drop package UTOUTPUT;
drop package UTPACKAGE;
drop package UTPLSQL2;
drop package UTPLSQL;
drop package UTPLSQL_UTIL;
drop package UTRECEQ;
drop package UTRERROR;
drop package UTREPORT;
drop package UTOUTPUTREPORTER;
drop package UTFILEREPORTER;
drop package UTRESULT2;
drop package UTRESULT;
drop package UTROUTCOME;
drop package UTRSUITE;
drop package UTRTESTCASE;
drop package UTRUNITTEST;
drop package UTRUTP;
drop package UTSUITE;
drop package UTSUITEUTP;
drop package UTTEST;
drop package UTTESTCASE;
drop package UTTESTPREP;
drop package UTUNITTEST;
drop package UTUTP;

drop package UT_UTOUTPUT;

SET TERMOUT ON
PROMPT &line1
PROMPT DROPPING &UT PUBLIC SYNONYMS
PROMPT &line1

drop public synonym UTASSERT2;
drop public synonym UTASSERT;
drop public synonym UTCONFIG;
drop public synonym UTGEN;
drop public synonym UTOUTCOME;
drop public synonym UTOUTPUT;
drop public synonym UTPACKAGE;
drop public synonym UTPLSQL2;
drop public synonym UTPLSQL;
drop public synonym UTPLSQL_UTIL;
drop public synonym UTRECEQ;
drop public synonym UTRERROR;
drop public synonym UTRESULT2;
drop public synonym UTRESULT;
drop public synonym UTROUTCOME;
drop public synonym UTRSUITE;
drop public synonym UTRTESTCASE;
drop public synonym UTRUNITTEST;
drop public synonym UTRUTP;
drop public synonym UTR_ERROR;
drop public synonym UTR_OUTCOME;
drop public synonym UTR_SUITE;
drop public synonym UTR_TESTCASE;
drop public synonym UTR_UNITTEST;
drop public synonym UTR_UTP;
drop public synonym UTSUITE;
drop public synonym UTSUITEUTP;
drop public synonym UTTEST;
drop public synonym UTTESTCASE;
drop public synonym UTTESTPREP;
drop public synonym UTUNITTEST;
drop public synonym UTUTP;
drop public synonym UT_ARGUMENT;
drop public synonym UT_ASSERTION;
drop public synonym UT_CONFIG;
drop public synonym UT_DETERMINISTIC;
drop public synonym UT_DETERMINISTIC_ARG;
drop public synonym UT_EQ;
drop public synonym UT_GRID;
drop public synonym UT_OUTCOME;
drop public synonym UT_PACKAGE;
drop public synonym UT_RECEQ;
drop public synonym UT_RECEQ_PKG;
drop public synonym UT_SUITE;
drop public synonym UT_SUITE_UTP;
drop public synonym UT_TEST;
drop public synonym UT_TESTCASE;
drop public synonym UT_TESTPREP;
drop public synonym UT_UNITTEST;
drop public synonym UT_UTOUTPUT;
drop public synonym UT_UTP;
drop public synonym UTPLSQL_RUNNUM_SEQ;
drop public synonym UT_ASSERTION_SEQ;
drop public synonym UT_PACKAGE_SEQ;
drop public synonym UT_RECEQ_SEQ;
drop public synonym UT_REFCURSOR_RESULTS_SEQ;
drop public synonym UT_SUITE_SEQ;
drop public synonym UT_TESTCASE_SEQ;
drop public synonym UT_TEST_SEQ;
drop public synonym UT_UNITTEST_SEQ;
drop public synonym UT_UTP_SEQ;
drop public synonym UTV_LAST_RUN;
drop public synonym UTV_RESULT_FULL;

SET TERMOUT ON
PROMPT &line1
PROMPT DROPPING &UT SEQUENCES
PROMPT &line1

drop sequence UTPLSQL_RUNNUM_SEQ;
drop sequence UT_ASSERTION_SEQ;
drop sequence UT_PACKAGE_SEQ;
drop sequence UT_RECEQ_SEQ;
drop sequence UT_REFCURSOR_RESULTS_SEQ;
drop sequence UT_SUITE_SEQ;
drop sequence UT_TESTCASE_SEQ;
drop sequence UT_TEST_SEQ;
drop sequence UT_UNITTEST_SEQ;
drop sequence UT_UTP_SEQ;

SET TERMOUT ON
PROMPT &line1
PROMPT DROPPING &UT VIEWS
PROMPT &line1

drop view utv_last_run;
drop view utv_result_full;

SET TERMOUT ON
PROMPT &line1
PROMPT DROPPING &UT TABLES
PROMPT &line1

drop table UTR_ERROR cascade constraints;
drop table UTR_OUTCOME cascade constraints;
drop table UTR_SUITE cascade constraints;
drop table UTR_TESTCASE cascade constraints;
drop table UTR_UNITTEST cascade constraints;
drop table UTR_UTP cascade constraints;
drop table UT_ARGUMENT cascade constraints;
drop table UT_ASSERTION cascade constraints;
drop table UT_CONFIG cascade constraints;
drop table UT_DETERMINISTIC cascade constraints;
drop table UT_DETERMINISTIC_ARG cascade constraints;
drop table UT_EQ cascade constraints;
drop table UT_GRID cascade constraints;
drop table UT_OUTCOME cascade constraints;
drop table UT_PACKAGE cascade constraints;
drop table UT_RECEQ cascade constraints;
drop table UT_RECEQ_PKG cascade constraints;
drop table UT_SUITE cascade constraints;
drop table UT_SUITE_UTP cascade constraints;
drop table UT_TEST cascade constraints;
drop table UT_TESTCASE cascade constraints;
drop table UT_TESTPREP cascade constraints;
drop table UT_UNITTEST cascade constraints;
drop table UT_UTP cascade constraints;

