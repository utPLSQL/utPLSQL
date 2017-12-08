create or replace package body test_ut_test is


  procedure execute_autonomous(a_sql varchar2) is
    pragma autonomous_transaction;
  begin
    if a_sql is not null then
      execute immediate a_sql;
    end if;
    commit;
  end;

  function run_test(a_path varchar2) return clob is
    l_lines    ut3.ut_varchar2_list;
  begin
    select * bulk collect into l_lines from table(ut3.ut.run(a_path));
    return ut3.ut_utils.table_to_clob(l_lines);
  end;

  function get_value(a_variable varchar2) return integer is
    l_glob_val integer;
  begin
    execute immediate 'begin :l_glob_val := '||a_variable||'; end;' using out l_glob_val;
    return l_glob_val;
  end;

  procedure drop_test_package is
  begin
    execute_autonomous('drop package ut_test_pkg');
  end;


  procedure disabled_test is
    l_results  clob;
  begin
    --Arrange
    execute_autonomous(
      q'[create or replace package ut_test_pkg as
        --%suite
        gv_glob_val integer := 0;
        --%test
        --%disabled
        procedure test1;
        --%test
        procedure test2;
      end;]');
    execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(1); end;
        end;]');
    --Act
    l_results := run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [0 sec] (IGNORED)%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 0 errored, 1 disabled, 0 warning(s)%');
    ut.expect(get_value('ut_test_pkg.gv_glob_val')).to_equal(1);
  end;

  procedure aftertest_errors is
    l_results  clob;
  begin
    --Arrange
    execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          gv_glob_val integer := 0;
          --%aftertest(failing_procedure)
          --%test
          procedure test1;
          procedure failing_procedure;
          --%test
          procedure test2;
        end;]');
    execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
          procedure failing_procedure is begin gv_glob_val := 1/0; end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(1); end;
        end;]');
    --Act
    l_results := run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [% sec] (FAILED - 1)%test2 [% sec]%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)%');
    ut.expect(get_value('ut_test_pkg.gv_glob_val')).to_equal(2);
  end;

  procedure aftereach_errors is
    l_results  clob;
  begin
    --Arrange
    execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          gv_glob_val integer := 0;
          --%aftereach
          procedure failing_procedure;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure failing_procedure is begin gv_glob_val := 1/0; end;
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
        end;]');
    --Act
    l_results := run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [% sec] (FAILED - 1)%');
    ut.expect(l_results).to_be_like('%test2 [% sec] (FAILED - 2)%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 2 errored, 0 disabled, 0 warning(s)%');
    ut.expect(get_value('ut_test_pkg.gv_glob_val')).to_equal(2);
  end;

  procedure beforetest_errors is
    l_results  clob;
  begin
    --Arrange
    execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          gv_glob_val integer := 0;
          procedure failing_procedure;

          --%beforetest(failing_procedure)
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure failing_procedure is begin gv_glob_val := 1/0; end;
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(1); end;
        end;]');
    --Act
    l_results := run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [% sec] (FAILED - 1)%test2 [% sec]%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)%');
    ut.expect(get_value('ut_test_pkg.gv_glob_val')).to_equal(1);
  end;

  procedure beforeeach_errors is
    l_results  clob;
  begin
    --Arrange
    execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          gv_glob_val integer := 0;
          --%beforeeach
          procedure failing_procedure;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure failing_procedure is begin gv_glob_val := 1/0; end;
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
        end;]');
    --Act
    l_results := run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [% sec] (FAILED - 1)%');
    ut.expect(l_results).to_be_like('%test2 [% sec] (FAILED - 2)%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 2 errored, 0 disabled, 0 warning(s)%');
    ut.expect(get_value('ut_test_pkg.gv_glob_val')).to_equal(0);
  end;

end;
/
