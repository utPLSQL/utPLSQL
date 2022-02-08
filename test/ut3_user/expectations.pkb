create or replace package body expectations as

  procedure inline_expectation_to_dbms_out is
    l_expected         clob;
    l_actual           clob;
    pragma autonomous_transaction;
  begin
    --Arrange
    --Act
    execute immediate 'begin some_pkg.some_procedure; end;';
    ut3_develop.ut.expect(1).to_equal(0);
    ut3_develop.ut.expect(0).to_equal(0);

    --Assert
    l_actual := ut3_tester_helper.main_helper.get_dbms_output_as_clob();

    l_expected := q'[FAILURE
  Actual: 1 (number) was expected to equal: 0 (number)
  at "UT3$USER#.SOME_PKG%", line 4 ut3_develop.ut.expect(1).to_equal(0);
  at "anonymous block", line 1
  at "UT3$USER#.EXPECTATIONS%", line 10
SUCCESS
  Actual: 0 (number) was expected to equal: 0 (number)
FAILURE
  Actual: 1 (number) was expected to equal: 0 (number)
  at "UT3$USER#.EXPECTATIONS%", line 11 ut3_develop.ut.expect(1).to_equal(0);
SUCCESS
  Actual: 0 (number) was expected to equal: 0 (number)
]';

    ut.expect(l_actual).to_be_like(l_expected);
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
        ut3_develop.ut.expect(1).to_equal(0);
        ut3_develop.ut.expect(0).to_equal(0);
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