create or replace package body run_helper is

  procedure setup_cache_objects is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3$user#.dummy_test_package as    
        --%suite(dummy_test_suite)
        --%rollback(manual)

        --%test(dummy_test)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[create or replace procedure ut3$user#.dummy_test_procedure as
        --%some_annotation(some_text)
        --%rollback(manual)
      begin
        null;
      end;]';
    execute immediate q'[create or replace procedure ut3_tester_helper.dummy_test_procedure as
        --%some_annotation(some_text)
        --%rollback(manual)
      begin
        null;
      end;]';
      
      execute immediate q'[grant execute on ut3_tester_helper.dummy_test_procedure to public]';
  end;


  procedure setup_cache is
    pragma autonomous_transaction;
  begin
    setup_cache_objects();
    ut3.ut_annotation_manager.rebuild_annotation_cache('UT3$USER#','PACKAGE');
    ut3.ut_annotation_manager.rebuild_annotation_cache('UT3$USER#','PROCEDURE');
    ut3.ut_annotation_manager.rebuild_annotation_cache('UT3_TESTER_HELPER','PROCEDURE');
  end;

  procedure cleanup_cache is
    pragma autonomous_transaction;
  begin
    delete from ut3.ut_annotation_cache_info
     where object_type = 'PROCEDURE' and object_owner in ('UT3$USER#','UT3_TESTER_HELPER')
        or object_type = 'PACKAGE' and object_owner = user and object_name = 'DUMMY_TEST_PACKAGE';
    execute immediate q'[drop package ut3$user#.dummy_test_package]';
    execute immediate q'[drop procedure ut3$user#.dummy_test_procedure]';
    execute immediate q'[drop procedure ut3_tester_helper.dummy_test_procedure]';
  end;

 procedure db_link_setup is
    l_service_name varchar2(100);
    begin
      select global_name into l_service_name from global_name;
      execute immediate
      'create public database link db_loopback connect to ut3$user# identified by ut3
        using ''(DESCRIPTION=
                  (ADDRESS=(PROTOCOL=TCP)
                    (HOST='||sys_context('userenv','SERVER_HOST')||')
                    (PORT=1521)
                  )
                  (CONNECT_DATA=(SERVICE_NAME='||l_service_name||')))''';
      execute immediate q'[
    create or replace package ut3$user#.test_db_link is
      --%suite

      --%test
      procedure runs_with_db_link;
    end;]';

      execute immediate q'[
    create or replace package body ut3$user#.test_db_link is
      procedure runs_with_db_link is
        a_value integer;
        begin
          select 1 into a_value
          from dual@db_loopback;
          ut3.ut.expect(a_value).to_be_null();
        end;
    end;]';

    end;
    
  procedure db_link_cleanup is
    begin
      begin execute immediate 'drop public database link db_loopback'; exception when others then null; end;
      begin execute immediate 'drop package ut3$user#.test_db_link'; exception when others then null; end;
  end;
    
end;
/
