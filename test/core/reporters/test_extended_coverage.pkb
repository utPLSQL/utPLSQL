create or replace package body test_extended_coverage is

  g_run_id ut3.ut_coverage.tt_coverage_id_arr;

  function get_mock_block_run_id return integer is
    v_result integer;
  begin
    select nvl(min(run_id),0) - 1 into v_result
      from dbmspcc_runs;
    return v_result;
  end;

  function get_mock_proftab_run_id return integer is
    v_result integer;
  begin
    select nvl(min(runid),0) - 1 into v_result
      from ut3.plsql_profiler_runs;
    return v_result;
  end;

  procedure create_dummy_coverage_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package UT3.DUMMY_COVERAGE is
      procedure do_stuff(i_input in number);
    end;]';
    execute immediate q'[create or replace package body UT3.DUMMY_COVERAGE is
      procedure do_stuff(i_input in number) is
      begin
        if i_input = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
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
    end;]';
    execute immediate q'[create or replace package body UT3.TEST_DUMMY_COVERAGE is
      procedure test_do_stuff is
      begin
        dummy_coverage.do_stuff(1);
        ut.expect(1).to_equal(1);
      end;
    end;]';
  end;

  procedure mock_block_coverage_data(a_run_id integer) is
    c_unit_id   constant integer := 1;
  begin
    insert into dbmspcc_runs ( run_id, run_owner, run_timestamp, run_comment)
    values(a_run_id, user, sysdate, 'unit testing utPLSQL');

    insert into dbmspcc_units ( run_id, object_id, type, owner, name,last_ddl_time)
    values(a_run_id, c_unit_id, 'PACKAGE BODY', 'UT3', 'DUMMY_COVERAGE',sysdate);

    insert into dbmspcc_blocks ( run_id,  object_id, line,block,col,covered,not_feasible)
    select a_run_id, c_unit_id,4,1,1,1,0  from dual union all
    select a_run_id, c_unit_id,4,2,2,0,0  from dual union all
    select a_run_id, c_unit_id,5,3,0,1,0  from dual union all
    select a_run_id, c_unit_id,7,4,1,1,0  from dual;
  end;

  procedure mock_profiler_coverage_data(a_run_id integer) is
    c_unit_id   constant integer := 1;
  begin
    insert into ut3.plsql_profiler_runs ( runid, run_owner, run_date, run_comment)
    values(a_run_id, user, sysdate, 'unit testing utPLSQL');

    insert into ut3.plsql_profiler_units ( runid, unit_number, unit_type, unit_owner, unit_name)
    values(a_run_id, c_unit_id, 'PACKAGE BODY', 'UT3', 'DUMMY_COVERAGE');

    insert into ut3.plsql_profiler_data ( runid,  unit_number, line#, total_occur, total_time)
    select a_run_id, c_unit_id,     4,           1, 1  from dual union all
    select a_run_id, c_unit_id,     5,           0, 0  from dual union all
    select a_run_id, c_unit_id,     6,           1, 0  from dual union all
    select a_run_id, c_unit_id,     7,           1, 1  from dual;
  end;
  
  procedure setup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    create_dummy_coverage_package();
    create_dummy_coverage_test();
    g_run_id(ut3.ut_coverage.gc_block_coverage) := get_mock_block_run_id();
    g_run_id(ut3.ut_coverage.gc_proftab_coverage) := get_mock_proftab_run_id();
    ut3.ut_coverage.mock_coverage_id(g_run_id);
    mock_block_coverage_data(g_run_id(ut3.ut_coverage.gc_block_coverage));
    mock_profiler_coverage_data(g_run_id(ut3.ut_coverage.gc_proftab_coverage));
    commit;
  end;

  procedure cleanup_dummy_coverage is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3.test_dummy_coverage]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3.dummy_coverage]'; exception when others then null; end;
    delete from dbmspcc_blocks where run_id = g_run_id(ut3.ut_coverage.gc_block_coverage);
    delete from dbmspcc_units where run_id = g_run_id(ut3.ut_coverage.gc_block_coverage);
    delete from dbmspcc_runs where run_id = g_run_id(ut3.ut_coverage.gc_block_coverage);
    delete from ut3.plsql_profiler_data where runid = g_run_id(ut3.ut_coverage.gc_proftab_coverage);
    delete from ut3.plsql_profiler_units where runid = g_run_id(ut3.ut_coverage.gc_proftab_coverage);
    delete from ut3.plsql_profiler_runs where runid = g_run_id(ut3.ut_coverage.gc_proftab_coverage);
    commit;
  end;

  procedure coverage_for_object is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '%<file path="ut3.dummy_coverage">%<lineToCover lineNumber="4" covered="true" branchesToCover="2" coveredBranches="1"/>%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_include_objects => ut3.ut_varchar2_list( 'ut3.dummy_coverage' )
        )
      );
    --Assert
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure coverage_for_schema is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
  begin
    --Arrange
    l_expected := '%<file path="ut3.dummy_coverage">%<lineToCover lineNumber="4" covered="true" branchesToCover="2" coveredBranches="1"/>%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_coverage_schemes => ut3.ut_varchar2_list( 'ut3' )
        )
      );
    --Assert
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
    ut.expect(l_actual).to_be_like('%<file path="ut3.%">%<file path="ut3.%">%');
  end;

  procedure coverage_for_file is
    l_expected  clob;
    l_actual    clob;
    l_results   ut3.ut_varchar2_list;
    l_file_path varchar2(100);
  begin
    --Arrange
    l_file_path := lower('test/ut3.dummy_coverage.pkb');
    l_expected := '%<file path="'||l_file_path||'">%<lineToCover lineNumber="4" covered="true" branchesToCover="2" coveredBranches="1"/>%';
    --Act
    select *
      bulk collect into l_results
      from table(
        ut3.ut.run(
          a_path => 'ut3.test_dummy_coverage',
          a_reporter=> ut3.ut_coverage_sonar_reporter( ),
          a_source_files => ut3.ut_varchar2_list( l_file_path ),
          a_test_files => ut3.ut_varchar2_list( )
        )
      );
    --Assert
    l_actual := ut3.ut_utils.table_to_clob(l_results);
    ut.expect(l_actual).to_be_like(l_expected);
  end;

end;
/
