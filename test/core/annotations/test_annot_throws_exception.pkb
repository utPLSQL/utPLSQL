create or replace package body test_annot_throws_exception
is
  procedure create_package is
    pragma autonomous_transaction;

    l_package_spec VARCHAR2(32737);
    l_package_body VARCHAR2(32737);
  begin
    l_package_spec := '
        create package annotated_package_with_throws is
            --%suite(Dummy package to test annotation throws)

            --%test(Throws samme annoted exception)
            --%throws(-20145)
            procedure raised_same_exception;

            --%test(Throws one of the listed exceptions)
            --%throws(-20145,-20146, -20189 ,-20563)
            procedure raised_one_listed_exception;

            --%test(Throws diff exception)
            --%throws(-20144)
            procedure raised_diff_exception;

            --%test(Throws empty)
            --%throws()
            procedure empty_throws;

            --%test(Ignores when only bad parameters are passed1)
            --%throws(hello,784#,0-=234,,u1234)
            procedure bad_paramters_with_except;

            --%test(Ignores when only bad parameters are passed, the test does not raise a exception and it shows successful test)
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
  end;

  procedure drop_package is
    pragma autonomous_transaction;

    l_drop_statment VARCHAR2(32737);
  begin
    l_drop_statment := 'drop package annotated_package_with_throws';
    execute immediate l_drop_statment;
  end;

  function execution_test_result(a_procedure_test_name in varchar) return varchar2 is
    l_result varchar2(32737);
  begin
    select column_value
    into l_result
    from table(ut3.ut.run('annotated_package_with_throws.'||a_procedure_test_name, ut3.ut_documentation_reporter()))
    where regexp_like(column_value, '^([0-9]+) tests, [0-9]+ failed, [0-9]+ errored, [0-9]+ disabled, [0-9]+ warning\(s\)$');

    return l_result;
  end;

  procedure throws_same_annotated_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('raised_same_exception');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;

  procedure throws_one_of_annotated_excpt is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('raised_one_listed_exception');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;

  procedure throws_diff_annotated_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('raised_diff_exception');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;

  procedure throws_empty is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('empty_throws');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)');
  end;

  procedure bad_paramters_with_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('bad_paramters_with_except');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 1 errored, 0 disabled, 0 warning(s)');
  end;

  procedure bad_paramters_without_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('bad_paramters_without_except');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;

  procedure one_valid_exception_number is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('one_valid_exception_number');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;

  procedure nothing_thrown is
    l_result VARCHAR2(32737);
  begin
    --Act
    l_result := execution_test_result('nothing_thrown');
    --Assert
    ut.expect(l_result).to_equal('1 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;
end;
/
