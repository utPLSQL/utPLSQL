CREATE OR REPLACE PACKAGE ut_str
IS
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
 
   -- For each program to test...
   PROCEDURE ut_betwn;
   PROCEDURE ut_betwn2;
END ut_str;
/
