create or replace package ut3$user#.html_coverage_test is

   -- Author  : LUW07
   -- Created : 23/05/2017 09:37:29
   -- Purpose : Supporting html coverage procedure

   -- Public type declarations
   procedure run_if_statment(o_result out number);
end html_coverage_test;
/
create or replace package body ut3$user#.html_coverage_test is

   -- Private type declarations
   procedure run_if_statment(o_result out number) is
      l_testedvalue number := 1;
      l_success     number := 0;
   begin
      if l_testedvalue = 1 then
         l_success := 1;
      end if;

      o_result := l_success;
   end run_if_statment;
end html_coverage_test;
/
