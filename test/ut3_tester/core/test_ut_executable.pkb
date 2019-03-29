create or replace package body test_ut_executable is

  g_dbms_output_text varchar2(30) := 'Some output from procedure';

  procedure exec_schema_package_proc is
    l_executable ut3.ut_executable;
    l_test       ut3.ut_test;
    l_result     boolean;
  begin
    --Arrange
    l_test := ut3.ut_test(a_object_name => 'test_ut_executable',a_name => 'test_ut_executable', a_line_no=> 1);
    l_executable := ut3.ut_executable_test( null, 'test_ut_executable', 'passing_proc', ut3.ut_utils.gc_test_execute );
    --Act
    l_result := l_executable.do_execute(l_test);
    --Assert
    ut.expect(l_result).to_be_true;
    ut.expect(l_executable.serveroutput).to_be_null;
    ut.expect(l_executable.get_error_stack_trace()).to_be_null;
  end;

  procedure exec_package_proc_output is
    l_executable ut3.ut_executable;
    l_test       ut3.ut_test;
    l_result     boolean;
  begin
    --Arrange
    l_test := ut3.ut_test(a_object_name => 'test_ut_executable',a_name => 'test_ut_executable', a_line_no=> 1);
    l_executable := ut3.ut_executable_test( user, 'test_ut_executable', 'output_proc', ut3.ut_utils.gc_test_execute );
    --Act
    l_result := l_executable.do_execute(l_test);
    --Assert
    ut.expect(l_result).to_be_true;
    ut.expect(l_executable.serveroutput).to_equal(to_clob(g_dbms_output_text||chr(10)));
    ut.expect(l_executable.get_error_stack_trace()).to_be_null;
  end;

  procedure exec_failing_proc is
    l_executable ut3.ut_executable;
    l_test       ut3.ut_test;
    l_result     boolean;
  begin
    --Arrange
    l_test := ut3.ut_test(a_object_name => 'test_ut_executable',a_name => 'test_ut_executable', a_line_no=> 1);
    l_executable := ut3.ut_executable_test( user, 'test_ut_executable', 'throwing_proc', ut3.ut_utils.gc_test_execute );
    --Act
    l_result := l_executable.do_execute(l_test);
    --Assert
    ut.expect(l_result).to_be_false;
    ut.expect(l_executable.serveroutput).to_be_null;
    ut.expect(l_executable.get_error_stack_trace()).to_be_like('ORA-06501: PL/SQL: program error%');
  end;

  procedure modify_stateful_package is
    l_job_name varchar2(30) := 'recreate_stateful_package';
    l_cnt      integer      := 1;
    pragma autonomous_transaction;
  begin
    dbms_scheduler.create_job(
        job_name      =>  l_job_name,
        job_type      =>  'PLSQL_BLOCK',
        job_action    =>  q'/
          begin
            execute immediate q'[
              create or replace package stateful_package as
                g_state varchar2(3) := 'abc';
              end;]';
          end;/',
        start_date    =>  localtimestamp,
        enabled       =>  TRUE,
        auto_drop     =>  TRUE,
        comments      =>  'one-time job'
    );
    $if dbms_db_version.version >= 18 $then
      dbms_session.sleep(0.4);
    $else
      dbms_lock.sleep(0.4);
    $end
    while l_cnt > 0 loop
      select count(1) into l_cnt
      from dba_scheduler_running_jobs srj
      where srj.job_name = l_job_name;
    end loop;
  end;

  procedure form_name is
  begin
    ut.expect(ut3.ut_executable_test( user, ' package ', 'proc', null ).form_name()).to_equal(user||'.package.proc');
    ut.expect(ut3.ut_executable_test( null, 'package', ' proc ', null ).form_name()).to_equal('package.proc');
    ut.expect(ut3.ut_executable_test( null, 'proc', null, null ).form_name()).to_equal('proc');
    ut.expect(ut3.ut_executable_test( ' '||user||' ', 'proc', null, null ).form_name()).to_equal(user||'.proc');
  end;

  procedure passing_proc is
  begin
    null;
  end;

  procedure output_proc is
  begin
    dbms_output.put_line(g_dbms_output_text);
  end;

  procedure throwing_proc is
  begin
    raise program_error;
  end;

end;
/
