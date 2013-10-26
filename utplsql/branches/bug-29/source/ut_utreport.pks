CREATE OR REPLACE PACKAGE UT_UTREPORT 
AS

  PROCEDURE ut_setup;
  PROCEDURE ut_teardown;
  
  PROCEDURE ut_check_report_facade;
  
END;
/