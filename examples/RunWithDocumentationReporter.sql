Set Serveroutput On Size Unlimited format truncated
set linesize 10000
set echo off

create or replace package demo_doc_reporter1 is
  -- %suite(Demo of documentation reporter)
  -- %test(A passing test sample)
  procedure passing_test;
  -- %test
  procedure test_without_name;
  -- %test(A failing test exsample)
  procedure failing_test;
  -- %test
  procedure failing_no_name;
  -- %test(repoting exception)
  procedure failing_exception_raised;
end;
/

create or replace package body demo_doc_reporter1 is

  procedure passing_test is begin null; end;

  procedure test_without_name is
  begin
    ut.expect(1).to_(equal(1));
  end;

  procedure failing_test is
  begin
    ut.expect(1).to_(equal(2));
  end;
  procedure failing_no_name is
  begin
    ut.expect(sysdate).to_(equal(to_char(sysdate)));
  end;
  procedure failing_exception_raised is
    l_date date;
  begin
    l_date := to_date('abcd');
  end;
end;
/

create or replace package demo_doc_reporter2 is
  -- %suite(A suite pacakge without body)
  -- %test(A test)
  procedure passing_test1;
  -- %test
  procedure passing_test2;
end;
/

create or replace package suite_package_without_name is
  -- %suite
  -- %test(A passing test sample)
  procedure passing_test1;
  -- %test(A passing test sample)
  procedure passing_test2;
end;
/

create or replace package body suite_package_without_name is

  procedure passing_test1 is begin null; end;

  procedure passing_test2 is
  begin
    ut.expect(1).to_(equal(1));
  end;
end;
/

begin
  ut_suite_manager.run_cur_schema_suites_static(ut_documentation_reporter(), a_force_parse_again => true);
end;
/


drop package demo_doc_reporter2;
drop package suite_package_without_name;
drop package demo_doc_reporter1;
