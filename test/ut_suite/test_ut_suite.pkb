create or replace package body test_ut_suite is

  procedure create_test_packages is
  begin
    test_ut_test.execute_autonomous(
      q'[create or replace package failing_no_body as
          --%suite
          gv_glob_val number := 0;
          --%beforeall
          procedure before_all;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    test_ut_test.execute_autonomous(
      q'[create or replace package failing_bad_body as
          --%suite
          gv_glob_val number := 0;
          --%beforeall
          procedure before_all;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    begin
      test_ut_test.execute_autonomous(
        q'[create or replace package body failing_bad_body as
           begin
             null;
           end;]');
    exception
      when others then
        null;
    end;
  end;

  procedure drop_test_packages is
  begin
    test_ut_test.execute_autonomous('drop package ut_test_pkg');
    test_ut_test.execute_autonomous('drop package failing_no_body');
    test_ut_test.execute_autonomous('drop package failing_bad_body');
  end;

  procedure disabled_suite is
    l_results  clob;
  begin
    --Arrange
    test_ut_test.execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          --%disabled
          gv_glob_val number := 0;
          --%beforeall
          procedure before_all;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    --Act
    l_results := test_ut_test.run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [0 sec] (IGNORED)%');
    ut.expect(l_results).to_be_like('%test2 [0 sec] (IGNORED)%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 0 errored, 2 disabled, 0 warning(s)%');
  end;

  procedure beforeall_errors is
    l_results  clob;
  begin
    --Arrange
    test_ut_test.execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          gv_glob_val integer := 0;
          --%beforeall
          procedure failing_procedure;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    test_ut_test.execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure failing_procedure is begin gv_glob_val := 1/0; end;
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(2); end;
        end;]');
    --Act
    l_results := test_ut_test.run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [% sec] (FAILED - 1)%');
    ut.expect(l_results).to_be_like('%test2 [% sec] (FAILED - 2)%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 2 errored, 0 disabled, 0 warning(s)%');
    ut.expect(test_ut_test.get_value('ut_test_pkg.gv_glob_val')).to_equal(0);
  end;

  procedure aftereall_errors is
    l_results  clob;
  begin
    --Arrange
    test_ut_test.execute_autonomous(
      q'[create or replace package ut_test_pkg as
          --%suite
          gv_glob_val integer := 0;
          --%afterall
          procedure failing_procedure;
          --%test
          procedure test1;
          --%test
          procedure test2;
        end;]');
    test_ut_test.execute_autonomous(
      q'[create or replace package body ut_test_pkg as
          procedure failing_procedure is begin gv_glob_val := 1/0; end;
          procedure test1 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(1); end;
          procedure test2 is begin gv_glob_val := gv_glob_val + 1; ut3.ut.expect(1).to_equal(1); end;
        end;]');
    --Act
    l_results := test_ut_test.run_test('ut_test_pkg');
    --Assert
    ut.expect(l_results).to_be_like('%test1 [% sec]%');
    ut.expect(l_results).to_be_like('%test2 [% sec]%');
    ut.expect(l_results).not_to_be_like('%test1 [% sec] (FAILED - 1)%');
    ut.expect(l_results).not_to_be_like('%test2 [% sec] (FAILED - 2)%');
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)%');
    ut.expect(test_ut_test.get_value('ut_test_pkg.gv_glob_val')).to_equal(2);
  end;

  procedure package_without_body is
    l_results  clob;
  begin
    --Act
    l_results := test_ut_test.run_test('failing_no_body');
    --Assert
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 2 errored%');
  end;

  procedure package_with_invalid_body is
    l_results  clob;
  begin
    --Act
    l_results := test_ut_test.run_test('failing_bad_body');
    --Assert
    ut.expect(l_results).to_be_like('%2 tests, 0 failed, 2 errored%');
  end;

end;
/
