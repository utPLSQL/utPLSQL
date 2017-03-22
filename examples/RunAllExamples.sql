PROMPT Run all examples
Clear Screen
set echo off
set feedback off
set linesize 1000

declare
  l_run_number  binary_integer;
begin
  dbms_profiler.start_profiler( run_number => l_run_number);
end;
/

-- Examples for users
@@RunUserExamples.sql

-- Framework developer examples
@@RunDeveloperExamples.sql

declare
  l_return_code binary_integer;
begin
  l_return_code := dbms_profiler.stop_profiler();
end;
/
