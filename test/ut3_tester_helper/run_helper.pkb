create or replace package body run_helper is

  procedure setup_cache_objects is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_user.dummy_test_package as
        --%suite(dummy_test_suite)
        --%suitepath(some.path)
        --%rollback(manual)

        --%test(dummy_test)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[create or replace procedure ut3_user.dummy_test_procedure as
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

    execute immediate q'[create or replace package ut3_user.bad_test_package as
        --%rollback(manual)
        --%test(dummy_test)
        procedure some_dummy_test_procedure;
      end;]';
  end;

  procedure setup_cache_objectstag is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_user.dummy_test_package as
        --%suite(dummy_test_suite)
        --%suitepath(some.path)
        --%tags(dummy)
        --%rollback(manual)

        --%test(dummy_test)
        --%tags(testtag)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[create or replace procedure ut3_user.dummy_test_procedure as
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

  procedure setup_cache_twotags is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_user.dummy_test_package as
        --%suite(dummy_test_suite)
        --%tags(suitetag1,suitetag2)
        --%rollback(manual)

        --%test(dummy_test)
        --%tags(testtag1,testtag2)
        --%beforetest(some_procedure)
        procedure some_dummy_test_procedure;
      end;]';
    execute immediate q'[create or replace procedure ut3_user.dummy_test_procedure as
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

  procedure create_trans_control is
      pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut_transaction_control as
            function count_rows(a_val varchar2) return number;
            procedure setup;
            procedure test;
            procedure test_failure;
         end;]';
         
     execute immediate
      q'[create or replace package body ut_transaction_control
          as

            function count_rows(a_val varchar2) return number is
              l_cnt number;
            begin
              select count(*) into l_cnt from ut$test_table t where t.val = a_val;
              return l_cnt;
            end;
            procedure setup is begin
              insert into ut$test_table values ('s');
            end;
            procedure test is
            begin
              insert into ut$test_table values ('t');
            end;
            procedure test_failure is
            begin
              insert into ut$test_table values ('t');
              --raise no_data_found;
              raise_application_error(-20001,'Error');
            end;
         end;]';
         
         execute immediate 'grant execute on ut_transaction_control to public';
  end;

  procedure drop_trans_control is
      pragma autonomous_transaction;
  begin
    execute immediate 'drop package ut_transaction_control';
  end;

  procedure setup_cache is
    pragma autonomous_transaction;
  begin
    setup_cache_objects();
    ut3_develop.ut_annotation_manager.rebuild_annotation_cache('UT3_USER','PACKAGE');
    ut3_develop.ut_annotation_manager.rebuild_annotation_cache('UT3_USER','PROCEDURE');
    ut3_develop.ut_annotation_manager.rebuild_annotation_cache('UT3_TESTER_HELPER','PROCEDURE');
  end;

  procedure cleanup_cache is
    pragma autonomous_transaction;
  begin
    delete from ut3_develop.ut_annotation_cache_info
     where object_type = 'PROCEDURE' and object_owner in ('UT3_USER','UT3_TESTER_HELPER')
        or object_type = 'PACKAGE' and object_owner = user and object_name = 'DUMMY_TEST_PACKAGE';
    execute immediate q'[drop package ut3_user.dummy_test_package]';
    execute immediate q'[drop procedure ut3_user.dummy_test_procedure]';
    execute immediate q'[drop procedure ut3_tester_helper.dummy_test_procedure]';
  end;

  procedure create_db_link is
    l_service_name varchar2(100);
    pragma autonomous_transaction;
  begin
    select global_name into l_service_name from global_name;
    execute immediate
      'create public database link db_loopback connect to ut3_tester_helper identified by ut3
        using ''(DESCRIPTION=
                  (ADDRESS=(PROTOCOL=TCP)
                    (HOST='||sys_context('userenv','SERVER_HOST')||')
                  (PORT=1521)
                )
                (CONNECT_DATA=(SERVICE_NAME='||l_service_name||')))''';
  end;

  procedure drop_db_link is
  begin
    execute immediate 'drop public database link db_loopback';
  exception
    when others then
      null;
  end;
  
  procedure db_link_setup is
    l_service_name varchar2(100);
    begin
      create_db_link;
      execute immediate q'[
    create or replace package ut3_user.test_db_link is
      --%suite

      --%test
      procedure runs_with_db_link;
    end;]';

      execute immediate q'[
    create or replace package body ut3_user.test_db_link is
      procedure runs_with_db_link is
        a_value integer;
        begin
          select 1 into a_value
          from dual@db_loopback;
          ut3_develop.ut.expect(a_value).to_be_null();
        end;
    end;]';

    end; 
    
  procedure db_link_cleanup is
    begin
      drop_db_link;
      begin execute immediate 'drop package ut3_user.test_db_link'; exception when others then null; end;
  end;

 procedure create_suite_with_link is
    pragma autonomous_transaction;
  begin
    create_db_link;
    execute immediate 'create table tst(id number(18,0))';
    execute immediate q'[
      create or replace package test_distributed_savepoint is
        --%suite
        --%suitepath(alltests)

        --%beforeall
        procedure setup;

        --%test
        procedure test;
      end;]';

    execute immediate q'[
      create or replace package body test_distributed_savepoint is

        g_expected constant integer := 1;

        procedure setup is
        begin
          insert into tst@db_loopback values(g_expected);
        end;

        procedure test is
          l_actual   integer := 0;
        begin
          select id into l_actual from tst@db_loopback;

          ut.expect(l_actual).to_equal(g_expected);
        end;

      end;]';
      execute immediate 'grant execute on test_distributed_savepoint to public';
  end;
  
 procedure drop_suite_with_link is
    pragma autonomous_transaction;
  begin
    drop_db_link;
    execute immediate 'drop table tst';
    execute immediate 'drop package test_distributed_savepoint';
  end;
  
  procedure create_ut3_user_tests is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package test_package_1 is
      --%suite
      --%tags(suite1,helper)
      --%suitepath(tests)
      --%rollback(manual)

      --%test(Test1 from test package 1)
      --%tags(test1,suite1test1,subtest1)
      procedure test1;

      --%test(Test2 from test package 1)
      --%tags(test1,suite1test2)
      procedure test2;

    end test_package_1;
    ]';
    execute immediate q'[create or replace package body test_package_1 is
      procedure test1 is
        begin
          dbms_output.put_line('test_package_1.test1 executed');
          raise_application_error(-20111,'test');
        end;
      procedure test2 is
        begin
          dbms_output.put_line('test_package_1.test2 executed');
        end;
    end test_package_1;
    ]';

    execute immediate q'[create or replace package test_package_2 is
      --%suite
      --%tags(suite2,helper)
      --%suitepath(tests.test_package_1)

      --%test
      --%tags(test2,suite2test1,subtest2)
      procedure test1;

      --%test
      --%tags(suite2test2)
      procedure test2;

    end test_package_2;
    ]';
    execute immediate q'[create or replace package body test_package_2 is
      procedure test1 is
        begin
          dbms_output.put_line('test_package_2.test1 executed');
        end;
      procedure test2 is
        begin
          dbms_output.put_line('test_package_2.test2 executed');
        end;
    end test_package_2;
    ]';

    execute immediate q'[create or replace package test_package_3 is
      --%suite
      --%tags(suite3,helper)
      --%suitepath(tests2)

      --%test
      --%tags(test1suite3)
      procedure test1;

      --%test
      --%tags(test2suite3)
      procedure test2;

    end test_package_3;
    ]';
    execute immediate q'[create or replace package body test_package_3 is
      procedure test1 is
        begin
          dbms_output.put_line('test_package_3.test1 executed');
        end;
      procedure test2 is
        begin
          dbms_output.put_line('test_package_3.test2 executed');
        end;
    end test_package_3;
    ]';
    execute immediate q'[grant execute on test_package_1 to public]';
    execute immediate q'[grant execute on test_package_2 to public]';
    execute immediate q'[grant execute on test_package_3 to public]';
  end;

  procedure drop_ut3_user_tests is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package test_package_1]';
    execute immediate q'[drop package test_package_2]';
    execute immediate q'[drop package test_package_3]';
  end;
 
   procedure create_test_suite is
    pragma autonomous_transaction;
  begin
    ut3_tester_helper.run_helper.create_db_link;
    execute immediate q'[
      create or replace package stateful_package as
        function get_state return varchar2;
      end;
    ]';
    execute immediate q'[
      create or replace package body stateful_package as
        g_state varchar2(1) := 'A';
        function get_state return varchar2 is begin return g_state; end;
      end;
    ]';
    execute immediate q'[
      create or replace package test_stateful as
        --%suite
        --%suitepath(test_state)

        --%test
        --%beforetest(acquire_state_via_db_link,rebuild_stateful_package)
        procedure failing_stateful_test;

        procedure rebuild_stateful_package;
        procedure acquire_state_via_db_link;

      end;
    ]';
    execute immediate q'{
    create or replace package body test_stateful as

      procedure failing_stateful_test is
      begin
        ut3_develop.ut.expect(stateful_package.get_state@db_loopback).to_equal('abc');
      end;

      procedure rebuild_stateful_package is
        pragma autonomous_transaction;
      begin
        execute immediate q'[
          create or replace package body stateful_package as
            g_state varchar2(3) := 'abc';
            function get_state return varchar2 is begin return g_state; end;
          end;
        ]';
      end;

      procedure acquire_state_via_db_link is
      begin
        dbms_output.put_line('stateful_package.get_state@db_loopback='||stateful_package.get_state@db_loopback);
      end;
    end;
    }';
   execute immediate 'grant execute on test_stateful to public';
  end;
 
  procedure drop_test_suite is
    pragma autonomous_transaction;
  begin
    drop_db_link;
    execute immediate 'drop package stateful_package';
    execute immediate 'drop package test_stateful';
  end; 

  procedure package_no_body is
    pragma autonomous_transaction;
  begin
    execute immediate 'create or replace package ut_without_body as
    procedure test1;
  end;';
  end;

  procedure drop_package_no_body is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package ut_without_body';
  end;

  procedure run(a_reporter ut3_develop.ut_reporter_base := null) is
  begin
    ut3_develop.ut.run(a_reporter);
  end; 
  
  procedure run(a_path varchar2, a_reporter ut3_develop.ut_reporter_base := null) is
  begin
    ut3_develop.ut.run(a_path, a_reporter);
  end;    
  
  procedure run(a_paths ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base := null) is
  begin
    ut3_develop.ut.run(a_paths, a_reporter);
  end;

  procedure run(a_paths ut3_develop.ut_varchar2_list, a_test_files ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base) is
  begin
    ut3_develop.ut.run(
      a_paths,
      a_reporter, 
      a_source_files => ut3_develop.ut_varchar2_list(),
      a_test_files => a_test_files
     );
   end;

  function run(a_reporter ut3_develop.ut_reporter_base := null) return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (ut3_develop.ut.run(a_reporter));
    return l_results;
  end;

  function run(a_paths ut3_develop.ut_varchar2_list, a_test_files ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base) return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (
      ut3_develop.ut.run(
      a_paths,
      a_reporter, a_source_files => ut3_develop.ut_varchar2_list(),
      a_test_files => a_test_files
       ));
    return l_results;
  end;

  function run(a_path varchar2, a_reporter ut3_develop.ut_reporter_base := null)
    return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (ut3_develop.ut.run(a_path, a_reporter));
    return l_results;
  end;
  
  function run(a_paths ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base := null)
    return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (ut3_develop.ut.run(a_paths, a_reporter));
   return l_results;
  end;
  
  function run(a_test_files ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base)
    return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (
      ut3_develop.ut.run(
        a_reporter, a_source_files => ut3_develop.ut_varchar2_list(),
        a_test_files => a_test_files
      ));
    return l_results;
  end;
 
  procedure run(a_reporter ut3_develop.ut_reporter_base := null,a_tags varchar2) is
  begin
    ut3_develop.ut.run(a_reporter,a_tags => a_tags);
  end; 
  
  procedure run(a_path varchar2, a_reporter ut3_develop.ut_reporter_base := null,a_tags varchar2) is
  begin
    ut3_develop.ut.run(a_path, a_reporter,a_tags => a_tags);
  end;
  
  procedure run(a_paths ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base := null, a_tags varchar2) is
  begin
    ut3_develop.ut.run(a_paths, a_reporter,a_tags => a_tags);
  end;
  
  function run(a_reporter ut3_develop.ut_reporter_base := null,a_tags varchar2) return ut3_develop.ut_varchar2_list  is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (ut3_develop.ut.run(a_reporter, a_tags => a_tags));
    return l_results;
  end;
  
  function run(a_path varchar2, a_reporter ut3_develop.ut_reporter_base := null, a_tags varchar2)
    return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (ut3_develop.ut.run(a_path, a_reporter,a_tags => a_tags));
    return l_results;
  end;
  
  function run(a_paths ut3_develop.ut_varchar2_list, a_reporter ut3_develop.ut_reporter_base := null, a_tags varchar2)
    return ut3_develop.ut_varchar2_list is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table (ut3_develop.ut.run(a_paths, a_reporter, a_tags => a_tags));
   return l_results;
  end;
  
  procedure test_rollback_type(a_procedure_name varchar2, a_rollback_type integer, a_expectation ut_matcher) is
    l_suite    ut3_develop.ut_suite;
  begin
    --Arrange
    execute immediate 'delete from ut$test_table';
    l_suite := ut3_develop.ut_suite(a_object_owner => 'ut3_tester_helper', a_object_name => 'UT_TRANSACTION_CONTROL', a_line_no=> 1);
    l_suite.path := 'ut_transaction_control';
    l_suite.before_all_list := ut3_develop.ut_executables(ut3_develop.ut_executable('ut3_tester_helper', 'UT_TRANSACTION_CONTROL', 'setup', ut3_develop.ut_utils.gc_before_all));
    l_suite.items.extend;
    l_suite.items(l_suite.items.last) := ut3_develop.ut_test(a_object_owner => 'ut3_tester_helper', a_object_name => 'ut_transaction_control',a_name => a_procedure_name, a_line_no=> 1);
    l_suite.set_rollback_type(a_rollback_type);

    --Act
    l_suite.do_execute();

    --Assert
    ut.expect(main_helper.get_value(q'[ut_transaction_control.count_rows('t')]')).to_( a_expectation );
    ut.expect(main_helper.get_value(q'[ut_transaction_control.count_rows('s')]')).to_( a_expectation );
  end;
  
  procedure create_dummy_long_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_develop.dummy_long_test_package as
        
        --%suitepath(verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext)
        --%suite(dummy_test_suite)

        --%test(dummy_test)
        procedure some_dummy_test_procedure;
      end;]';
      
    execute immediate q'[create or replace package ut3_develop.dummy_long_test_package1 as
        
        --%suitepath(verylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtextverylongtext)
        --%suite(dummy_test_suite1)

        --%test(dummy_test)
        procedure some_dummy_test_procedure;
      end;]';
  end;

  procedure drop_dummy_long_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package ut3_develop.dummy_long_test_package]';
    execute immediate q'[drop package ut3_develop.dummy_long_test_package1]';
  end;
 
  procedure create_ut3_suite is
    pragma autonomous_transaction;
  begin
    execute immediate q'[
      create or replace package ut3_develop.some_test_package
      as
        --%suite

        --%test
        procedure some_test;

      end;]';
  end;

  procedure drop_ut3_suite is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package ut3_develop.some_test_package]';
  end;
  
  function get_schema_ut_packages(a_owner in varchar2) return ut3_develop.ut_object_names is
  begin
    return ut3_develop.ut_suite_manager.get_schema_ut_packages(ut3_develop.ut_varchar2_rows(a_owner));
  end;
    
  function ut_output_buffer_tmp return t_out_buff_tab pipelined is
    l_buffer_tab t_out_buff_tab;
    cursor get_buffer is
    select * from ut3_develop.ut_output_buffer_tmp;
  begin
    open get_buffer;
    fetch get_buffer bulk collect into l_buffer_tab;
    for idx in 1..l_buffer_tab.count loop
      pipe row(l_buffer_tab(idx));
    end loop;
  end;
  
  procedure delete_buffer is
  begin
    delete from ut3_develop.ut_output_buffer_tmp;
  end;

  function get_annotation_cache_info_cur(
    a_owner varchar2,
    a_type varchar2
  ) return sys_refcursor is
    l_result sys_refcursor;
  begin
    open l_result for
      select * from ut3_develop.ut_annotation_cache_info
       where object_owner = a_owner and object_type = a_type;

    return l_result;
  end;

  function get_annotation_cache_cursor(
    a_owner varchar2,
    a_type  varchar2,
    a_name  varchar2 := null
  ) return sys_refcursor is
    l_result sys_refcursor;
  begin
    open l_result for
      select *
        from ut3_develop.ut_annotation_cache_info i
        join ut3_develop.ut_annotation_cache c on c.cache_id = i.cache_id
       where object_owner = a_owner and object_type = a_type and object_name = nvl( a_name, object_name );

    return l_result;
  end;

end;
/
