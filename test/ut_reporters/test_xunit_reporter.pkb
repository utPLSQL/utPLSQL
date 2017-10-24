create or replace package body test_xunit_reporter as

  procedure crate_a_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package check_xunit_reporting is
      --%suite(A suite with <tag>)

      --%test(A test with <tag>)
      procedure test_do_stuff;
    end;]';
    execute immediate q'[create or replace package body check_xunit_reporting is
      procedure test_do_stuff is
      begin
        ut3.ut.expect(1).to_equal(1);
        ut3.ut.expect(1).to_equal(2);
      end;
    end;]';
  end;

  procedure escapes_special_chars is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_xunit_reporting',ut3.ut_xunit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%<tag>%');
    ut.expect(l_actual).to_be_like('%&lt;tag&gt;%');
  end;

  procedure reports_only_failed_or_errored is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_xunit_reporting',ut3.ut_xunit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%Actual: 1 (number) was expected to equal: 1 (number)%');
    ut.expect(l_actual).to_be_like('%Actual: 1 (number) was expected to equal: 2 (number)%');
  end;

  procedure reports_failed_line is
    l_results   ut3.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3.ut.run('check_xunit_reporting',ut3.ut_xunit_reporter()));
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%at "%.CHECK_XUNIT_REPORTING%", line %');
  end;

  procedure remove_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_xunit_reporting';
  end;
end;
/
