CREATE OR REPLACE PACKAGE ut_truncit
IS
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
 
   -- For each program to test...
   PROCEDURE ut_TRUNCIT;
END ut_truncit;
/
