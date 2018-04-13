create or replace package body test_ut_runner is

  procedure setup_cache_objects is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package dummy_test_package as
        --%suite(dummy_test_suite)
        --%rollback(manual)

        --%test(dummy_test)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[create or replace procedure dummy_test_procedure as
        --%some_annotation(some_text)
        --%rollback(manual)
      begin
        null;
      end;]';
    execute immediate q'[create or replace procedure ut3.dummy_test_procedure as
        --%some_annotation(some_text)
        --%rollback(manual)
      begin
        null;
      end;]';
  end;

  procedure setup_cache is
    pragma autonomous_transaction;
  begin
    setup_cache_objects();
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PROCEDURE');
    ut3.ut_annotation_manager.rebuild_annotation_cache('UT3','PROCEDURE');
  end;

  procedure cleanup_cache is
    pragma autonomous_transaction;
  begin
    delete from ut3.ut_annotation_cache_info
     where object_type = 'PROCEDURE' and object_owner in ('UT3',user)
        or object_type = 'PACKAGE' and object_owner = user and object_name = 'DUMMY_TEST_PACKAGE';
    execute immediate q'[drop package dummy_test_package]';
    execute immediate q'[drop procedure dummy_test_procedure]';
    execute immediate q'[drop procedure ut3.dummy_test_procedure]';
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

  procedure test_purge_cache_schema_type is
    l_actual sys_refcursor;
  begin

    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = user and object_type = 'PROCEDURE';
    ut.expect(l_actual).not_to_be_empty();

    --Act
    ut3.ut_runner.purge_cache(user,'PROCEDURE');

    --Assert
    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = user and object_type = 'PROCEDURE';
    --Cache purged for object owner/type
    ut.expect(l_actual).to_be_empty();
    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = user and object_type = 'PACKAGE';
    --Cache not purged for other types
    ut.expect(l_actual).not_to_be_empty();
    open l_actual for
      select * from ut3.ut_annotation_cache_info
       where object_owner = 'UT3' and object_type = 'PROCEDURE';
    --Cache not purged for other owners
    ut.expect(l_actual).not_to_be_empty();

  end;

  procedure test_rebuild_cache_schema_type is
    l_actual integer;
  begin
    --Act
    ut3.ut_annotation_manager.rebuild_annotation_cache(user,'PACKAGE');
    --Assert
    select count(1) into l_actual
      from ut3.ut_annotation_cache_info i
      join ut3.ut_annotation_cache c on c.cache_id = i.cache_id
     where object_owner = user and object_type = 'PACKAGE' and object_name = 'DUMMY_TEST_PACKAGE';
    --Rebuild cache for user/packages
    ut.expect(l_actual).to_equal(4);

    select count(1) into l_actual
      from ut3.ut_annotation_cache_info i
      join ut3.ut_annotation_cache c on c.cache_id = i.cache_id
     where object_owner = 'UT3' and object_type = 'PROCEDURE';

    --Did not rebuild cache for ut3/procedures
    ut.expect(l_actual).to_equal(0);
  end;

  procedure test_get_unit_test_info is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for
      select 'UT3_TESTER'  package_owner, 'DUMMY_TEST_PACKAGE' package_name,
             to_char(null) procedure_name, 1 annotation_pos, 'suite' annotation_name, 'dummy_test_suite' annotation_text
        from dual union all
      select 'UT3_TESTER', 'DUMMY_TEST_PACKAGE', to_char(null),               2, 'rollback', 'manual' from dual union all
      select 'UT3_TESTER', 'DUMMY_TEST_PACKAGE', 'SOME_DUMMY_TEST_PROCEDURE', 3, 'test', 'dummy_test' from dual union all
      select 'UT3_TESTER', 'DUMMY_TEST_PACKAGE', 'SOME_DUMMY_TEST_PROCEDURE', 4, 'beforetest', 'some_procedure' from dual;
    --Act
    open l_actual for select * from table(ut3.ut_runner.get_unit_test_info('UT3_TESTER','DUMMY_TEST_PACKAGE'));
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure test_get_reporters_list is
    l_expected sys_refcursor;
    l_actual   sys_refcursor;
  begin
    --Arrange
    open l_expected for
      select 'UT3.UT_COVERAGE_COBERTURA_REPORTER' reporter_object_name, 'Y' is_output_reporter from dual union all
      select 'UT3.UT_COVERAGE_HTML_REPORTER', 'Y' from dual union all
      select 'UT3.UT_COVERAGE_SONAR_REPORTER', 'Y' from dual union all
      select 'UT3.UT_COVERALLS_REPORTER', 'Y' from dual union all
      select 'UT3.UT_DOCUMENTATION_REPORTER', 'Y' from dual union all
      select 'UT3.UT_JUNIT_REPORTER', 'Y' from dual union all
      select 'UT3.UT_SONAR_TEST_REPORTER', 'Y' from dual union all
      select 'UT3.UT_TEAMCITY_REPORTER', 'Y' from dual union all
      select 'UT3.UT_TFS_JUNIT_REPORTER', 'Y' from dual;
    --Act
    open l_actual for select * from table(ut3.ut_runner.GET_REPORTERS_LIST()) order by 1;
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure db_link_cleanup is
    begin
      begin execute immediate 'drop public database link db_loopback'; exception when others then null; end;
      begin execute immediate 'drop package test_db_link'; exception when others then null; end;
    end;

  procedure db_link_setup is
    l_service_name varchar2(100);
    begin
      select global_name into l_service_name from global_name;
      execute immediate
      'create public database link db_loopback connect to ut3_tester identified by ut3
        using ''(DESCRIPTION=
                  (ADDRESS=(PROTOCOL=TCP)
                    (HOST='||sys_context('userenv','SERVER_HOST')||')
                    (PORT=1521)
                  )
                  (CONNECT_DATA=(SERVICE_NAME='||l_service_name||')))''';
      execute immediate q'[
    create or replace package test_db_link is
      --%suite

      --%test
      procedure runs_with_db_link;
    end;]';

      execute immediate q'[
    create or replace package body test_db_link is
      procedure runs_with_db_link is
        a_value integer;
        begin
          select 1 into a_value
          from dual@db_loopback;
          ut3.ut.expect(a_value).to_be_null();
        end;
    end;]';

    end;

  procedure raises_20213_on_fail_link is
    l_reporter ut3.ut_documentation_reporter := ut3.ut_documentation_reporter();
    l_lines    ut3.ut_varchar2_list;
  begin
    --Arrange
    --Act
    ut3.ut_runner.run(ut3.ut_varchar2_list('test_db_link'), ut3.ut_reporters(l_reporter), a_fail_on_errors=> true);
    ut.fail('Expected exception but nothing was raised');
  exception
    when others then
      --Assert
      ut.expect(sqlcode).to_equal(-20213);
      ut.expect(dbms_utility.format_error_stack||dbms_utility.format_error_backtrace).not_to_be_like('%ORA-02055%');
  end;

end;
/
