create or replace package body test_coverage is

  g_run_id integer;

  function get_mock_run_id return integer is
    v_result integer;
  begin
    select nvl(min(runid),0) - 1 into v_result
      from ut3.plsql_profiler_runs;
    return v_result;
  end;

  procedure create_dummy_coverage_package is
  begin
    execute immediate q'[create or replace package DUMMY_COVERAGE is
      procedure do_stuff;
    end;]';
    execute immediate q'[create or replace package body DUMMY_COVERAGE is
      procedure do_stuff is
      begin
        if 1 = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
      end;
    end;]';
  end;

  procedure create_dummy_coverage_test is
  begin
    execute immediate q'[create or replace package TEST_DUMMY_COVERAGE is
      --%suite(dummy coverage test)

      --%test
      procedure test_do_stuff;
    end;]';
    execute immediate q'[create or replace package body TEST_DUMMY_COVERAGE is
      procedure test_do_stuff is
      begin
        dummy_coverage.do_stuff;
      end;
    end;]';
  end;

  procedure mock_coverage_data(a_run_id integer) is
    c_unit_id   constant integer := 1;
  begin
    insert into ut3.plsql_profiler_runs ( runid, run_owner, run_date, run_comment)
    values(a_run_id, user, sysdate, 'unit testing utPLSQL');

    insert into ut3.plsql_profiler_units ( runid, unit_number, unit_type, unit_owner, unit_name)
    values(a_run_id, c_unit_id, 'PACKAGE BODY', 'UT3_TESTER', 'DUMMY_COVERAGE');

    insert into ut3.plsql_profiler_data ( runid,  unit_number, line#, total_occur, total_time)
    select a_run_id, c_unit_id,     4,           1, 1  from dual union all
    select a_run_id, c_unit_id,     5,           0, 0  from dual union all
    select a_run_id, c_unit_id,     7,           1, 1  from dual;
  end;

  procedure setup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    create_dummy_coverage_package();
    create_dummy_coverage_test();
    g_run_id := get_mock_run_id();
    ut3.ut_coverage_helper.mock_coverage_id(g_run_id);
    mock_coverage_data(g_run_id);
    commit;
  end;

  procedure cleanup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    execute immediate q'[drop package test_dummy_coverage]';
    execute immediate q'[drop package dummy_coverage]';
    delete from ut3.plsql_profiler_data where runid = g_run_id;
    delete from ut3.plsql_profiler_units where runid = g_run_id;
    delete from ut3.plsql_profiler_runs where runid = g_run_id;
    commit;
  end;

end;
/
