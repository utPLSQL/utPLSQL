CREATE OR REPLACE PACKAGE ut3_user.html_coverage_test IS

   -- Author  : LUW07
   -- Created : 23/05/2017 09:37:29
   -- Purpose : Supporting html coverage procedure

   -- Public type declarations
   PROCEDURE run_if_statment(o_result OUT NUMBER);
END HTML_COVERAGE_TEST;
/
CREATE OR REPLACE PACKAGE BODY ut3_user.html_coverage_test IS

   -- Private type declarations
   PROCEDURE run_if_statment(o_result OUT NUMBER) IS
      l_testedvalue NUMBER := 1;
      l_success     NUMBER := 0;
   BEGIN
      IF l_testedvalue = 1 THEN
         l_success := 1;
      END IF;
      
      o_result := l_success;
   END run_if_statment;
END HTML_COVERAGE_TEST;
/