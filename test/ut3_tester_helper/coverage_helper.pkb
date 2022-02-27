create or replace package body coverage_helper is

  g_job_no          integer := 0;

  function block_coverage_available return boolean is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return true;
    $else
      return false;
    $end
  end;

  function covered_package_name return varchar2 is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return 'dummy_coverage_package_with_an_amazingly_long_name_that_you_would_not_think_of_in_real_life_project_because_its_simply_too_long';
    $else
      return 'dummy_coverage';
    $end
  end;

  function substitute_covered_package( a_text varchar2, a_substitution varchar2 ) return varchar2 is
  begin
    return replace( replace( a_text, a_substitution, covered_package_name() ), upper(a_substitution), upper(covered_package_name()) );
  end;

  procedure set_develop_mode is
  begin
    ut3_develop.ut_coverage.set_develop_mode(true);
  end;


  procedure create_dummy_coverage is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_develop.]'||covered_package_name||q'[ is
      procedure do_stuff(i_input in number);
    end;]';

    execute immediate q'[create or replace package body ut3_develop.]'||covered_package_name||q'[ is
      procedure do_stuff(i_input in number) is
      begin
        if i_input = 2 then dbms_output.put_line('should not get here'); elsif i_input = 1 then dbms_output.put_line('should get here');
        else
          dbms_output.put_line('should not get here');
        end if;
      end;
    end;]';

    execute immediate q'[create or replace package ut3_develop.test_dummy_coverage is
      --%suite(dummy coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;

      --%test
      procedure zero_coverage;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.test_dummy_coverage is
      procedure test_do_stuff is
      begin
        ]'||covered_package_name||q'[.do_stuff(1);
        ut.expect(1).to_equal(1);
      end;
      procedure zero_coverage is
      begin
        null;
      end;
    end;]';

  end;

  procedure drop_dummy_coverage is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3_develop.test_dummy_coverage]';    exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.]'||covered_package_name; exception when others then null; end;
  end;
 

  procedure create_dummy_coverage_1 is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_develop.dummy_coverage_1 is
      procedure do_stuff;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.dummy_coverage_1 is
      procedure do_stuff is
      begin
        if 1 = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
      end;
    end;]';

    execute immediate q'[create or replace package ut3_develop.test_dummy_coverage_1 is
      --%suite(dummy coverage test 1)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.test_dummy_coverage_1 is
      procedure test_do_stuff is
      begin
        dummy_coverage_1.do_stuff;
      end;
      
    end;]';
  end;

  procedure drop_dummy_coverage_1 is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3_develop.dummy_coverage_1]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.test_dummy_coverage_1]'; exception when others then null; end;
  end;

  procedure create_cov_with_dbms_stats is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create table ut3_develop.table_to_test_stats as select * from user_objects]';

    execute immediate q'[create or replace package ut3_develop.stats is
      procedure gather;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.stats is
      procedure gather is
      begin
        dbms_Stats.gather_table_stats('UT3_DEVELOP','TABLE_TO_TEST_STATS');
      end;
    end;]';

    execute immediate q'[create or replace package ut3_develop.test_stats is
      --%suite(stats gathering coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_stats_gather;

    end;]';

    execute immediate q'[create or replace package body ut3_develop.test_stats is
      procedure test_stats_gather is
      begin
        stats.gather;
        ut.expect(1).to_equal(1);
      end;
    end;]';

  end;

  procedure create_regex_dummy_for_schema(p_schema in varchar2) is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ]'||p_schema||q'[.regex_dummy_cov is
      procedure do_stuff(i_input in number);
    end;]';

    execute immediate q'[create or replace package body ]'||p_schema||q'[.regex_dummy_cov is
      procedure do_stuff(i_input in number) is
      begin
        if i_input = 2 then dbms_output.put_line('should not get here'); elsif i_input = 1 then dbms_output.put_line('should get here');
        else
          dbms_output.put_line('should not get here');
        end if;
      end;
    end;]';

    execute immediate q'[create or replace package ]'||p_schema||q'[.test_regex_dummy_cov is
      --%suite(dummy coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;

      --%test
      procedure zero_coverage;
    end;]';

    execute immediate q'[create or replace package body ]'||p_schema||q'[.test_regex_dummy_cov is
      procedure test_do_stuff is
      begin
        regex_dummy_cov.do_stuff(1);
        ut.expect(1).to_equal(1);
      end;
      procedure zero_coverage is
      begin
        null;
      end;
    end;]';
  end;

  procedure create_regex_dummy_obj is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_develop.regex123_dummy_cov is
      procedure do_stuff(i_input in number);
    end;]';

    execute immediate q'[create or replace package body ut3_develop.regex123_dummy_cov is
      procedure do_stuff(i_input in number) is
      begin
        if i_input = 2 then dbms_output.put_line('should not get here'); elsif i_input = 1 then dbms_output.put_line('should get here');
        else
          dbms_output.put_line('should not get here');
        end if;
      end;
    end;]';

    execute immediate q'[create or replace package ut3_develop.test_regex123_dummy_cov is
      --%suite(dummy coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;

      --%test
      procedure zero_coverage;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.test_regex123_dummy_cov is
      procedure test_do_stuff is
      begin
        regex123_dummy_cov.do_stuff(1);
        ut.expect(1).to_equal(1);
      end;
      procedure zero_coverage is
      begin
        null;
      end;
    end;]';
  end;

  procedure create_regex_dummy_cov is
  begin
    create_regex_dummy_for_schema('ut3_develop');
    create_regex_dummy_for_schema('ut3_tester_helper');
    create_regex_dummy_obj;
  end;

  procedure drop_regex_dummy_cov is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3_develop.regex_dummy_cov]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.test_regex_dummy_cov]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_tester_helper.regex_dummy_cov]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_tester_helper.test_regex_dummy_cov]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.regex123_dummy_cov]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.test_regex123_dummy_cov]'; exception when others then null; end;        
  end;


  procedure drop_cov_with_dbms_stats is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3_develop.test_stats]';    exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.stats]'; exception when others then null; end;
    begin execute immediate q'[drop table ut3_develop.table_to_test_stats]'; exception when others then null; end;
  end;


  procedure run_standalone_coverage(a_coverage_run_id raw, a_input integer) is
  begin
    ut3_develop.ut_runner.coverage_start(a_coverage_run_id);
    execute immediate 'begin ut3_develop.'||covered_package_name||'.do_stuff(:a_input); end;' using in a_input;
    ut3_develop.ut_runner.coverage_stop();
  end;

  function get_job_status(a_job_name varchar2, a_job_started_after timestamp with time zone) return varchar2 is
    l_status varchar2(1000);
  begin
    begin
      select status into l_status
        from user_scheduler_job_run_details
       where job_name = upper(a_job_name)
         and req_start_date >= a_job_started_after;
    exception
      when no_data_found then
      null;
    end;
    return l_status;
  end;

  procedure sleep(a_time number) is
  begin
    $if dbms_db_version.version >= 18 $then
      dbms_session.sleep(a_time);
    $else
      dbms_lock.sleep(a_time );
    $end
  end;

  procedure run_job_and_wait_for_finish(a_job_action varchar2) is
    l_status          varchar2(1000);
    l_job_name        varchar2(30);
    l_timestamp       timestamp with time zone := current_timestamp;
    i integer := 0;
    pragma autonomous_transaction;
  begin
    g_job_no := g_job_no + 1;
    l_job_name := 'utPLSQL_selftest_job_'||g_job_no;
    sleep(0.15);
    dbms_scheduler.create_job(
      job_name      =>  l_job_name,
      job_type      =>  'PLSQL_BLOCK',
      job_action    =>  a_job_action,
      start_date    =>  l_timestamp,
      enabled       =>  TRUE,
      auto_drop     =>  TRUE,
      comments      =>  'one-time-job'
      );
    while (l_status is null or l_status not in ('SUCCEEDED','FAILED')) and i < 150 loop
      l_status := get_job_status( l_job_name, l_timestamp );
      sleep(0.1);
      i := i + 1;
    end loop;
    commit;
    if l_status = 'FAILED' then
      raise_application_error(-20000, 'Running a scheduler job failed');
    end if;
  end;

  procedure run_coverage_job(a_coverage_run_id raw, a_input integer) is
  begin
    run_job_and_wait_for_finish(
      'begin coverage_helper.run_standalone_coverage('''||a_coverage_run_id||''', '||a_input||'); end;'
      );
  end;

  procedure create_test_results_table is
    pragma autonomous_transaction;
    e_exists exception;
    pragma exception_init ( e_exists, -955 );
  begin
    execute immediate 'create table test_results (text varchar2(4000))';
  exception
    when e_exists then
      null;
  end;

  procedure drop_test_results_table is
    pragma autonomous_transaction;
    e_not_exists exception;
    pragma exception_init ( e_not_exists, -942 );
  begin
    execute immediate 'drop table test_results';
  exception
    when e_not_exists then
      null;
  end;

  function run_code_as_job( a_plsql_block varchar2 ) return clob is
    l_result_clob clob;
    pragma autonomous_transaction;
  begin
    run_job_and_wait_for_finish( a_plsql_block );

    execute immediate q'[
      declare
        l_results ut3_develop.ut_varchar2_list;
      begin
        select *
          bulk collect into l_results
          from test_results;
        delete from test_results;
        commit;
        :clob_results := ut3_tester_helper.main_helper.table_to_clob(l_results);
      end;
      ]'
    using out l_result_clob;

    return l_result_clob;
  end;

  procedure copy_coverage_data_to_ut3(a_coverage_run_id raw) is
    pragma autonomous_transaction;
    l_current_coverage_run_id raw(32) := hextoraw(sys_context('UT3_INFO','COVERAGE_RUN_ID'));
  begin
    insert into ut3.ut_coverage_runs(coverage_run_id, line_coverage_id, block_coverage_id)
    select l_current_coverage_run_id, -line_coverage_id, -block_coverage_id
      from ut3_develop.ut_coverage_runs
     where coverage_run_id = a_coverage_run_id;

    insert into ut3.plsql_profiler_runs(runid, related_run, run_owner, run_date, run_comment, run_total_time, run_system_info, run_comment1, spare1)
    select -runid, related_run, run_owner, run_date, run_comment, run_total_time, run_system_info, run_comment1, spare1
      from ut3_develop.plsql_profiler_runs c
      join ut3_develop.ut_coverage_runs r
        on r.line_coverage_id = c.runid
     where r.coverage_run_id = a_coverage_run_id;

    insert into ut3.plsql_profiler_units(runid, unit_number, unit_type, unit_owner, unit_name, unit_timestamp, total_time, spare1, spare2)
    select -runid, unit_number, unit_type, unit_owner, unit_name, unit_timestamp, total_time, spare1, spare2
      from ut3_develop.plsql_profiler_units c
      join ut3_develop.ut_coverage_runs r
        on r.line_coverage_id = c.runid
     where r.coverage_run_id = a_coverage_run_id;

    insert into ut3.plsql_profiler_data(runid, unit_number, line#, total_occur, total_time, min_time, max_time, spare1, spare2, spare3, spare4)
    select -runid, unit_number, line#, total_occur, total_time, min_time, max_time, spare1, spare2, spare3, spare4
      from ut3_develop.plsql_profiler_data c
      join ut3_develop.ut_coverage_runs r
        on r.line_coverage_id = c.runid
     where r.coverage_run_id = a_coverage_run_id;

    insert into ut3.dbmspcc_runs(run_id, run_comment, run_owner, run_timestamp)
    select -run_id, run_comment, run_owner, run_timestamp
      from ut3_develop.dbmspcc_runs c
      join ut3_develop.ut_coverage_runs r
        on r.block_coverage_id = c.run_id
     where r.coverage_run_id = a_coverage_run_id;

    insert into ut3.dbmspcc_units(run_id, object_id, owner, name, type, last_ddl_time)
    select -run_id, object_id, owner, name, type, last_ddl_time
      from ut3_develop.dbmspcc_units c
      join ut3_develop.ut_coverage_runs r
        on r.block_coverage_id = c.run_id
     where r.coverage_run_id = a_coverage_run_id;

    insert into ut3.dbmspcc_blocks(run_id, object_id, block, line, col, covered, not_feasible)
    select -run_id, object_id, block, line, col, covered, not_feasible
      from ut3_develop.dbmspcc_blocks c
      join ut3_develop.ut_coverage_runs r
        on r.block_coverage_id = c.run_id
     where r.coverage_run_id = a_coverage_run_id;

    commit;
  end;

  function gather_coverage_on_coverage( a_cov_options varchar2) return clob is
    pragma autonomous_transaction;
    l_plsql_block varchar2(32767);
    l_result_clob clob;
    l_coverage_id raw(32) := sys_guid();
  begin
    l_plsql_block := q'[
    declare
      l_coverage_options ut3_develop.ut_coverage_options;
      l_coverage_run_id raw(32) := ']'||rawtohex(l_coverage_id)||q'[';
      l_result ut3_develop.ut_coverage.t_coverage;
    begin
      ut3_develop.ut_runner.coverage_start(l_coverage_run_id); 
      ut3_develop.ut_coverage.set_develop_mode(a_develop_mode => true);
      l_coverage_options := {a_cov_options};  
      l_result := ut3_develop.ut_coverage.get_coverage_data(l_coverage_options);
      ut3_develop.ut_coverage.set_develop_mode(a_develop_mode => false);
      ut3_develop.ut_runner.coverage_stop();
      insert into test_results select owner||'.'||name from ut3_develop.ut_coverage_sources_tmp;
      commit;
    end;]';
    l_plsql_block := replace(l_plsql_block,'{a_cov_options}',a_cov_options);
    run_job_and_wait_for_finish( l_plsql_block );
    execute immediate q'[
      declare
        l_results ut3_develop.ut_varchar2_list;
      begin
        select *
          bulk collect into l_results
          from test_results;
        delete from test_results;
        commit;
        :clob_results := ut3_tester_helper.main_helper.table_to_clob(l_results);
      end;
      ]'
    using out l_result_clob;
    copy_coverage_data_to_ut3(l_coverage_id);
    return l_result_clob;
  end;

  function run_tests_as_job( a_run_command varchar2 ) return clob is
    l_plsql_block varchar2(32767);
    l_result_clob clob;
    l_coverage_id raw(32) := sys_guid();
  begin
    l_plsql_block := q'[
    begin
      ut3_develop.ut_runner.coverage_start(']'||rawtohex(l_coverage_id)||q'[');
      insert into test_results select * from table( {a_run_command} );
      commit;
    end;]';
    l_plsql_block := replace(l_plsql_block,'{a_run_command}',a_run_command);
    l_result_clob := run_code_as_job( l_plsql_block );
    copy_coverage_data_to_ut3(l_coverage_id);
    return l_result_clob;
  end;

  procedure create_dup_object_name is
    pragma autonomous_transaction;
  begin
    execute immediate 'create table ut3_develop.test_table(id integer)';
    execute immediate q'[
    create or replace trigger ut3_develop.duplicate_name
      before insert on ut3_develop.test_table
    begin

      dbms_output.put_line('A');
    end;
    ]';
    execute immediate q'[
    create or replace package ut3_develop.duplicate_name is
      procedure some_procedure;
    end;
    ]';
    execute immediate q'[
    create or replace package body ut3_develop.duplicate_name is
      procedure some_procedure is
      begin
        insert into test_table(id) values(1);
      end;
    end;
    ]';
    execute immediate q'[
    create or replace package ut3_develop.test_duplicate_name is
      --%suite
      
      --%test
      procedure run_duplicate_name;
    end;
    ]';
    execute immediate q'[
    create or replace package body ut3_develop.test_duplicate_name is
      procedure run_duplicate_name is
        l_actual sys_refcursor;
      begin
        ut3_develop.duplicate_name.some_procedure;
        ut.expect(l_actual).to_have_count(1);
      end;
    end;
    ]';
  end;

  procedure drop_dup_object_name is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop table ut3_develop.test_table';
    execute immediate 'drop package ut3_develop.duplicate_name';
    execute immediate 'drop package ut3_develop.test_duplicate_name';
  end;

end;
/
