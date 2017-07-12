-- set termout off
-- create or replace package tests as
--   procedure dummy;
-- end;
-- /
-- set termout on

declare
  l_expected ut_object_names;
  l_actual   ut_object_names;
begin
  l_expected := ut_object_names(
    ut_object_name(user,'TEST_PACKAGE_1'),
    ut_object_name(user,'TEST_PACKAGE_2'),
    ut_object_name(user,'TEST_PACKAGE_3'),
    ut_object_name(user,'TEST_REPORTERS_1'),
    ut_object_name(user,'TEST_REPORTERS')
  );
  l_actual := ut_suite_manager.get_schema_ut_packages(ut_varchar2_list(user));
  if l_actual = l_expected then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line('actual:'||xmltype(anydata.convertcollection(l_actual)).getclobval());
    dbms_output.put_line('expected:'||xmltype(anydata.convertcollection(l_expected)).getclobval());
  end if;
end;
/

-- set termout off
-- drop package tests
-- /
-- set termout on
--
