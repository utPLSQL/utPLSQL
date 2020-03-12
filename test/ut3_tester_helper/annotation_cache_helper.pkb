create or replace package body annotation_cache_helper as

  procedure setup_two_suites is
    pragma autonomous_transaction;
  begin
    execute immediate
      'create or replace package ut3_cache_test_owner.granted_test_suite is
        --%suite

        --%test
        procedure test1;
        --%test
        procedure test2;
        end;';

    execute immediate
      'create or replace package body ut3_cache_test_owner.granted_test_suite is
        procedure test1 is begin ut3.ut.expect( 1 ).to_equal( 1 ); end;
        procedure test2 is begin ut3.ut.expect( 1 ).to_equal( 1 ); end;
        end;';
    execute immediate
      'create or replace package ut3_cache_test_owner.not_granted_test_suite is
        --%suite

        --%test
        procedure test1;
        --%test
        procedure test2;
        end;';
    execute immediate
      'create or replace package body ut3_cache_test_owner.not_granted_test_suite is
        procedure test1 is begin ut3.ut.expect( 1 ).to_equal( 1 ); end;
        procedure test2 is begin ut3.ut.expect( 1 ).to_equal( 1 ); end;
        end;';

    execute immediate
      'grant execute on ut3_cache_test_owner.granted_test_suite to
        ut3_execute_any_proc_user, ut3_select_any_table_user, ut3_select_catalog_user, ut3_no_extra_priv_user';
  end;

  procedure revoke_granted_suite is
    pragma autonomous_transaction;
  begin
    execute immediate
      'revoke execute on ut3_cache_test_owner.granted_test_suite from
        ut3_execute_any_proc_user, ut3_select_any_table_user, ut3_select_catalog_user, ut3_no_extra_priv_user';
  exception
    when others then
      null;
  end;


  procedure add_new_suite is
    pragma autonomous_transaction;
  begin
    execute immediate
      'create or replace package ut3_cache_test_owner.new_suite is
        --%suite

        --%test
        procedure test1;
        --%test
        procedure test2;
        end;';

    execute immediate
      'create or replace package body ut3_cache_test_owner.new_suite is
        procedure test1 is begin ut3.ut.expect( 1 ).to_equal( 1 ); end;
        procedure test2 is begin ut3.ut.expect( 1 ).to_equal( 1 ); end;
        end;';
    execute immediate
      'grant execute on ut3_cache_test_owner.new_suite to
        ut3_execute_any_proc_user, ut3_select_any_table_user, ut3_select_catalog_user, ut3_no_extra_priv_user';
  end;

  procedure cleanup_two_suites is
    pragma autonomous_transaction;
  begin
    begin
      execute immediate 'drop package ut3_cache_test_owner.not_granted_test_suite';
    exception
      when others then
        null;
    end;
    begin
      execute immediate 'drop package ut3_cache_test_owner.granted_test_suite';
    exception
      when others then
        null;
    end;
  end;

  procedure cleanup_new_suite is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package ut3_cache_test_owner.new_suite';
  exception
    when others then
      null;
  end;

  procedure purge_annotation_cache is
  begin
    ut3.ut_runner.purge_cache( 'UT3_CACHE_TEST_OWNER' );
  end;


  procedure disable_ddl_trigger is
    pragma autonomous_transaction;
  begin
    execute immediate 'alter trigger ut3.ut_trigger_annotation_parsing disable';
    execute immediate 'begin ut3.ut_trigger_check.is_alive( ); end;';
  end;

  procedure enable_ddl_trigger is
    pragma autonomous_transaction;
  begin
    execute immediate 'alter trigger ut3.ut_trigger_annotation_parsing enable';
  end;

  procedure create_run_function_for_user(a_user varchar2) is
    pragma autonomous_transaction;
  begin
    execute immediate
      'create or replace function ' || a_user || '.call_ut_run return clob is
        l_data    ut3.ut_varchar2_list;
        l_results clob;
      begin
        select * bulk collect into l_data from table (ut3.ut.run( ''ut3_cache_test_owner'' ));
        return ut3_tester_helper.main_helper.table_to_clob( l_data );
      end;
      ';
    execute immediate 'grant execute on ' || a_user || '.call_ut_run to public ';
  end;

  procedure drop_run_function_for_user(a_user varchar2) is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop function ' || a_user || '.call_ut_run';
  end;

  procedure create_run_function_for_users is
  begin
    create_run_function_for_user( 'ut3_no_extra_priv_user' );
    create_run_function_for_user( 'ut3_select_catalog_user' );
    create_run_function_for_user( 'ut3_select_any_table_user' );
    create_run_function_for_user( 'ut3_execute_any_proc_user' );
    create_run_function_for_user( 'ut3_cache_test_owner' );
    create_run_function_for_user( 'ut3' );
  end;

  procedure drop_run_function_for_users is
  begin
    drop_run_function_for_user( 'ut3_no_extra_priv_user' );
    drop_run_function_for_user( 'ut3_select_catalog_user' );
    drop_run_function_for_user( 'ut3_select_any_table_user' );
    drop_run_function_for_user( 'ut3_execute_any_proc_user' );
    drop_run_function_for_user( 'ut3_cache_test_owner' );
    drop_run_function_for_user( 'ut3' );
  end;

  function run_tests_as(a_user varchar2) return clob is
    l_results clob;
  begin
    execute immediate 'begin :x := '||a_user||'.call_ut_run; end;' using out l_results;
    return l_results;
  end;
end;
/