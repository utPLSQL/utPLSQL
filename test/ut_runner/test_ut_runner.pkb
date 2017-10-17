create or replace package body test_ut_runner is

  procedure version_comp_check_compare is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.123.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.123.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.13.31.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.1.0','v3.0.0.0') ).to_equal(0);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.1.0.0','v3.0.0.0') ).to_equal(0);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v2.0.0.0') ).to_equal(0);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v4.0.0.0') ).to_equal(0);
  end;

  procedure version_comp_check_ignore is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.123','v3.0.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0.0','v3.0.0.123') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0','v3.0.0.0') ).to_equal(1);
  end;

  procedure version_comp_check_short is
  begin
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0.0','v3.0.0.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3.0','v3.0.123.0') ).to_equal(1);
    ut.expect( ut3.ut_runner.version_compatibility_check('v3','v3.123.0.0') ).to_equal(1);
  end;

  procedure version_comp_check_exception is
    procedure throws(a_requested varchar2, a_current varchar2) is
      l_compatible integer;
    begin
      l_compatible := ut3.ut_runner.version_compatibility_check(a_requested,a_current);
      ut.fail('Expected exception but nothing was raised');
    exception
      when others then
        ut.expect(sqlcode).to_equal(-20214);
    end;
  begin
    throws('bad_ver','v3.0.0.0');
    throws('v3.0.0.0','bad_ver');
  end;

  procedure create_test_spec
  as
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package test_cache as
    --%suite

    --%test
    procedure failing_test;
end;
]';
  end;

  procedure create_test_body(a_number integer)
  as
    pragma autonomous_transaction;
  begin
    execute immediate 'create or replace package body test_cache as
    procedure failing_test is
    begin
      ut3.ut.expect('||a_number||').to_be_null;
    end;
end;';
  end;

  procedure drop_test_package
  as
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package test_cache';
  end;

  procedure run_reset_package_body_cache is
    l_results   ut3.ut_varchar2_list;
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    create_test_spec();
    create_test_body(0);
    select *
      bulk collect into l_results
      from table(ut3.ut.run('test_cache'));

    --Act
    create_test_body(1);
    select *
      bulk collect into l_results
      from table(ut3.ut.run('test_cache'));
    --Assert
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    l_expected := '%ut3.ut.expect(1).to_be_null;%';
    ut.expect(l_actual).to_be_like(l_expected);
    drop_test_package();
  end;

  procedure run_keep_dbms_output_buffer is
    l_expected         dbmsoutput_linesarray;
    l_actual           dbmsoutput_linesarray;
    l_lines            number := 100;
  begin
    --Arrange
    create_test_spec();
    create_test_body(0);
    l_expected := dbmsoutput_linesarray(
        'A text placed into DBMS_OUTPUT',
        'Another line',
        lpad('A very long line',10000,'a')
    );
    dbms_output.enable;
    dbms_output.put_line(l_expected(1));
    dbms_output.put_line(l_expected(2));
    dbms_output.put_line(l_expected(3));
    --Act
    ut3.ut.run('test_cache');

    --Assert
    dbms_output.get_lines(lines => l_actual, numlines => l_lines);
    for i in 1 .. l_expected.count loop
      ut.expect(l_actual(i)).to_equal(l_expected(i));
    end loop;
    drop_test_package();
  end;

end;
/
