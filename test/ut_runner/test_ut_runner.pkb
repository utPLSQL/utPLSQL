create or replace package body test_ut_runner is

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



  procedure keep_an_open_transaction is
    l_expected    varchar2(300);
    l_output_data dbms_output.chararr;
    l_num_lines   integer := 100000;
  begin
    --Arrange
    create_test_spec();
    create_test_body(0);
    l_expected := dbms_transaction.local_transaction_id(true);
    --Act
    ut3.ut.run('test_cache');
    dbms_output.get_lines( l_output_data, l_num_lines);
    --Assert
    ut.expect(dbms_transaction.local_transaction_id()).to_equal(l_expected);
    drop_test_package();
  end;

  procedure close_newly_opened_transaction is
    l_output_data dbms_output.chararr;
    l_num_lines   integer := 100000;
  begin
    --Arrange
    create_test_spec();
    create_test_body(0);
    rollback;
    --Act
    ut3.ut.run('test_cache');
    dbms_output.get_lines( l_output_data, l_num_lines);
    --Assert
    ut.expect(dbms_transaction.local_transaction_id()).to_be_null();
    drop_test_package();
  end;

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

end;
/
