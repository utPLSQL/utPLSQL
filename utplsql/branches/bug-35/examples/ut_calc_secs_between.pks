CREATE OR REPLACE PACKAGE ut_calc_secs_between
IS
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
 
   -- For each program to test...
   PROCEDURE ut_CALC_SECS_BETWEEN;
END ut_calc_secs_between;
/
