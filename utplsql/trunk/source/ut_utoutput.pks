CREATE OR REPLACE PACKAGE ut_utoutput
IS
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
 
   -- For each program to test...
   PROCEDURE ut_count;
   PROCEDURE ut_extract;
   PROCEDURE ut_nextline;
   PROCEDURE ut_replace;
   PROCEDURE ut_saving;
   
END ut_utoutput;
/
