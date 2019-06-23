create or replace package body coverage_helper is

  g_run_ids         ut3.ut_coverage.tt_coverage_id_arr;
  g_profiler_run_id integer;
  g_block_run_id    integer;

  function get_mock_proftab_run_id return integer is
    v_result integer;
  begin
    select nvl(min(runid),0) - 1 into v_result
      from ut3.plsql_profiler_runs;
    return v_result;
  end; 
 
  function get_mock_block_run_id return integer is
    v_result integer;
  begin
    select nvl(min(run_id),0) - 1 into v_result
      from ut3.dbmspcc_runs;
    return v_result;
  end;

  procedure setup_mock_coverage_id is
  begin
    g_profiler_run_id := get_mock_proftab_run_id();
    ut3.ut_coverage.mock_coverage_id(g_profiler_run_id, ut3.ut_coverage.gc_proftab_coverage);
  end;

  procedure setup_mock_coverage_ids(a_profiler_run_id integer, a_block_run_id integer) is
    l_coverage_ids ut3.ut_coverage.tt_coverage_id_arr;
  begin
    l_coverage_ids(ut3.ut_coverage.gc_proftab_coverage) := a_profiler_run_id;
    l_coverage_ids(ut3.ut_coverage.gc_block_coverage)   := a_block_run_id;
    ut3.ut_coverage.mock_coverage_id(l_coverage_ids);
  end;

  procedure setup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    create_dummy_12_2_cov_pck();
    create_dummy_12_2_cov_test();
    grant_exec_on_12_2_cov();

    g_profiler_run_id := get_mock_proftab_run_id();
    g_block_run_id    := get_mock_block_run_id();
    setup_mock_coverage_ids(g_profiler_run_id, g_block_run_id);

    mock_block_coverage_data(g_block_run_id, user);
    mock_profiler_coverage_data(g_profiler_run_id, user);
    commit;
  end;

  procedure mock_coverage_data(a_user in varchar2) is
    c_unit_id   constant integer := 1;
  begin
    insert into ut3.plsql_profiler_runs ( runid, run_owner, run_date, run_comment)
    values(g_profiler_run_id, a_user, sysdate, 'unit testing utPLSQL');

    insert into ut3.plsql_profiler_units ( runid, unit_number, unit_type, unit_owner, unit_name)
    values(g_profiler_run_id, c_unit_id, 'PACKAGE BODY', 'UT3', 'DUMMY_COVERAGE');

    insert into ut3.plsql_profiler_data ( runid,  unit_number, line#, total_occur, total_time)
    select g_profiler_run_id, c_unit_id,     4,           1, 1  from dual union all
    select g_profiler_run_id, c_unit_id,     5,           0, 0  from dual union all
    select g_profiler_run_id, c_unit_id,     7,           1, 1  from dual;
  end;

  procedure cleanup_dummy_coverage(a_run_id in integer) is
    pragma autonomous_transaction;
  begin
    delete from ut3.plsql_profiler_data where runid = a_run_id;
    delete from ut3.plsql_profiler_units where runid = a_run_id;
    delete from ut3.plsql_profiler_runs where runid = a_run_id;
    commit;
  end;

  procedure cleanup_dummy_coverage(a_block_id in integer, a_prof_id in integer) is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3.test_block_dummy_coverage]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3.dummy_coverage_package_with_an_amazingly_long_name_that_you_would_not_think_of_in_real_life_project_because_its_simply_too_long]'; exception when others then null; end;
    delete from dbmspcc_blocks where run_id = a_block_id;
    delete from dbmspcc_units where run_id = a_block_id;
    delete from dbmspcc_runs where run_id = a_block_id;
    cleanup_dummy_coverage(a_prof_id);
    commit;
  end;

  procedure cleanup_dummy_coverage is
  begin
    cleanup_dummy_coverage(
      g_block_run_id,
      g_profiler_run_id
    );
  end;

  procedure create_dummy_coverage_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package UT3.DUMMY_COVERAGE is
      procedure do_stuff;
      
      procedure grant_myself;
    end;]';
    execute immediate q'[create or replace package body UT3.DUMMY_COVERAGE is
      procedure do_stuff is
      begin
        if 1 = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
      end;
      
      procedure grant_myself is
      begin
        execute immediate 'grant debug,execute on UT3.DUMMY_COVERAGE to ut3$user#';
      end;
    end;]';
    
  end; 

  procedure create_dummy_coverage_test is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package UT3.TEST_DUMMY_COVERAGE is
      --%suite(dummy coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;
      
      procedure grant_myself;
    end;]';
    execute immediate q'[create or replace package body UT3.TEST_DUMMY_COVERAGE is
      procedure test_do_stuff is
      begin
        dummy_coverage.do_stuff;
      end;
      
      procedure grant_myself is
      begin
        execute immediate 'grant debug,execute on UT3.TEST_DUMMY_COVERAGE to ut3$user#';
      end;
    end;]';
    
  end;
  
  procedure grant_exec_on_cov is
      pragma autonomous_transaction;
  begin
    execute immediate 'begin UT3.DUMMY_COVERAGE.grant_myself(); end;';
    execute immediate 'begin UT3.TEST_DUMMY_COVERAGE.grant_myself(); end;'; 
  end;
 
  procedure drop_dummy_coverage_pkg is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3.test_dummy_coverage]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3.dummy_coverage]'; exception when others then null; end;
  end;
 

  procedure create_dummy_coverage_test_1 is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package UT3.DUMMY_COVERAGE_1 is
      procedure do_stuff;
      procedure grant_myself;
    end;]';
    execute immediate q'[create or replace package body UT3.DUMMY_COVERAGE_1 is
      procedure do_stuff is
      begin
        if 1 = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
      end;
      
      procedure grant_myself is
      begin
        execute immediate 'grant debug,execute on UT3.DUMMY_COVERAGE_1 to ut3$user#';
      end;
      
    end;]';
    execute immediate q'[create or replace package UT3.TEST_DUMMY_COVERAGE_1 is
      --%suite(dummy coverage test 1)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;
      
      procedure grant_myself;
    end;]';
    execute immediate q'[create or replace package body UT3.TEST_DUMMY_COVERAGE_1 is
      procedure test_do_stuff is
      begin
        dummy_coverage_1.do_stuff;
      end;
      
      procedure grant_myself is
      begin
        execute immediate 'grant debug,execute on UT3.TEST_DUMMY_COVERAGE_1 to ut3$user#';
      end;
      
    end;]';
    execute immediate 'begin UT3.DUMMY_COVERAGE_1.grant_myself(); end;';
    execute immediate 'begin UT3.TEST_DUMMY_COVERAGE_1.grant_myself(); end;';
  end;

  procedure drop_dummy_coverage_test_1 is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package UT3.DUMMY_COVERAGE_1]';
    execute immediate q'[drop package UT3.TEST_DUMMY_COVERAGE_1]';
  end;

  --12.2 Setup
  procedure create_dummy_12_2_cov_pck is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package UT3.DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG is
      procedure do_stuff(i_input in number);
      
      procedure grant_myself;
    end;]';
    execute immediate q'[create or replace package body UT3.DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG is
      procedure do_stuff(i_input in number) is
      begin
        if i_input = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
      end;
      
      procedure grant_myself is
      begin
        execute immediate 'grant debug,execute on UT3.DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG to ut3$user#';
      end;
      
    end;]';
  end;

  procedure create_dummy_12_2_cov_test is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package UT3.TEST_BLOCK_DUMMY_COVERAGE is
      --%suite(dummy coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;
      
      procedure grant_myself;
      
    end;]';
    execute immediate q'[create or replace package body UT3.TEST_BLOCK_DUMMY_COVERAGE is
      procedure test_do_stuff is
      begin
        dummy_coverage_package_with_an_amazingly_long_name_that_you_would_not_think_of_in_real_life_project_because_its_simply_too_long.do_stuff(1);
        ut.expect(1).to_equal(1);
      end;
      
      procedure grant_myself is
      begin
        execute immediate 'grant debug,execute on  UT3.TEST_BLOCK_DUMMY_COVERAGE to ut3$user#';
      end;
    end;]';
  end;

  procedure mock_block_coverage_data(a_run_id integer,a_user in varchar2) is
    c_unit_id   constant integer := 1;
  begin
    insert into dbmspcc_runs ( run_id, run_owner, run_timestamp, run_comment)
    values(a_run_id, a_user, sysdate, 'unit testing utPLSQL');

    insert into dbmspcc_units ( run_id, object_id, type, owner, name,last_ddl_time)
    values(a_run_id, c_unit_id, 'PACKAGE BODY', 'UT3', 'DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG',sysdate);

    insert into dbmspcc_blocks ( run_id,  object_id, line,block,col,covered,not_feasible)
    select a_run_id, c_unit_id,4,1,1,1,0  from dual union all
    select a_run_id, c_unit_id,4,2,2,0,0  from dual union all
    select a_run_id, c_unit_id,5,3,0,1,0  from dual union all
    select a_run_id, c_unit_id,7,4,1,1,0  from dual;
  end;

  procedure mock_profiler_coverage_data(a_run_id integer,a_user in varchar2) is
    c_unit_id   constant integer := 1;
  begin
    insert into ut3.plsql_profiler_runs ( runid, run_owner, run_date, run_comment)
    values(a_run_id, a_user, sysdate, 'unit testing utPLSQL');

    insert into ut3.plsql_profiler_units ( runid, unit_number, unit_type, unit_owner, unit_name)
    values(a_run_id, c_unit_id, 'PACKAGE BODY', 'UT3', 'DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG');

    insert into ut3.plsql_profiler_data ( runid,  unit_number, line#, total_occur, total_time)
    select a_run_id, c_unit_id,     4,           1, 1  from dual union all
    select a_run_id, c_unit_id,     5,           0, 0  from dual union all
    select a_run_id, c_unit_id,     6,           1, 0  from dual union all
    select a_run_id, c_unit_id,     7,           1, 1  from dual;
  end;

  procedure grant_exec_on_12_2_cov is
      pragma autonomous_transaction;
  begin
    execute immediate 'begin UT3.DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG.grant_myself(); end;';
    execute immediate 'begin UT3.TEST_BLOCK_DUMMY_COVERAGE.grant_myself(); end;'; 
  end;

  procedure set_develop_mode is
  begin
    ut3.ut_coverage.set_develop_mode(true);
  end;

end;
/
