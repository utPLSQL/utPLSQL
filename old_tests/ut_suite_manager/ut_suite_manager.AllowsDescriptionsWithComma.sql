set termout off
create or replace package tst_package_to_be_dropped as
  --%suite(A suite description, though with comma, is assigned by suite_manager)

  --%test(A test description, though with comma, is assigned by suite_manager)
  procedure test1;

  --%test
  --%displayname(A test description, though with comma, is assigned by suite_manager)
  procedure test2;
end;
/

create or replace package body tst_package_to_be_dropped as
  procedure test1 is begin ut.expect(1).to_equal(1); end;
  procedure test2 is begin ut.expect(1).to_equal(1); end;
end;
/

set termout on

set termout on

declare
  l_objects_to_run ut_suite_items;
  l_suite          ut_suite;
  l_test           ut_test;
  l_results        ut_expectation_results;
begin
  l_objects_to_run := ut_suite_manager.configure_execution_by_path(ut_varchar2_list('tst_package_to_be_dropped'));

  --Assert
  ut.expect(l_objects_to_run.count).to_equal(1);

  l_suite := treat(l_objects_to_run(1) as ut_suite);

  ut.expect(l_suite.name).to_equal('tst_package_to_be_dropped');
  ut.expect(l_suite.description).to_equal('A suite description, though with comma, is assigned by suite_manager');
  ut.expect(l_suite.items.count).to_equal(2);

  l_test := treat(l_suite.items(1) as ut_test);

  ut.expect(l_test.name).to_equal('test1');
  ut.expect(l_test.description).to_equal('A test description, though with comma, is assigned by suite_manager');

  l_test := treat(l_suite.items(2) as ut_test);

  ut.expect(l_test.name).to_equal('test2');
  ut.expect(l_test.description).to_equal('A test description, though with comma, is assigned by suite_manager');


  l_results := ut_expectation_processor.get_failed_expectations();

  :test_result := ut_utils.tr_success;
  for i in 1 .. l_results.count loop
    :test_result := greatest(:test_result, l_results(i).status);
     if l_results(i).status != ut_utils.tr_success then
      dbms_output.put_line(l_results(i).get_result_clob);
     end if;
  end loop;
end;
/

set termout off
drop package tst_package_to_be_dropped
/
set termout on
