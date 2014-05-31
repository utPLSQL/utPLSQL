CREATE OR REPLACE PACKAGE BODY ut_calc_secs_between
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      NULL;
   END;
   
   PROCEDURE ut_teardown
   IS
   BEGIN
      NULL;
   END;

   -- For each program to test...
   PROCEDURE ut_CALC_SECS_BETWEEN 
   IS
      secs PLS_INTEGER;
   BEGIN
      CALC_SECS_BETWEEN (
            DATE1 => SYSDATE
            ,
            DATE2 => SYSDATE
            ,
            SECS => secs
       );

      utAssert.eq (
         'Same dates',
         secs, 
         0
         );
         
      CALC_SECS_BETWEEN (
            DATE1 => SYSDATE
            ,
            DATE2 => SYSDATE+1
            ,
            SECS => secs
       );

      utAssert.eq (
         'Exactly one day',
         secs, 
         24 * 60 * 60
         );
         
   END ut_CALC_SECS_BETWEEN;

END ut_calc_secs_between;
/
