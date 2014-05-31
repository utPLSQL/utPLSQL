CREATE OR REPLACE PACKAGE BODY ut_truncit
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      EXECUTE IMMEDIATE 
         'CREATE TABLE temp_emp AS SELECT * FROM employee';
   END;
   
   PROCEDURE ut_teardown
   IS
   BEGIN
      EXECUTE IMMEDIATE 
         'DROP TABLE temp_emp';
   END;

   -- For each program to test...
   PROCEDURE ut_TRUNCIT IS
   BEGIN
      TRUNCIT (
            TAB => 'temp_emp'
            ,
            SCH => USER
       );

      utAssert.eq (
         'Test of TRUNCIT',
         tabcount (USER, 'temp_emp'),
         0
         );
   END ut_TRUNCIT;

END ut_truncit;
/
