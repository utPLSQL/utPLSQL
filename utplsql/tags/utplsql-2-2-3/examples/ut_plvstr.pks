CREATE OR REPLACE PACKAGE ut_plvstr
IS
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
 
   -- For each program to test...
   PROCEDURE ut_BETWN1;
END ut_plvstr;
/
