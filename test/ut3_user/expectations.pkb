create or replace package body expectations as

  procedure inline_expectation_to_dbms_out is
    l_expected         sys_refcursor;
    l_actual           sys_refcursor;
    l_output           dbmsoutput_linesarray;
    l_results          ut3.ut_varchar2_list;
    l_lines            number := 10000;
    pragma autonomous_transaction;
  begin
    --Arrange
    --Act
    execute immediate 'begin some_pkg.some_procedure; end;';
    ut3.ut.expect(1).to_equal(0);
    ut3.ut.expect(0).to_equal(0);

    --Assert
    open l_expected for
      select 'FAILURE' as out_row from dual union all
      select 'Actual: 1 (number) was expected to equal: 0 (number)' from dual union all
      select 'at "UT3$USER#.SOME_PKG.SOME_PROCEDURE", line 4 ut3.ut.expect(1).to_equal(0);
  at "anonymous block", line 1
  at "UT3$USER#.EXPECTATIONS.INLINE_EXPECTATION_TO_DBMS_OUT", line 13' from dual union all
      select 'SUCCESS' from dual union all
      select 'Actual: 0 (number) was expected to equal: 0 (number)' from dual union all
      select 'FAILURE' as out_row from dual union all
      select 'Actual: 1 (number) was expected to equal: 0 (number)' from dual union all
      select 'at "UT3$USER#.EXPECTATIONS.INLINE_EXPECTATION_TO_DBMS_OUT", line 14 ut3.ut.expect(1).to_equal(0);' from dual union all
      select 'SUCCESS' from dual union all
      select 'Actual: 0 (number) was expected to equal: 0 (number)' from dual union all
      select '' from dual;
    dbms_output.get_lines(lines => l_output, numlines => l_lines);
    open l_actual for select trim(column_value) as out_row from table(l_output);

    ut.expect(l_actual).to_equal(l_expected);
    rollback;
  end;

  procedure create_some_pkg is
    pragma autonomous_transaction;
  begin
    execute immediate q'[
    create or replace package some_pkg is
      procedure some_procedure;
    end;]';

    execute immediate q'[
    create or replace package body some_pkg is
      procedure some_procedure is
      begin
        ut3.ut.expect(1).to_equal(0);
        ut3.ut.expect(0).to_equal(0);
      end;
    end;]';
  end;

  procedure drop_some_pkg is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package some_pkg';
  end;

end;
/