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

            --%test(Throws one exception)
            --%throws(-20145)
            procedure raised_same_exception;

            --%test(Throws one exception)
            --%throws(-20144)
            procedure raised_diff_exception;
        end;
    ';

    l_package_body := '
        create package body annotated_package_with_throws is
            procedure raised_same_exception is
            begin
                raise_application_error(-20145, ''Test error'');
            end;

            procedure raised_diff_exception is
            begin
                raise_application_error(-20143, ''Test error'');
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

  procedure throws_same_annotated_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    select column_value
    into l_result
    from table(ut3.ut.run('annotated_package_with_throws.raised_same_exception', ut3.ut_documentation_reporter()))
    where regexp_like(column_value, '^([0-9]+) tests, [0-9]+ failed, [0-9]+ errored, [0-9]+ disabled, [0-9]+ warning\(s\)$');

    --Assert
    ut.expect(l_result).to_equal('1 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;

  procedure throws_diff_annotated_except is
    l_result VARCHAR2(32737);
  begin
    --Act
    select column_value
    into l_result
    from table(ut3.ut.run('annotated_package_with_throws.raised_diff_exception', ut3.ut_documentation_reporter()))
    where regexp_like(column_value, '^([0-9]+) tests, [0-9]+ failed, [0-9]+ errored, [0-9]+ disabled, [0-9]+ warning\(s\)$');

    --Assert
    ut.expect(l_result).to_equal('1 tests, 1 failed, 0 errored, 0 disabled, 0 warning(s)');
  end;
end;
/
