--Arrange
create or replace package test_disabled_suite as
  --%suite
  --%disabled
  gv_glob_val number := 0;
  --%beforeall
  procedure before_all;
  --%test
  procedure test1;
  --%test
  procedure test2;
end;
/

declare
  l_lines    ut_varchar2_list;
  l_results  clob;
begin
--Act
  select * bulk collect into l_lines from table(ut.run('test_disabled_suite'));

  l_results := ut_utils.table_to_clob(l_lines);

--Assert
  ut.expect(l_results).to_be_like('%test1 [0 sec] (IGNORED)%');
  ut.expect(l_results).to_be_like('%test2 [0 sec] (IGNORED)%');
  ut.expect(l_results).to_be_like('%2 tests, 0 failed, 0 errored, 2 disabled, 0 warning(s)%');

  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    dbms_output.put_line(
      xmltype(
        anydata.convertcollection(
          ut_expectation_processor.get_failed_expectations()
        )
      ).getclobval()
    );
  end if;
end;
/

drop package test_disabled_suite
/
