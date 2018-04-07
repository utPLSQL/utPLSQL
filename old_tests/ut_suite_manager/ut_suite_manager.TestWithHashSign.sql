set termout off
create or replace package tst_package_with_hash_test as
  --%suite

  --%test
  procedure test#1;
end;
/

create or replace package body tst_package_with_hash_test as
  procedure test#1 is begin ut.expect(1).to_equal(1); end;
end;
/

set termout on

declare
  l_objects_to_run ut_suite_items;
  l_suite          ut_suite;
  l_test           ut_test;
begin

  --act
  l_objects_to_run := ut_suite_manager.configure_execution_by_path(ut_varchar2_list('tst_package_with_hash_test.test#1'));
  
  --Assert
  ut.expect(l_objects_to_run.count).to_equal(1);

  l_suite := treat(l_objects_to_run(1) as ut_suite);

  ut.expect(l_suite.name).to_equal('tst_package_with_hash_test');
  ut.expect(l_suite.items.count).to_equal(1);

  l_test := treat(l_suite.items(1) as ut_test);

  ut.expect(l_test.name).to_equal('test#1');

  if ut_expectation_processor.get_status = ut_utils.gc_success then
    :test_result := ut_utils.gc_success;
  end if;

end;
/

drop package tst_package_with_hash_test
/
