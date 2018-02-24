create or replace package body test_annot_throws_exception
is
  g_tests_results clob;

  procedure recollect_tests_results is
    pragma autonomous_transaction;

    l_package_spec  varchar2(32737);
    l_package_body  varchar2(32737);
    l_drop_statment varchar2(32737);
    l_test_results  ut3.ut_varchar2_list;
  begin
    l_package_spec := '
        create package annotated_package_with_throws is
            --%suite(Dummy package to test annotation throws)

            --%test(Throws same annotated exception)
            --%throws(-20145)
            procedure raised_same_exception;

            --%test(Throws one of the listed exceptions)
            --%throws(-20145,-20146, -20189 ,-20563)
            procedure raised_one_listed_exception;

            --%test(Leading zero is ignored in exception list)
            --%throws(-01476)
            procedure leading_0_exception_no;

            --%test(Throws diff exception)
            --%throws(-20144)
            procedure raised_diff_exception;

            --%test(Throws empty)
            --%throws()
            procedure empty_throws;

            --%test(Ignores annotation and fails when exception was thrown)
            --%throws(hello,784#,0-=234,,u1234)
            procedure bad_paramters_with_except;

            --%test(Ignores annotation and succeeds when no exception thrown)
            --%throws(hello,784#,0-=234,,u1234)
            procedure bad_paramters_without_except;

            --%test(Detects a valid exception number within many invalid ones)
            --%throws(7894562, operaqk, -=1, -1, pow74d, posdfk3)
            procedure one_valid_exception_number;

            --%test(Givess failure when a exception is expected and nothing is thrown)
            --%throws(-20459, -20136, -20145)
            procedure nothing_thrown;
        end;
    ';

    l_package_body := '
        create package body annotated_package_with_throws is
            procedure raised_same_exception is
            begin
                raise_application_error(-20145, ''Test error'');
            end;

            procedure raised_one_listed_exception is
            begin
                raise_application_error(-20189, ''Test error'');
            end;

            procedure leading_0_exception_no is
                x integer;
            begin
                x := 1 / 0;
            end;

            procedure raised_diff_exception is
            begin
                raise_application_error(-20143, ''Test error'');
            end;

            procedure empty_throws is
            begin
                raise_application_error(-20143, ''Test error'');
            end;

            procedure bad_paramters_with_except is
            begin
                raise_application_error(-20143, ''Test error'');
            end;

            procedure bad_paramters_without_except is
            begin
                null;
            end;

            procedure one_valid_exception_number is
            begin
              raise dup_val_on_index;
            end;

            procedure nothing_thrown is
            begin
                null;
            end;
        end;
    ';

    execute immediate l_package_spec;
    execute immediate l_package_body;

    select * bulk collect into l_test_results from table(ut3.ut.run(('annotated_package_with_throws')));

    g_tests_results := ut3.ut_utils.table_to_clob(l_test_results);

    l_drop_statment := 'drop package annotated_package_with_throws';
    execute immediate l_drop_statment;
  end;

  procedure throws_same_annotated_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws same annotated exception \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('raised_same_exception');
  end;

  procedure throws_one_of_annotated_excpt is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws one of the listed exceptions \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('raised_one_listed_exception');
  end;

  procedure throws_with_leading_zero is
  begin
    ut.expect(g_tests_results).to_match('^\s*Leading zero is ignored in exception list \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('leading_0_exception_no');
  end;

  procedure throws_diff_annotated_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws diff exception \[[\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('raised_diff_exception\s+Actual: -20143 was expected to equal: -20144\s+ORA-20143: Test error\s+ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;

  procedure throws_empty is
  begin
    ut.expect(g_tests_results).to_match('^\s*Throws empty \[[\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('empty_throws\s*ORA-20143: Test error\s*ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;

  procedure bad_paramters_with_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Ignores annotation and fails when exception was thrown \[[\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('bad_paramters_with_except\s*ORA-20143: Test error\s*ORA-06512: at "UT3_TESTER.ANNOTATED_PACKAGE_WITH_THROWS"');
  end;

  procedure bad_paramters_without_except is
  begin
    ut.expect(g_tests_results).to_match('^\s*Ignores annotation and succeeds when no exception thrown \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('bad_paramters_without_except');
  end;

  procedure one_valid_exception_number is
  begin
    ut.expect(g_tests_results).to_match('^\s*Detects a valid exception number within many invalid ones \[[\.0-9]+ sec\]\s*$','m');
    ut.expect(g_tests_results).not_to_match('one_valid_exception_number');
  end;

  procedure nothing_thrown is
  begin
    ut.expect(g_tests_results).to_match('^\s*Givess failure when a exception is expected and nothing is thrown \[[\.0-9]+ sec\] \(FAILED - [0-9]+\)\s*$','m');
    ut.expect(g_tests_results).to_match('nothing_thrown\s*Expected one of exceptions \(-20459, -20136, -20145\) but nothing was raised.');
  end;
end;
/
