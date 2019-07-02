create or replace package body expectations as

  --%test(Expectations return data to screen when called standalone)

  procedure inline_expectation_to_dbms_out is
    l_expected         sys_refcursor;
    l_actual           sys_refcursor;
    l_output           dbmsoutput_linesarray;
    l_results          ut3.ut_varchar2_list;
    l_lines            number := 10000;
  begin
    --Arrange
    ut3_tester_helper.main_helper.clear_ut_run_context;
    open l_expected for
      select 'FAILURE' as out_row from dual union all
      select 'Actual: 1 (number) was expected to equal: 0 (number)' from dual union all
      select 'SUCCESS' from dual union all
      select 'Actual: 0 (number) was expected to equal: 0 (number)' from dual union all
      select '' from dual;
    --Act
    ut3.ut.expect(1).to_equal(0);
    ut3.ut.expect(0).to_equal(0);

    --Assert
    dbms_output.get_lines(lines => l_output, numlines => l_lines);
    open l_actual for select trim(column_value) as out_row from table(l_output);

    ut.expect(l_actual).to_equal(l_expected);
  end;
end;
/