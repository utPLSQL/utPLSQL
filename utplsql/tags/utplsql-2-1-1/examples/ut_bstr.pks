CREATE OR REPLACE PACKAGE ut_bstr
IS
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
 
   -- For each program to test...
   PROCEDURE ut_BETWNSTR;
END ut_bstr;
/
